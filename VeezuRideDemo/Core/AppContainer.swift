import Foundation

final class AppContainer: @unchecked Sendable {
    static let shared: AppContainer = {
        MainActor.assumeIsolated {
            AppContainer()
        }
    }()

    // MARK: - Services
    
    let locationService: any LocationServiceable
    let driverSimulationService: any DriverSimulationServiceable
    let fareCalculationService: any FareCalculationServiceable
    let rideBookingService: any RideBookingServiceable

    // MARK: - Configuration
    
    private let isProduction: Bool

    @MainActor
    private init(isProduction: Bool = true) {
        self.isProduction = isProduction
        
        if isProduction {
            
            self.locationService = LocationService()
            self.fareCalculationService = FareCalculationService()
            self.driverSimulationService = DriverSimulationService()
            self.rideBookingService = RideBookingService(
                driverSimulationService: self.driverSimulationService
            )
        } else {
            self.locationService = MockLocationService()
            self.fareCalculationService = MockFareCalculationService()
            self.driverSimulationService = MockDriverSimulationService()
            self.rideBookingService = MockRideBookingService()
        }
    }

    @MainActor
    static func mock() -> AppContainer {
        return AppContainer(isProduction: false)
    }

    @MainActor
    func startServices() {
        locationService.requestAuthorization()
        locationService.startUpdatingLocation()
        driverSimulationService.start()
    }

    @MainActor
    func stopServices() {
        locationService.stopUpdatingLocation()
        driverSimulationService.stop()
    }
}

// MARK: - Environment Key for SwiftUI

import SwiftUI

private struct AppContainerKey: EnvironmentKey {
    static let defaultValue: AppContainer = .shared
}

extension EnvironmentValues {
    var appContainer: AppContainer {
        get { self[AppContainerKey.self] }
        set { self[AppContainerKey.self] = newValue }
    }
}
