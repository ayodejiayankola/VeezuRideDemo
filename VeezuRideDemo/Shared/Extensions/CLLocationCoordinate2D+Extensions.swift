import CoreLocation
import Foundation

extension CLLocationCoordinate2D {
    
    func isEqual(to coordinate: CLLocationCoordinate2D) -> Bool {
        return latitude == coordinate.latitude && longitude == coordinate.longitude
    }
    
    func distance(to coordinate: CLLocationCoordinate2D) -> CLLocationDistance {
        let from = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let to = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return from.distance(from: to)
    }
    
    func bearing(to coordinate: CLLocationCoordinate2D) -> Double {
        let lat1 = self.latitude.toRadians()
        let lon1 = self.longitude.toRadians()
        let lat2 = coordinate.latitude.toRadians()
        let lon2 = coordinate.longitude.toRadians()
        
        let dLon = lon2 - lon1
        
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        
        let bearing = atan2(y, x).toDegrees()
        return (bearing + 360).truncatingRemainder(dividingBy: 360)
    }
    
    func coordinate(at distance: CLLocationDistance, bearing: Double) -> CLLocationCoordinate2D {
        let earthRadius: Double = 6371000.0
        
        let lat1 = self.latitude.toRadians()
        let lon1 = self.longitude.toRadians()
        let brng = bearing.toRadians()
        
        let lat2 = asin(sin(lat1) * cos(distance / earthRadius) +
                        cos(lat1) * sin(distance / earthRadius) * cos(brng))
        
        let lon2 = lon1 + atan2(sin(brng) * sin(distance / earthRadius) * cos(lat1),
                                cos(distance / earthRadius) - sin(lat1) * sin(lat2))
        
        return CLLocationCoordinate2D(
            latitude: lat2.toDegrees(),
            longitude: lon2.toDegrees()
        )
    }
    
    static func random(center: CLLocationCoordinate2D, radius: CLLocationDistance) -> CLLocationCoordinate2D {
        let randomDistance = Double.random(in: 0...radius)
        let randomBearing = Double.random(in: 0..<360)
        return center.coordinate(at: randomDistance, bearing: randomBearing)
    }
    
    var isValid: Bool {
        return latitude >= -90 && latitude <= 90 &&
        longitude >= -180 && longitude <= 180
    }
}

// MARK: - Double Extensions for Angle Conversion

extension Double {
    func toRadians() -> Double {
        return self * .pi / 180.0
    }
    
    func toDegrees() -> Double {
        return self * 180.0 / .pi
    }
}
