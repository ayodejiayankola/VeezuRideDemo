import SwiftUI
import MapKit

struct DriverAnnotationView: View {
    let driver: Driver
    let isAssigned: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(backgroundGradient)
                .frame(width: 40, height: 40)
                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)

            Image(systemName: driver.vehicleType.icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)

            if isAssigned {
                Circle()
                    .stroke(Color.green, lineWidth: 2)
                    .frame(width: 40, height: 40)
                    .scaleEffect(pulseScale)
            }
        }
    }

    // MARK: - Computed Properties

    private var backgroundGradient: LinearGradient {
        if isAssigned {
            return LinearGradient(
                colors: [.green, .green.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else if driver.status == .available {
            return LinearGradient(
                colors: [.blue, .blue.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [.gray, .gray.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    @State private var pulseScale: CGFloat = 1.0

    private var pulseAnimation: Animation {
        Animation.easeInOut(duration: 1.5)
            .repeatForever(autoreverses: true)
    }

    // MARK: - Lifecycle
    init(driver: Driver, isAssigned: Bool = false) {
        self.driver = driver
        self.isAssigned = isAssigned

        if isAssigned {
            _pulseScale = State(initialValue: 1.2)
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        DriverAnnotationView(
            driver: Driver(
                coordinate: CLLocationCoordinate2D(latitude: 51.5, longitude: -0.1),
                status: .available,
                name: "John",
                vehicleType: .sedan
            )
        )

        DriverAnnotationView(
            driver: Driver(
                coordinate: CLLocationCoordinate2D(latitude: 51.5, longitude: -0.1),
                status: .available,
                name: "Sarah",
                vehicleType: .suv
            ),
            isAssigned: true
        )

        DriverAnnotationView(
            driver: Driver(
                coordinate: CLLocationCoordinate2D(latitude: 51.5, longitude: -0.1),
                status: .busy,
                name: "Mike",
                vehicleType: .luxury
            )
        )
    }
    .padding()
}
