import Foundation
import SwiftUI
import MapKit
import Combine

@MainActor
final class MapViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var region: MKCoordinateRegion
    @Published var drivers: [Driver] = []
    @Published var userLocation: CLLocationCoordinate2D
    @Published var selectedDestination: CLLocationCoordinate2D?

    // MARK: - Services
    private let locationService: LocationServiceable
    private let driverSimulationService: DriverSimulationServiceable

    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init(
        locationService: LocationServiceable,
        driverSimulationService: DriverSimulationServiceable
    ) {
        self.locationService = locationService
        self.driverSimulationService = driverSimulationService

        let defaultCenter = locationService.currentLocation
        self.userLocation = defaultCenter
        self.region = MKCoordinateRegion(
            center: defaultCenter,
            span: MKCoordinateSpan(
                latitudeDelta: AppConstants.Map.defaultSpan,
                longitudeDelta: AppConstants.Map.defaultSpan
            )
        )

        setupBindings()
    }

    // MARK: - Setup
    private func setupBindings() {
        locationService.locationPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] location in
                self?.userLocation = location
                if let center = self?.region.center, center.isEqual(to: AppConstants.Map.defaultCenter) {
                    self?.region = MKCoordinateRegion(
                        center: location,
                        span: MKCoordinateSpan(
                            latitudeDelta: AppConstants.Map.defaultSpan,
                            longitudeDelta: AppConstants.Map.defaultSpan
                        )
                    )
                }
            }
            .store(in: &cancellables)

        driverSimulationService.driversPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$drivers)
    }

    // MARK: - Public Methods

    func centerOnUserLocation() {
        withAnimation {
            region = MKCoordinateRegion(
                center: userLocation,
                span: MKCoordinateSpan(
                    latitudeDelta: AppConstants.Map.defaultSpan,
                    longitudeDelta: AppConstants.Map.defaultSpan
                )
            )
        }
    }
    
    func setDestination(_ coordinate: CLLocationCoordinate2D) {
        selectedDestination = coordinate
        
        let pickupLocation = userLocation
        let dropoffLocation = coordinate

        let centerLat = (pickupLocation.latitude + dropoffLocation.latitude) / 2
        let centerLon = (pickupLocation.longitude + dropoffLocation.longitude) / 2

        let latDelta = abs(pickupLocation.latitude - dropoffLocation.latitude) * 1.5
        let lonDelta = abs(pickupLocation.longitude - dropoffLocation.longitude) * 1.5

        withAnimation {
            region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon),
                span: MKCoordinateSpan(
                    latitudeDelta: max(latDelta, 0.01),
                    longitudeDelta: max(lonDelta, 0.01)
                )
            )
        }
    }

    func clearDestination() {
        selectedDestination = nil
        centerOnUserLocation()
    }

    func getNearestAvailableDriver() -> Driver? {
        return driverSimulationService.findNearestAvailableDriver(to: userLocation)
    }

    func focusOnDriver(_ driver: Driver) {
        withAnimation {
            region = MKCoordinateRegion(
                center: driver.coordinate,
                span: MKCoordinateSpan(
                    latitudeDelta: 0.01,
                    longitudeDelta: 0.01
                )
            )
        }
    }
}
