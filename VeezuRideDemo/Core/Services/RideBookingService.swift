import Foundation
import CoreLocation
import Combine

@MainActor
protocol RideBookingServiceable {
    var currentRidePublisher: AnyPublisher<RideRequest?, Never> { get }
    var currentRide: RideRequest? { get }

    func requestRide(
        pickup: CLLocationCoordinate2D,
        pickupAddress: String,
        dropoff: CLLocationCoordinate2D,
        dropoffAddress: String,
        estimatedFare: Decimal
    ) async throws -> RideRequest

    func cancelRide() async
    func assignDriver(_ driver: Driver, to rideId: String) async
}

enum RideBookingError: LocalizedError {
    case noDriversAvailable
    case invalidLocation
    case bookingInProgress

    var errorDescription: String? {
        switch self {
        case .noDriversAvailable:
            return "No drivers are currently available in your area"
        case .invalidLocation:
            return "Invalid pickup or dropoff location"
        case .bookingInProgress:
            return "A ride is already in progress"
        }
    }
}

@MainActor
final class RideBookingService: RideBookingServiceable {
    private let currentRideSubject = CurrentValueSubject<RideRequest?, Never>(nil)
    private let driverSimulationService: DriverSimulationServiceable

    var currentRidePublisher: AnyPublisher<RideRequest?, Never> {
        currentRideSubject.eraseToAnyPublisher()
    }

    var currentRide: RideRequest? {
        currentRideSubject.value
    }

    init(driverSimulationService: DriverSimulationServiceable) {
        self.driverSimulationService = driverSimulationService
    }

    func requestRide(
        pickup: CLLocationCoordinate2D,
        pickupAddress: String,
        dropoff: CLLocationCoordinate2D,
        dropoffAddress: String,
        estimatedFare: Decimal
    ) async throws -> RideRequest {
        
        if let currentRide = currentRide, currentRide.state.isActive {
            throw RideBookingError.bookingInProgress
        }

        guard pickup.isValid && dropoff.isValid else {
            throw RideBookingError.invalidLocation
        }

        var rideRequest = RideRequest(
            pickupLocation: pickup,
            dropoffLocation: dropoff,
            pickupAddress: pickupAddress,
            dropoffAddress: dropoffAddress,
            state: .searching,
            estimatedFare: estimatedFare
        )

        currentRideSubject.send(rideRequest)

        try? await Task.sleep(nanoseconds: UInt64(AppConstants.Ride.maxSearchTime * 1_000_000_000))

        guard let nearestDriver = driverSimulationService.findNearestAvailableDriver(to: pickup) else {
            rideRequest.state = .cancelled
            currentRideSubject.send(rideRequest)
            throw RideBookingError.noDriversAvailable
        }

        try? await Task.sleep(nanoseconds: UInt64(AppConstants.Ride.assignmentDelay * 1_000_000_000))

        rideRequest.state = .assigned
        rideRequest.assignedDriver = nearestDriver
        rideRequest.acceptedTime = Date()

        let distance = pickup.distance(to: nearestDriver.coordinate)
        let eta = distance / AppConstants.Simulation.driverSpeed

        var assignedDriver = nearestDriver
        assignedDriver.eta = eta

        rideRequest.assignedDriver = assignedDriver

        driverSimulationService.updateDriverStatus(id: nearestDriver.id, status: .busy)

        currentRideSubject.send(rideRequest)

        return rideRequest
    }

    func cancelRide() async {
        guard var ride = currentRide else { return }

        if let driver = ride.assignedDriver {
            driverSimulationService.updateDriverStatus(id: driver.id, status: .available)
        }

        ride.state = .cancelled
        currentRideSubject.send(ride)

        try? await Task.sleep(nanoseconds: 500_000_000)
        currentRideSubject.send(nil)
    }

    func assignDriver(_ driver: Driver, to rideId: String) async {
        guard var ride = currentRide, ride.id == rideId else { return }

        ride.assignedDriver = driver
        ride.state = .assigned
        ride.acceptedTime = Date()

        driverSimulationService.updateDriverStatus(id: driver.id, status: .busy)

        currentRideSubject.send(ride)
    }
}

// MARK: - Mock Implementation

@MainActor
final class MockRideBookingService: RideBookingServiceable {
    private let currentRideSubject = CurrentValueSubject<RideRequest?, Never>(nil)

    var currentRidePublisher: AnyPublisher<RideRequest?, Never> {
        currentRideSubject.eraseToAnyPublisher()
    }

    var currentRide: RideRequest? {
        currentRideSubject.value
    }

    func requestRide(
        pickup: CLLocationCoordinate2D,
        pickupAddress: String,
        dropoff: CLLocationCoordinate2D,
        dropoffAddress: String,
        estimatedFare: Decimal
    ) async throws -> RideRequest {
        let ride = RideRequest(
            pickupLocation: pickup,
            dropoffLocation: dropoff,
            pickupAddress: pickupAddress,
            dropoffAddress: dropoffAddress,
            state: .assigned,
            estimatedFare: estimatedFare
        )
        currentRideSubject.send(ride)
        return ride
    }

    func cancelRide() async {
        currentRideSubject.send(nil)
    }

    func assignDriver(_ driver: Driver, to rideId: String) async {
        guard var ride = currentRide else { return }
        ride.assignedDriver = driver
        currentRideSubject.send(ride)
    }
}
