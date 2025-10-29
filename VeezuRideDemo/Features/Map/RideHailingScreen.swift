import SwiftUI

struct RideHailingScreen: View {
    @StateObject private var mapViewModel: MapViewModel
    @StateObject private var bookingViewModel: BookingViewModel

    init() {
        let container = AppContainer.shared

        _mapViewModel = StateObject(wrappedValue: MapViewModel(
            locationService: container.locationService,
            driverSimulationService: container.driverSimulationService
        ))

        _bookingViewModel = StateObject(wrappedValue: BookingViewModel(
            rideBookingService: container.rideBookingService,
            fareCalculationService: container.fareCalculationService,
            locationService: container.locationService
        ))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            MapView(
                viewModel: mapViewModel,
                assignedDriverId: bookingViewModel.currentRide?.assignedDriver?.id
            )
            VStack {
                HStack {
                    Spacer()

                    Button {
                        mapViewModel.centerOnUserLocation()
                    } label: {
                        Image(systemName: "location.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.blue)
                            .padding(12)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
                    }
                    .padding(.trailing, 16)
                }
                .padding(.top, 60)

                Spacer()
            }

            BookingPanelView(viewModel: bookingViewModel)
                .transition(.move(edge: .bottom).combined(with: .opacity))
        }
        .ignoresSafeArea(edges: .bottom)
        .task { @MainActor in
            AppContainer.shared.startServices()
        }
    }
}

// MARK: - Preview
#Preview {
    RideHailingScreen()
}
