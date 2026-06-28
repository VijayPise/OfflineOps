import SwiftUI

// MARK: - Conflict Resolution View

struct ConflictResolutionView: View {
    let conflict: JobConflict
    let syncEngine: SyncEngine
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    VStack(alignment: .leading, spacing: 6) {
                        Label("This job was changed elsewhere", systemImage: "exclamationmark.triangle.fill")
                            .font(FTTheme.titleFont)
                            .foregroundStyle(FTTheme.syncConflict)

                        Text("Your office team updated this job while you were offline. Choose which version to keep.")
                            .font(FTTheme.bodyFont)
                            .foregroundStyle(FTTheme.textSecondary)
                    }

                    versionCard(
                        title: "Your version (on this phone)",
                        job: conflict.localJob,
                        accent: FTTheme.primary
                    ) {
                        syncEngine.resolveConflict(conflict, keepLocal: true)
                        dismiss()
                    }

                    versionCard(
                        title: "Office version (server)",
                        job: conflict.serverJob,
                        accent: FTTheme.statusCompleted
                    ) {
                        syncEngine.resolveConflict(conflict, keepLocal: false)
                        dismiss()
                    }
                }
                .padding(16)
            }
            .background(FTTheme.background)
            .navigationTitle("Resolve Conflict")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.large])
    }

    private func versionCard(
        title: String,
        job: Job,
        accent: Color,
        onKeep: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(FTTheme.captionFont)
                .foregroundStyle(accent)

            Text(job.title)
                .font(FTTheme.titleFont)
                .foregroundStyle(FTTheme.textPrimary)

            Text(job.notes.isEmpty ? "No notes" : job.notes)
                .font(FTTheme.bodyFont)
                .foregroundStyle(FTTheme.textSecondary)

            Button(action: onKeep) {
                Text("Keep This Version")
                    .font(FTTheme.bodyFont)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(accent)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(16)
        .background(FTTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: FTTheme.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: FTTheme.cornerRadius)
                .stroke(accent.opacity(0.3), lineWidth: 1.5)
        )
    }
}
