import Foundation
import CoreLocation

enum AppConstants {
    
    // MARK: - Map Configuration
    
    enum Map {
        static let defaultCenter = CLLocationCoordinate2D(
            latitude: 51.4816,
            longitude: -3.1791
        )
        
        static let defaultSpan = 0.05
        
        static let minDriverMovementDistance: Double = 10.0
        
        static let maxDriverMovementDistance: Double = 50.0
        
        static let driverUpdateInterval: TimeInterval = 1.5
    }
    
    // MARK: - Ride Configuration
    
    enum Ride {
        static let baseFare: Decimal = 2.50
        
        static let perKilometerRate: Decimal = 1.20
        
        static let minimumFare: Decimal = 5.00
        
        static let maxSearchTime: TimeInterval = 3.0
        
        static let assignmentDelay: TimeInterval = 2.0
        
        static let cancellationGracePeriod: TimeInterval = 60.0
    }
    
    // MARK: - Driver Simulation
    
    enum Simulation {
        
        static let numberOfDrivers = 8
        
        static let driverSpawnRadius: Double = 3000.0
        
        static let driverSpeed: Double = 15.0
        
        static let directionChangeProbability: Double = 0.1
    }
    
    // MARK: - UI Configuration
    
    enum UI {
        
        static let animationDuration: Double = 0.3
        
        static let panelCornerRadius: CGFloat = 24.0
        
        static let standardPadding: CGFloat = 16.0
        
        static let largePadding: CGFloat = 24.0
    }
}

// MARK: - Sample Data

extension AppConstants {
    
    static let driverNames = [
        "James Wilson",
        "Sarah Thompson",
        "Michael Brown",
        "Emma Davies",
        "David Evans",
        "Sophie Williams",
        "Robert Jones",
        "Emily Taylor",
        "Daniel Smith",
        "Oliver Jackson"
    ]
    
    static let cardiffLandmarks = [
        "Cardiff Central Station",
        "Cardiff Castle",
        "Principality Stadium",
        "Cardiff Bay",
        "St David's Shopping Centre",
        "Cardiff University",
        "Llandaff Cathedral",
        "Cardiff City Hall"
    ]
}
