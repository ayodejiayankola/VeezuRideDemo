import Foundation
import CoreLocation
import MapKit

struct Driver: Identifiable, Equatable {
    let id: String
    var coordinate: CLLocationCoordinate2D
    var status: DriverStatus
    var name: String
    var vehicleType: VehicleType
    var rating: Double
    var eta: TimeInterval?

    init(
        id: String = UUID().uuidString,
        coordinate: CLLocationCoordinate2D,
        status: DriverStatus = .available,
        name: String,
        vehicleType: VehicleType = .sedan,
        rating: Double = 4.5
    ) {
        self.id = id
        self.coordinate = coordinate
        self.status = status
        self.name = name
        self.vehicleType = vehicleType
        self.rating = rating
        self.eta = nil
    }
    
    static func == (lhs: Driver, rhs: Driver) -> Bool {
        lhs.id == rhs.id
    }
}

enum DriverStatus: String, Codable {
    case available
    case busy
    case offline

    var displayText: String {
        switch self {
        case .available: return "Available"
        case .busy: return "Busy"
        case .offline: return "Offline"
        }
    }
}

enum VehicleType: String, Codable, CaseIterable {
    case sedan
    case suv
    case luxury
    case electric

    var displayName: String {
        switch self {
        case .sedan: return "Sedan"
        case .suv: return "SUV"
        case .luxury: return "Luxury"
        case .electric: return "Electric"
        }
    }

    var icon: String {
        switch self {
        case .sedan: return "car.fill"
        case .suv: return "suv.side.fill"
        case .luxury: return "car.fill"
        case .electric: return "bolt.car.fill"
        }
    }

    var baseFareMultiplier: Double {
        switch self {
        case .sedan: return 1.0
        case .suv: return 1.3
        case .luxury: return 1.8
        case .electric: return 1.1
        }
    }
}

// MARK: - MapKit Conformance

extension Driver {
    
    func toAnnotation() -> DriverAnnotation {
        let annotation = DriverAnnotation(driver: self)
        return annotation
    }
}

class DriverAnnotation: NSObject, MKAnnotation {
    let driver: Driver

    @objc dynamic var coordinate: CLLocationCoordinate2D {
        didSet {
    
        }
    }

    var title: String? {
        driver.name
    }

    var subtitle: String? {
        driver.status.displayText
    }

    init(driver: Driver) {
        self.driver = driver
        self.coordinate = driver.coordinate
        super.init()
    }

    func update(with coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}
