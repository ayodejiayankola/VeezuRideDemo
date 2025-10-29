import Foundation
import CoreLocation

struct RideRequest: Identifiable, Equatable {
    let id: String
    let pickupLocation: CLLocationCoordinate2D
    let dropoffLocation: CLLocationCoordinate2D
    let pickupAddress: String
    let dropoffAddress: String
    var state: RideState
    var estimatedFare: Decimal
    var assignedDriver: Driver?
    let requestTime: Date
    var acceptedTime: Date?
    var completedTime: Date?

    init(
        id: String = UUID().uuidString,
        pickupLocation: CLLocationCoordinate2D,
        dropoffLocation: CLLocationCoordinate2D,
        pickupAddress: String,
        dropoffAddress: String,
        state: RideState = .searching,
        estimatedFare: Decimal,
        assignedDriver: Driver? = nil
    ) {
        self.id = id
        self.pickupLocation = pickupLocation
        self.dropoffLocation = dropoffLocation
        self.pickupAddress = pickupAddress
        self.dropoffAddress = dropoffAddress
        self.state = state
        self.estimatedFare = estimatedFare
        self.assignedDriver = assignedDriver
        self.requestTime = Date()
        self.acceptedTime = nil
        self.completedTime = nil
    }

    var duration: TimeInterval? {
        guard let completedTime = completedTime else { return nil }
        return completedTime.timeIntervalSince(requestTime)
    }

    static func == (lhs: RideRequest, rhs: RideRequest) -> Bool {
        lhs.id == rhs.id
    }
}

enum RideState: String, Codable {
    case idle
    case searching
    case assigned
    case driverEnRoute
    case arrived
    case inProgress
    case completed
    case cancelled

    var displayText: String {
        switch self {
        case .idle: return "Ready to book"
        case .searching: return "Searching for drivers..."
        case .assigned: return "Driver assigned"
        case .driverEnRoute: return "Driver en route"
        case .arrived: return "Driver arrived"
        case .inProgress: return "Ride in progress"
        case .completed: return "Ride completed"
        case .cancelled: return "Ride cancelled"
        }
    }

    var icon: String {
        switch self {
        case .idle: return "location.fill"
        case .searching: return "magnifyingglass"
        case .assigned: return "checkmark.circle.fill"
        case .driverEnRoute: return "car.fill"
        case .arrived: return "mappin.circle.fill"
        case .inProgress: return "location.north.line.fill"
        case .completed: return "checkmark.seal.fill"
        case .cancelled: return "xmark.circle.fill"
        }
    }

    var canCancel: Bool {
        switch self {
        case .searching, .assigned, .driverEnRoute:
            return true
        default:
            return false
        }
    }

    var isActive: Bool {
        switch self {
        case .searching, .assigned, .driverEnRoute, .arrived, .inProgress:
            return true
        default:
            return false
        }
    }
}
