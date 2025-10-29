import SwiftUI
import MapKit

struct MapView: View {
    @ObservedObject var viewModel: MapViewModel
    let assignedDriverId: String?

    var body: some View {
        Map(position: .constant(.region(viewModel.region))) {
            Annotation("Your Location", coordinate: viewModel.userLocation) {
                UserLocationView()
            }

            ForEach(viewModel.drivers) { driver in
                Annotation(driver.name, coordinate: driver.coordinate) {
                    DriverAnnotationView(
                        driver: driver,
                        isAssigned: driver.id == assignedDriverId
                    )
                }
                .annotationTitles(.hidden)
            }

            if let destination = viewModel.selectedDestination {
                Annotation("Destination", coordinate: destination) {
                    DestinationAnnotationView()
                }
            }
        }
        .mapStyle(.standard(elevation: .realistic))
        .ignoresSafeArea()
    }
}

// MARK: - User Location View
struct UserLocationView: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(.blue.opacity(0.3))
                .frame(width: 50, height: 50)

            Circle()
                .fill(.blue)
                .frame(width: 16, height: 16)
                .overlay(
                    Circle()
                        .stroke(.white, lineWidth: 3)
                )
        }
    }
}

// MARK: - Destination Annotation View
struct DestinationAnnotationView: View {
    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 40))
                .foregroundStyle(.red, .white)

            Text("D")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .offset(y: -25)
        }
    }
}

// MARK: - Preview
#Preview {
    @MainActor func makeView() -> MapView {
        let container = AppContainer.mock()
        let viewModel = MapViewModel(
            locationService: container.locationService,
            driverSimulationService: container.driverSimulationService
        )
        return MapView(viewModel: viewModel, assignedDriverId: nil)
    }

    return makeView()
}

