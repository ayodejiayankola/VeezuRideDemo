import XCTest
import CoreLocation
@testable import VeezuRideDemo

final class CLLocationCoordinate2DExtensionsTests: XCTestCase {

    // MARK: - Distance Tests

    func testDistance_SameCoordinate_ReturnsZero() {
        
        let coordinate = CLLocationCoordinate2D(latitude: 51.4816, longitude: -3.1791)

        let distance = coordinate.distance(to: coordinate)

        XCTAssertEqual(distance, 0, accuracy: 1.0)
    }

    func testDistance_KnownDistance_CalculatesCorrectly() {
        let start = CLLocationCoordinate2D(latitude: 51.4816, longitude: -3.1791)
        let end = CLLocationCoordinate2D(latitude: 51.4900, longitude: -3.1791)

        let distance = start.distance(to: end)

        XCTAssertGreaterThan(distance, 900)
        XCTAssertLessThan(distance, 1100)
    }

    // MARK: - Bearing Tests

    func testBearing_NorthDirection_ReturnsZero() {
        let start = CLLocationCoordinate2D(latitude: 51.4816, longitude: -3.1791)
        let north = CLLocationCoordinate2D(latitude: 51.4916, longitude: -3.1791)

        let bearing = start.bearing(to: north)

        XCTAssertLessThan(bearing, 5, "Bearing directly north should be close to 0°")
    }

    func testBearing_EastDirection_Returns90() {
        let start = CLLocationCoordinate2D(latitude: 51.4816, longitude: -3.1791)
        let east = CLLocationCoordinate2D(latitude: 51.4816, longitude: -3.1691)

        let bearing = start.bearing(to: east)

        XCTAssertGreaterThan(bearing, 85, "Bearing directly east should be close to 90°")
        XCTAssertLessThan(bearing, 95)
    }

    // MARK: - Coordinate Movement Tests

    func testCoordinateAtDistance_MovesCorrectly() {
    
        let start = CLLocationCoordinate2D(latitude: 51.4816, longitude: -3.1791)
        let distance: CLLocationDistance = 1000
        let bearing: Double = 0

        let result = start.coordinate(at: distance, bearing: bearing)

        XCTAssertGreaterThan(result.latitude, start.latitude, "Moving north should increase latitude")
        XCTAssertEqual(result.longitude, start.longitude, accuracy: 0.001, "Moving north shouldn't change longitude much")
    }

    func testCoordinateAtDistance_RoundTrip_ReturnsToOrigin() {
        
        let start = CLLocationCoordinate2D(latitude: 51.4816, longitude: -3.1791)
        let distance: CLLocationDistance = 1000

        let north = start.coordinate(at: distance, bearing: 0)
        let backToStart = north.coordinate(at: distance, bearing: 180)
 
        XCTAssertEqual(backToStart.latitude, start.latitude, accuracy: 0.001)
        XCTAssertEqual(backToStart.longitude, start.longitude, accuracy: 0.001)
    }

    // MARK: - Random Coordinate Tests

    func testRandomCoordinate_StaysWithinRadius() {
        let center = CLLocationCoordinate2D(latitude: 51.4816, longitude: -3.1791)
        let radius: CLLocationDistance = 1000

        for _ in 0..<10 {
            let random = CLLocationCoordinate2D.random(center: center, radius: radius)
            let distance = center.distance(to: random)

            XCTAssertLessThanOrEqual(distance, radius, "Random coordinate should be within radius")
            XCTAssertGreaterThanOrEqual(distance, 0)
        }
    }

    // MARK: - Validation Tests

    func testIsValid_ValidCoordinate_ReturnsTrue() {
        let valid = CLLocationCoordinate2D(latitude: 51.4816, longitude: -3.1791)

        XCTAssertTrue(valid.isValid)
    }

    func testIsValid_InvalidLatitude_ReturnsFalse() {
 
        let invalidLat = CLLocationCoordinate2D(latitude: 91.0, longitude: -3.1791)

        XCTAssertFalse(invalidLat.isValid)
    }

    func testIsValid_InvalidLongitude_ReturnsFalse() {
  
        let invalidLon = CLLocationCoordinate2D(latitude: 51.4816, longitude: 181.0)

        XCTAssertFalse(invalidLon.isValid)
    }

    // MARK: - Equality Tests

    func testIsEqual_SameCoordinates_ReturnsTrue() {
        
        let coord1 = CLLocationCoordinate2D(latitude: 51.4816, longitude: -3.1791)
        let coord2 = CLLocationCoordinate2D(latitude: 51.4816, longitude: -3.1791)

        XCTAssertTrue(coord1.isEqual(to: coord2))
    }

    func testIsEqual_DifferentCoordinates_ReturnsFalse() {
        
        let coord1 = CLLocationCoordinate2D(latitude: 51.4816, longitude: -3.1791)
        let coord2 = CLLocationCoordinate2D(latitude: 51.4817, longitude: -3.1791)

        XCTAssertFalse(coord1.isEqual(to: coord2))
    }
}
