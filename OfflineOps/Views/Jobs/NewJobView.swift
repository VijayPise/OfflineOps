import SwiftUI

// MARK: - New Job View

struct NewJobView: View {
    let syncEngine: SyncEngine
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var customerName = ""
    @State private var address = ""
    @State private var scheduledDate = Date()

    var body: some View {
        NavigationStack {
            Form {
                Section("Job Details") {
                    TextField("Job title (e.g. AC Repair)", text: $title)
                    TextField("Customer name", text: $customerName)
                    TextField("Address", text: $address)
                }

                Section("Schedule") {
                    DatePicker("Date & time", selection: $scheduledDate)
                }

                Section {
                    Label(
                        "This job saves to your device immediately and uploads automatically when you're back online.",
                        systemImage: "info.circle.fill"
                    )
                    .font(FTTheme.captionFont)
                    .foregroundStyle(FTTheme.textSecondary)
                }
            }
            .navigationTitle("New Job")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveJob()
                    }
                    .fontWeight(.bold)
                    .disabled(title.isEmpty || customerName.isEmpty)
                }
            }
        }
    }

    private func saveJob() {
        let job = Job(
            title: title,
            customerName: customerName,
            address: address.isEmpty ? "Address not set" : address,
            latitude: 18.5204 + Double.random(in: -0.05...0.05),
            longitude: 73.8567 + Double.random(in: -0.05...0.05),
            scheduledDate: scheduledDate
        )
        syncEngine.createJob(job)
        dismiss()
    }
}
