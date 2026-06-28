import SwiftUI

// MARK: - Job List View
struct JobListView: View {
    @StateObject var viewModel: JobListViewModel
    @State private var showNewJobSheet = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                ConnectivityBanner(
                    networkMonitor: viewModel.networkMonitor,
                    pendingCount: viewModel.syncEngine.pendingCount,
                    isSyncing: viewModel.syncEngine.isSyncing
                )
                .animation(.spring(response: 0.35), value: viewModel.networkMonitor.isConnected)

                filterBar

                if viewModel.filteredJobs.isEmpty {
                    emptyState
                } else {
                    jobList
                }
            }
            .background(FTTheme.background)
            .navigationTitle("Today's Jobs")
            .searchable(text: $viewModel.searchText, prompt: "Search jobs or customers")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showNewJobSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                    }
                    // 56pt minimum tap target even though the icon is small
                    .frame(width: FTTheme.minTapTarget, height: FTTheme.minTapTarget)
                }
            }
            .sheet(isPresented: $showNewJobSheet) {
                NewJobView(syncEngine: viewModel.syncEngine)
            }
            .sheet(item: conflictBinding) { conflict in
                ConflictResolutionView(conflict: conflict, syncEngine: viewModel.syncEngine)
            }
        }
    }

    // MARK: - Filter Bar
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                filterChip(label: "All", isSelected: viewModel.statusFilter == nil) {
                    viewModel.statusFilter = nil
                }
                ForEach(JobStatus.allCases, id: \.self) { status in
                    filterChip(
                        label: status.label,
                        color: status.color,
                        isSelected: viewModel.statusFilter == status
                    ) {
                        viewModel.statusFilter = (viewModel.statusFilter == status) ? nil : status
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }

    private func filterChip(
        label: String,
        color: Color = FTTheme.primary,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(label)
                .font(FTTheme.captionFont)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? color : FTTheme.surfaceDim)
                .foregroundStyle(isSelected ? .white : FTTheme.textSecondary)
                .clipShape(Capsule())
        }
    }

    // MARK: - Job List
    private var jobList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.filteredJobs) { job in
                    NavigationLink(value: job) {
                        JobCard(job: job)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)
        }
        .refreshable {
            await viewModel.refresh()
        }
        .navigationDestination(for: Job.self) { job in
            JobDetailView(
                viewModel: JobDetailViewModel(job: job, syncEngine: viewModel.syncEngine)
            )
        }
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "checkmark.circle")
                .font(.system(size: 48))
                .foregroundStyle(FTTheme.textSecondary.opacity(0.4))
            Text("No jobs match")
                .font(FTTheme.titleFont)
                .foregroundStyle(FTTheme.textPrimary)
            Text("Try a different filter or search term.")
                .font(FTTheme.bodyFont)
                .foregroundStyle(FTTheme.textSecondary)
            Spacer()
        }
    }

    // MARK: - Conflict sheet binding
    private var conflictBinding: Binding<JobConflict?> {
        Binding(
            get: { viewModel.syncEngine.conflicts.first },
            set: { _ in }
        )
    }
}

// MARK: - Job: Hashable for NavigationLink(value:)
extension Job: Hashable {
    static func == (lhs: Job, rhs: Job) -> Bool { lhs.id == rhs.id && lhs.version == rhs.version }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
