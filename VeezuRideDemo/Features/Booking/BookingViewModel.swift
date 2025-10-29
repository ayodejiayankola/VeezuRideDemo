import Foundation
import CoreLocation
import Combine

@MainActor
final class BookingViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var bookingState: RideState = .idle
    @Published var pickupAddress: String = "Your location"
    @Published var dropoffAddress: String = ""
    @Published var estimatedFare: Decimal = 0
    @Published var currentRide: RideRequest?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false

    // MARK: - Services
    private let rideBookingService: RideBookingServiceable
    private let fareCalculationService: FareCalculationServiceable
    private let locationService: LocationServiceable

    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Computed Properties
    var canRequestRide: Bool {
        return bookingState == .idle && !dropoffAddress.isEmpty
    }

    var canCancelRide: Bool {
        return currentRide?.state.canCancel ?? false
    }

    var showBookingPanel: Bool {
        return true
    }

    var assignedDriverName: String? {
        return currentRide?.assignedDriver?.name
    }

    var assignedDriverETA: String? {
        guard let eta = currentRide?.assignedDriver?.eta else { return nil }
        let minutes = Int(ceil(eta / 60))
        return "\(minutes) min"
    }

    // MARK: - Initialization
    init(
        rideBookingService: RideBookingServiceable,
        fareCalculationService: FareCalculationServiceable,
        locationService: LocationServiceable
    ) {
        self.rideBookingService = rideBookingService
        self.fareCalculationService = fareCalculationService
        self.locationService = locationService

        setupBindings()
        setupDefaultDestination()
    }

    // MARK: - Setup
    
    private func setupBindings() {
        rideBookingService.currentRidePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] ride in
                self?.currentRide = ride
                self?.bookingState = ride?.state ?? .idle
                self?.isLoading = false
            }
            .store(in: &cancellables)
    }

    private func setupDefaultDestination() {
        if let landmark = AppConstants.cardiffLandmarks.first {
            dropoffAddress = landmark
            calculateFare()
        }
    }

    // MARK: - Public Methods

    func requestRide() async {
        guard canRequestRide else {
            errorMessage = "Please select a destination first"
            return
        }

        isLoading = true
        errorMessage = nil

        let pickup = locationService.currentLocation

        let dropoff = CLLocationCoordinate2D.random(
            center: pickup,
            radius: 5000
        )

        do {
            let ride = try await rideBookingService.requestRide(
                pickup: pickup,
                pickupAddress: pickupAddress,
                dropoff: dropoff,
                dropoffAddress: dropoffAddress,
                estimatedFare: estimatedFare
            )

            currentRide = ride
            bookingState = ride.state
        } catch let error as RideBookingError {
            errorMessage = error.errorDescription
            bookingState = .idle
        } catch {
            errorMessage = "Failed to request ride: \(error.localizedDescription)"
            bookingState = .idle
        }

        isLoading = false
    }

    func cancelRide() async {
        guard canCancelRide else { return }

        isLoading = true
        
        await rideBookingService.cancelRide()

        try? await Task.sleep(nanoseconds: 100_000_000)

        bookingState = .idle
        currentRide = nil
        errorMessage = nil
        isLoading = false
    }

    func updateDestination(_ address: String) {
        dropoffAddress = address
        calculateFare()
    }

    func calculateFare() {
        let pickup = locationService.currentLocation

        let dropoff = CLLocationCoordinate2D.random(
            center: pickup,
            radius: 5000
        )

        estimatedFare = fareCalculationService.calculateFare(
            from: pickup,
            to: dropoff,
            vehicleType: .sedan
        )
    }

    func selectPredefinedDestination(_ landmark: String) {
        updateDestination(landmark)
    }
    
    func reset() {
        bookingState = .idle
        currentRide = nil
        errorMessage = nil
        isLoading = false
        setupDefaultDestination()
    }
}
