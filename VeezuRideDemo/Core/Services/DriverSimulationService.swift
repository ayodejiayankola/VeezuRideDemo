import Foundation
import CoreLocation
import Combine

@MainActor
protocol DriverSimulationServiceable {
    var driversPublisher: AnyPublisher<[Driver], Never> { get }
    var drivers: [Driver] { get }

    func start()
    func stop()
    func addDriver(_ driver: Driver)
    func removeDriver(id: String)
    func updateDriverStatus(id: String, status: DriverStatus)
    func findNearestAvailableDriver(to coordinate: CLLocationCoordinate2D) -> Driver?
}

@MainActor
final class DriverSimulationService: DriverSimulationServiceable {
    private let driversSubject = CurrentValueSubject<[Driver], Never>([])
    private var updateTimer: Timer?
    private var driverDirections: [String: Double] = [:]

    var driversPublisher: AnyPublisher<[Driver], Never> {
        driversSubject.eraseToAnyPublisher()
    }

    var drivers: [Driver] {
        driversSubject.value
    }

    init() {
        generateInitialDrivers()
    }

    private func generateInitialDrivers() {
        let center = AppConstants.Map.defaultCenter
        let radius = AppConstants.Simulation.driverSpawnRadius

        var generatedDrivers: [Driver] = []

        for i in 0..<AppConstants.Simulation.numberOfDrivers {
            let randomCoordinate = CLLocationCoordinate2D.random(center: center, radius: radius)
            let randomName = AppConstants.driverNames.randomElement() ?? "Driver \(i + 1)"
            let vehicleType = VehicleType.allCases.randomElement() ?? .sedan
            let status: DriverStatus = Double.random(in: 0...1) > 0.7 ? .busy : .available

            let driver = Driver(
                coordinate: randomCoordinate,
                status: status,
                name: randomName,
                vehicleType: vehicleType,
                rating: Double.random(in: 4.0...5.0)
            )

            generatedDrivers.append(driver)
            
            driverDirections[driver.id] = Double.random(in: 0..<360)
        }

        driversSubject.send(generatedDrivers)
    }
    
    func start() {
        stop()

        updateTimer = Timer.scheduledTimer(
            withTimeInterval: AppConstants.Map.driverUpdateInterval,
            repeats: true
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.updateDriverPositions()
            }
        }
    }

    func stop() {
        updateTimer?.invalidate()
        updateTimer = nil
    }

    private func updateDriverPositions() {
        var updatedDrivers = driversSubject.value

        for index in updatedDrivers.indices {
            
            guard updatedDrivers[index].status == .available else { continue }

            let driver = updatedDrivers[index]

            var currentBearing = driverDirections[driver.id] ?? Double.random(in: 0..<360)

            if Double.random(in: 0...1) < AppConstants.Simulation.directionChangeProbability {
                currentBearing += Double.random(in: -45...45)
                currentBearing = currentBearing.truncatingRemainder(dividingBy: 360)
                if currentBearing < 0 { currentBearing += 360 }
            }

            let distance = AppConstants.Simulation.driverSpeed * AppConstants.Map.driverUpdateInterval

            let newCoordinate = driver.coordinate.coordinate(at: distance, bearing: currentBearing)

            let distanceFromCenter = newCoordinate.distance(to: AppConstants.Map.defaultCenter)
            if distanceFromCenter > AppConstants.Simulation.driverSpawnRadius {
                
                currentBearing = (currentBearing + 180).truncatingRemainder(dividingBy: 360)
            }

            updatedDrivers[index].coordinate = newCoordinate
            driverDirections[driver.id] = currentBearing
        }

        driversSubject.send(updatedDrivers)
    }

    func addDriver(_ driver: Driver) {
        var currentDrivers = driversSubject.value
        currentDrivers.append(driver)
        driversSubject.send(currentDrivers)
        driverDirections[driver.id] = Double.random(in: 0..<360)
    }

    func removeDriver(id: String) {
        var currentDrivers = driversSubject.value
        currentDrivers.removeAll { $0.id == id }
        driversSubject.send(currentDrivers)
        driverDirections.removeValue(forKey: id)
    }
    func updateDriverStatus(id: String, status: DriverStatus) {
        var currentDrivers = driversSubject.value
        if let index = currentDrivers.firstIndex(where: { $0.id == id }) {
            currentDrivers[index].status = status
            driversSubject.send(currentDrivers)
        }
    }

    func findNearestAvailableDriver(to coordinate: CLLocationCoordinate2D) -> Driver? {
        let availableDrivers = driversSubject.value.filter { $0.status == .available }

        return availableDrivers.min { driver1, driver2 in
            let distance1 = driver1.coordinate.distance(to: coordinate)
            let distance2 = driver2.coordinate.distance(to: coordinate)
            return distance1 < distance2
        }
    }
    
}

// MARK: - Mock Implementation

@MainActor
final class MockDriverSimulationService: DriverSimulationServiceable {
    private let driversSubject = CurrentValueSubject<[Driver], Never>([])

    var driversPublisher: AnyPublisher<[Driver], Never> {
        driversSubject.eraseToAnyPublisher()
    }

    var drivers: [Driver] {
        driversSubject.value
    }

    func start() {}
    func stop() {}

    func addDriver(_ driver: Driver) {
        var current = driversSubject.value
        current.append(driver)
        driversSubject.send(current)
    }

    func removeDriver(id: String) {
        var current = driversSubject.value
        current.removeAll { $0.id == id }
        driversSubject.send(current)
    }

    func updateDriverStatus(id: String, status: DriverStatus) {
        var current = driversSubject.value
        if let index = current.firstIndex(where: { $0.id == id }) {
            current[index].status = status
            driversSubject.send(current)
        }
    }

    func findNearestAvailableDriver(to coordinate: CLLocationCoordinate2D) -> Driver? {
        return driversSubject.value.first { $0.status == .available }
    }
}
