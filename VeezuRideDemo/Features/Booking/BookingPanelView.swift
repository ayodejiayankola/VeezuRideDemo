import SwiftUI

struct BookingPanelView: View {
    @ObservedObject var viewModel: BookingViewModel
    @State private var searchAnimationID = UUID()

    var body: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 8)
                .padding(.bottom, 16)

            Group {
                switch viewModel.bookingState {
                case .idle:
                    idleStateView
                case .searching:
                    searchingStateView
                        .id(searchAnimationID)
                case .assigned:
                    assignedStateView
                default:
                    idleStateView
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.bookingState)
            .onChange(of: viewModel.bookingState) { oldValue, newValue in
                if newValue == .searching {
                    searchAnimationID = UUID()
                }
            }
        }
        .padding(.horizontal, AppConstants.UI.standardPadding)
        .padding(.bottom, AppConstants.UI.largePadding)
        .background(
            RoundedRectangle(cornerRadius: AppConstants.UI.panelCornerRadius)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.15), radius: 20, y: -5)
        )
    }

    // MARK: - Idle State
    private var idleStateView: some View {
        VStack(spacing: 16) {
            VStack(spacing: 12) {
                LocationRow(
                    icon: "location.fill",
                    title: "Pickup",
                    subtitle: viewModel.pickupAddress,
                    color: .blue
                )

                Divider()

                LocationRow(
                    icon: "mappin.circle.fill",
                    title: "Destination",
                    subtitle: viewModel.dropoffAddress.isEmpty ? "Where to?" : viewModel.dropoffAddress,
                    color: .red
                )
            }

            if viewModel.estimatedFare > 0 {
                HStack {
                    Text("Estimated fare")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text("£\(viewModel.estimatedFare as NSDecimalNumber, formatter: currencyFormatter)")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }

            Button {
                Task {
                    await viewModel.requestRide()
                }
            } label: {
                HStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "car.fill")
                        Text("Request Ride")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.canRequestRide ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(!viewModel.canRequestRide || viewModel.isLoading)

            if let error = viewModel.errorMessage {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)
                .transition(.opacity.combined(with: .scale))
            }
        }
    }

    // MARK: - Searching State
    private var searchingStateView: some View {
        VStack(spacing: 20) {
            ZStack {
                ForEach(0..<3) { index in
                    Circle()
                        .stroke(Color.blue, lineWidth: 2)
                        .frame(width: 40, height: 40)
                        .scaleEffect(searchingScale)
                        .opacity(searchingOpacity)
                        .animation(
                            Animation.easeOut(duration: 1.5)
                                .repeatForever(autoreverses: false)
                                .delay(Double(index) * 0.3),
                            value: searchingScale
                        )
                }

                Image(systemName: "magnifyingglass")
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
            }
            .frame(height: 80)
            .onAppear {
                searchingScale = 1.0
                searchingOpacity = 1.0
                
                withAnimation {
                    searchingScale = 2.5
                    searchingOpacity = 0
                }
            }

            VStack(spacing: 8) {
                Text("Searching for drivers...")
                    .font(.headline)

                Text("Finding the best driver for you")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Button {
                Task {
                    await viewModel.cancelRide()
                }
            } label: {
                Text("Cancel")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(12)
            }
        }
        .padding(.vertical)
    }

    @State private var searchingScale: CGFloat = 1.0
    @State private var searchingOpacity: Double = 1.0

    // MARK: - Assigned State
    private var assignedStateView: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.green)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Driver assigned")
                        .font(.headline)

                    if let driverName = viewModel.assignedDriverName {
                        Text(driverName)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                if let eta = viewModel.assignedDriverETA {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(eta)
                            .font(.title3)
                            .fontWeight(.bold)

                        Text("away")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color.green.opacity(0.1))
            .cornerRadius(12)

            VStack(spacing: 8) {
                HStack {
                    Text("Pickup")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(viewModel.pickupAddress)
                        .font(.caption)
                }

                HStack {
                    Text("Destination")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(viewModel.dropoffAddress)
                        .font(.caption)
                }

                Divider()

                HStack {
                    Text("Fare")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Spacer()
                    Text("£\(viewModel.estimatedFare as NSDecimalNumber, formatter: currencyFormatter)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
            }
            .padding()
            .background(Color.secondary.opacity(0.05))
            .cornerRadius(12)

            if viewModel.canCancelRide {
                Button {
                    Task {
                        await viewModel.cancelRide()
                    }
                } label: {
                    Text("Cancel Ride")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(12)
                }
            }
        }
    }

    // MARK: - Currency Formatter
    private var currencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }
}

// MARK: - Location Row Component
struct LocationRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }

            Spacer()
        }
    }
}

// MARK: - Preview
#Preview {
    @MainActor func makeView() -> some View {
        let container = AppContainer.mock()
        let viewModel = BookingViewModel(
            rideBookingService: container.rideBookingService,
            fareCalculationService: container.fareCalculationService,
            locationService: container.locationService
        )

        return VStack {
            Spacer()
            BookingPanelView(viewModel: viewModel)
        }
    }

    return makeView()
}
