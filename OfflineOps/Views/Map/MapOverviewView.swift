import SwiftUI
import MapKit

// MARK: - Map Overview

struct MapOverviewView: View {
    @ObservedObject var syncEngine: SyncEngine
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var selectedJob: Job?

    var body: some View {
        NavigationStack {
            Map(position: $cameraPosition, selection: $selectedJob) {
                ForEach(syncEngine.jobs) { job in
                    Marker(job.title, systemImage: job.status.icon, coordinate: job.coordinate)
                        .tint(job.status.color)
                        .tag(job)
                }
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
            }
            .navigationTitle("Job Map")
            .sheet(item: $selectedJob) { job in
                NavigationStack {
                    JobDetailView(viewModel: JobDetailViewModel(job: job, syncEngine: syncEngine))
                }
                .presentationDetents([.medium, .large])
            }
        }
    }
}
