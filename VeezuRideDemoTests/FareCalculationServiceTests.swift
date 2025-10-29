import XCTest
import CoreLocation
@testable import VeezuRideDemo

final class FareCalculationServiceTests: XCTestCase {
    var sut: FareCalculationService!

    override func setUp() {
        super.setUp()
        sut = FareCalculationService()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Distance Calculation Tests

    func testCalculateDistance_SameLocation_ReturnsZero() {
        let location = CLLocationCoordinate2D(latitude: 51.4816, longitude: -3.1791)

        let distance = sut.calculateDistance(from: location, to: location)

        XCTAssertEqual(distance, 0, accuracy: 1.0, "Distance between same location should be zero")
    }

    func testCalculateDistance_DifferentLocations_ReturnsPositiveDistance() {
        let pickup = CLLocationCoordinate2D(latitude: 51.4816, longitude: -3.1791)
        let dropoff = CLLocationCoordinate2D(latitude: 51.4900, longitude: -3.1700)

        let distance = sut.calculateDistance(from: pickup, to: dropoff)

        XCTAssertGreaterThan(distance, 0, "Distance should be positive")
        XCTAssertLessThan(distance, 2000, "Distance should be reasonable for Cardiff")
    }

    // MARK: - Fare Calculation Tests

    func testCalculateFare_ShortDistance_ReturnsMinimumFare() {
        
        let pickup = CLLocationCoordinate2D(latitude: 51.4816, longitude: -3.1791)
        let dropoff = CLLocationCoordinate2D(latitude: 51.4817, longitude: -3.1791)

        let fare = sut.calculateFare(from: pickup, to: dropoff, vehicleType: .sedan)

        XCTAssertEqual(fare, AppConstants.Ride.minimumFare, "Short trips should have minimum fare")
    }

    func testCalculateFare_MediumDistance_CalculatesCorrectly() {
        
        let pickup = CLLocationCoordinate2D(latitude: 51.4816, longitude: -3.1791)
        let dropoff = CLLocationCoordinate2D(latitude: 51.5200, longitude: -3.1500)

        let fare = sut.calculateFare(from: pickup, to: dropoff, vehicleType: .sedan)

        XCTAssertGreaterThan(fare, AppConstants.Ride.minimumFare, "Medium distance should exceed minimum fare")
        XCTAssertLessThan(fare, 20.0, "Fare should be reasonable for ~5km trip")
    }

    func testCalculateFare_DifferentVehicleTypes_AppliesCorrectMultiplier() {
        
        let pickup = CLLocationCoordinate2D(latitude: 51.4816, longitude: -3.1791)
        let dropoff = CLLocationCoordinate2D(latitude: 51.5200, longitude: -3.1500)

        let sedanFare = sut.calculateFare(from: pickup, to: dropoff, vehicleType: .sedan)
        let suvFare = sut.calculateFare(from: pickup, to: dropoff, vehicleType: .suv)
        let luxuryFare = sut.calculateFare(from: pickup, to: dropoff, vehicleType: .luxury)

        XCTAssertLessThan(sedanFare, suvFare, "SUV should be more expensive than sedan")
        XCTAssertLessThan(suvFare, luxuryFare, "Luxury should be most expensive")
    }

    func testCalculateFare_ElectricVehicle_AppliesCorrectMultiplier() {
        
        let pickup = CLLocationCoordinate2D(latitude: 51.4816, longitude: -3.1791)
        let dropoff = CLLocationCoordinate2D(latitude: 51.5200, longitude: -3.1500)

        let sedanFare = sut.calculateFare(from: pickup, to: dropoff, vehicleType: .sedan)
        let electricFare = sut.calculateFare(from: pickup, to: dropoff, vehicleType: .electric)

        XCTAssertGreaterThan(electricFare, sedanFare, "Electric should have slight premium")
        XCTAssertLessThan(electricFare - sedanFare, 2.0, "Premium should be modest")
    }

    // MARK: - Rounding Tests

    func testCalculateFare_RoundsToTwoDecimalPlaces() {
      
        let pickup = CLLocationCoordinate2D(latitude: 51.4816, longitude: -3.1791)
        let dropoff = CLLocationCoordinate2D(latitude: 51.4900, longitude: -3.1700)

        let fare = sut.calculateFare(from: pickup, to: dropoff, vehicleType: .sedan)

        let fareString = String(describing: fare)
        let decimalParts = fareString.split(separator: ".")

        if decimalParts.count > 1 {
            XCTAssertLessThanOrEqual(decimalParts[1].count, 2, "Fare should have max 2 decimal places")
        }
    }

    // MARK: - Performance Tests

    func testCalculateFare_Performance() {
   
        let pickup = CLLocationCoordinate2D(latitude: 51.4816, longitude: -3.1791)
        let dropoff = CLLocationCoordinate2D(latitude: 51.5200, longitude: -3.1500)

        measure {
            _ = sut.calculateFare(from: pickup, to: dropoff, vehicleType: .sedan)
        }
    }
}
