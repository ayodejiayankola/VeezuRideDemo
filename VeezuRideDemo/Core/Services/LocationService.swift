import Foundation
import CoreLocation
import Combine

protocol LocationServiceable {
    var currentLocation: CLLocationCoordinate2D { get }
    var locationPublisher: AnyPublisher<CLLocationCoordinate2D, Never> { get }
    var authorizationStatus: CLAuthorizationStatus { get }

    func requestAuthorization()
    func startUpdatingLocation()
    func stopUpdatingLocation()
}

final class LocationService: NSObject, LocationServiceable {
    private let locationManager = CLLocationManager()
    private let locationSubject = CurrentValueSubject<CLLocationCoordinate2D, Never>(AppConstants.Map.defaultCenter)

    var currentLocation: CLLocationCoordinate2D {
        locationSubject.value
    }

    var locationPublisher: AnyPublisher<CLLocationCoordinate2D, Never> {
        locationSubject.eraseToAnyPublisher()
    }

    var authorizationStatus: CLAuthorizationStatus {
        locationManager.authorizationStatus
    }

    override init() {
        super.init()
        setupLocationManager()
    }

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10.0
    }

    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }

    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let coordinate = location.coordinate
        if coordinate.isValid {
            locationSubject.send(coordinate)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse ||
           manager.authorizationStatus == .authorizedAlways {
            startUpdatingLocation()
        }
    }
}

// MARK: - Mock Implementation for Testing
final class MockLocationService: LocationServiceable {
    var currentLocation: CLLocationCoordinate2D
    var locationPublisher: AnyPublisher<CLLocationCoordinate2D, Never>
    var authorizationStatus: CLAuthorizationStatus

    private let locationSubject: CurrentValueSubject<CLLocationCoordinate2D, Never>

    init(location: CLLocationCoordinate2D = AppConstants.Map.defaultCenter) {
        self.currentLocation = location
        self.locationSubject = CurrentValueSubject(location)
        self.locationPublisher = locationSubject.eraseToAnyPublisher()
        self.authorizationStatus = .authorizedWhenInUse
    }

    func requestAuthorization() {}
    func startUpdatingLocation() {}
    func stopUpdatingLocation() {}

    func simulateLocationUpdate(_ coordinate: CLLocationCoordinate2D) {
        currentLocation = coordinate
        locationSubject.send(coordinate)
    }
}
