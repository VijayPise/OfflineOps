import SwiftUI

// MARK: - Job Card

struct JobCard: View {
    let job: Job

    var body: some View {
        HStack(spacing: 14) {

            RoundedRectangle(cornerRadius: 3)
                .fill(job.status.color)
                .frame(width: 5)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(job.title)
                        .font(FTTheme.titleFont)
                        .foregroundStyle(FTTheme.textPrimary)
                        .lineLimit(1)

                    Spacer()

                    SyncStatusBadge(status: job.syncStatus, compact: true)
                }

                Text(job.customerName)
                    .font(FTTheme.bodyFont)
                    .foregroundStyle(FTTheme.textSecondary)

                HStack(spacing: 6) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundStyle(FTTheme.textSecondary)
                        .font(.system(size: 13))
                    Text(job.address)
                        .font(FTTheme.captionFont)
                        .foregroundStyle(FTTheme.textSecondary)
                        .lineLimit(1)
                }

                HStack(spacing: 8) {
                    Label(job.status.label, systemImage: job.status.icon)
                        .font(FTTheme.captionFont)
                        .foregroundStyle(job.status.color)

                    Text("•")
                        .foregroundStyle(FTTheme.textSecondary)

                    Text(job.scheduledDate, style: .time)
                        .font(FTTheme.captionFont)
                        .foregroundStyle(FTTheme.textSecondary)
                }
                .padding(.top, 2)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(FTTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: FTTheme.cornerRadius))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 3)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 12) {
            ForEach(Job.sampleList) { job in
                JobCard(job: job)
            }
        }
        .padding()
    }
    .background(FTTheme.background)
}
