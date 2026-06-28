import SwiftUI

// MARK: - Job Detail View
struct JobDetailView: View {
    @StateObject var viewModel: JobDetailViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                header

                infoCard

                notesSection

                actionButton
            }
            .padding(16)
        }
        .background(FTTheme.background)
        .navigationTitle(viewModel.job.title)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $viewModel.showCompletionSheet) {
            CompletionSheet(viewModel: viewModel)
        }
    }

    // MARK: - Header
    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label(viewModel.job.status.label, systemImage: viewModel.job.status.icon)
                    .font(FTTheme.bodyFont)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(viewModel.job.status.color)
                    .clipShape(Capsule())

                Spacer()

                SyncStatusBadge(status: viewModel.job.syncStatus)
            }

            Text(viewModel.job.customerName)
                .font(FTTheme.displayFont)
                .foregroundStyle(FTTheme.textPrimary)
        }
    }

    // MARK: - Info Card
    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            infoRow(icon: "mappin.circle.fill", title: "Address", value: viewModel.job.address)
            Divider()
            infoRow(icon: "clock.fill", title: "Scheduled", value: viewModel.job.scheduledDate.formatted(date: .abbreviated, time: .shortened))
            if let completedAt = viewModel.job.completedAt {
                Divider()
                infoRow(icon: "checkmark.circle.fill", title: "Completed", value: completedAt.formatted(date: .abbreviated, time: .shortened))
            }
        }
        .padding(16)
        .background(FTTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: FTTheme.cornerRadius))
    }

    private func infoRow(icon: String, title: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(FTTheme.primary)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(FTTheme.captionFont)
                    .foregroundStyle(FTTheme.textSecondary)
                Text(value)
                    .font(FTTheme.bodyFont)
                    .foregroundStyle(FTTheme.textPrimary)
            }
        }
    }

    // MARK: - Notes
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Job Notes")
                .font(FTTheme.titleFont)
                .foregroundStyle(FTTheme.textPrimary)

            TextEditor(text: $viewModel.notesDraft)
                .font(FTTheme.bodyFont)
                .frame(minHeight: 120)
                .padding(8)
                .background(FTTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: FTTheme.cornerRadius))
                .onChange(of: viewModel.notesDraft) { _, _ in
                    viewModel.saveNotes()
                }
        }
    }

    // MARK: - Action Button
    private var actionButton: some View {
        Group {
            if viewModel.job.status != .completed && viewModel.job.status != .cancelled {
                Button {
                    viewModel.advanceStatus()
                } label: {
                    Text(nextActionLabel)
                        .font(FTTheme.titleFont)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: FTTheme.minTapTarget)
                        .background(viewModel.job.status.color)
                        .clipShape(RoundedRectangle(cornerRadius: FTTheme.cornerRadius))
                }
            }
        }
    }

    private var nextActionLabel: String {
        switch viewModel.job.status {
        case .scheduled:  return "Start Driving"
        case .enRoute:    return "Arrived — Start Job"
        case .inProgress: return "Mark Job Complete"
        default:          return ""
        }
    }
}

// MARK: - Completion Sheet
private struct CompletionSheet: View {
    @ObservedObject var viewModel: JobDetailViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(FTTheme.statusCompleted)
                    .padding(.top, 24)

                Text("Complete this job?")
                    .font(FTTheme.displayFont)

                Text("Add any final notes before marking this job as done.")
                    .font(FTTheme.bodyFont)
                    .foregroundStyle(FTTheme.textSecondary)
                    .multilineTextAlignment(.center)

                TextEditor(text: $viewModel.notesDraft)
                    .frame(height: 100)
                    .padding(8)
                    .background(FTTheme.surfaceDim)
                    .clipShape(RoundedRectangle(cornerRadius: FTTheme.cornerRadius))

                Button {
                    viewModel.completeJob()
                } label: {
                    Text("Confirm Complete")
                        .font(FTTheme.titleFont)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: FTTheme.minTapTarget)
                        .background(FTTheme.statusCompleted)
                        .clipShape(RoundedRectangle(cornerRadius: FTTheme.cornerRadius))
                }

                Spacer()
            }
            .padding(20)
            .background(FTTheme.background)
        }
        .presentationDetents([.medium])
    }
}
