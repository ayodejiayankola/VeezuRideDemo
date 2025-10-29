import Foundation
import CoreLocation

protocol FareCalculationServiceable {
    func calculateFare(
        from pickup: CLLocationCoordinate2D,
        to dropoff: CLLocationCoordinate2D,
        vehicleType: VehicleType
    ) -> Decimal

    func calculateDistance(
        from pickup: CLLocationCoordinate2D,
        to dropoff: CLLocationCoordinate2D
    ) -> CLLocationDistance
}

final class FareCalculationService: FareCalculationServiceable {

    func calculateFare(
        from pickup: CLLocationCoordinate2D,
        to dropoff: CLLocationCoordinate2D,
        vehicleType: VehicleType
    ) -> Decimal {
        let distanceInMeters = calculateDistance(from: pickup, to: dropoff)
        let distanceInKm = Decimal(distanceInMeters / 1000.0)

        let baseFare = AppConstants.Ride.baseFare
        let distanceFare = distanceInKm * AppConstants.Ride.perKilometerRate
        let vehicleMultiplier = Decimal(vehicleType.baseFareMultiplier)

        var totalFare = (baseFare + distanceFare) * vehicleMultiplier

        if totalFare < AppConstants.Ride.minimumFare {
            totalFare = AppConstants.Ride.minimumFare
        }

        return totalFare.rounded(scale: 2)
    }

    func calculateDistance(
        from pickup: CLLocationCoordinate2D,
        to dropoff: CLLocationCoordinate2D
    ) -> CLLocationDistance {
        return pickup.distance(to: dropoff)
    }
}

// MARK: - Mock Implementation

final class MockFareCalculationService: FareCalculationServiceable {
    var mockFare: Decimal = 12.50

    func calculateFare(
        from pickup: CLLocationCoordinate2D,
        to dropoff: CLLocationCoordinate2D,
        vehicleType: VehicleType
    ) -> Decimal {
        return mockFare
    }

    func calculateDistance(
        from pickup: CLLocationCoordinate2D,
        to dropoff: CLLocationCoordinate2D
    ) -> CLLocationDistance {
        return 5000.0
    }
}

// MARK: - Decimal Extension

extension Decimal {
    func rounded(scale: Int) -> Decimal {
        var result = self
        var rounded = Decimal()
        NSDecimalRound(&rounded, &result, scale, .plain)
        return rounded
    }
}
