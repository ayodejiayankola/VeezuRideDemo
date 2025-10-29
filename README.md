# VeezuRideDemo

## Project Architecture

The project follows a clean, feature-based MVVM architecture designed for scalability, testability, and clarity. It organizes the codebase into three main layers — **Core**, **Features**, and **Shared** — with an additional **Tests** group for validation.

---

##  Project Structure

```
VeezuRideDemo/
├── Core/
│   ├── Constants/
│   │   └── AppConstants.swift              # App-wide constants and simulation settings
│   ├── Models/
│   │   ├── Driver.swift                    # Driver model with ID, vehicle, and status
│   │   └── RideRequest.swift               # Ride request, states, and assigned driver data
│   ├── Services/
│   │   ├── DriverSimulationService.swift   # Simulates drivers' positions and availability
│   │   ├── FareCalculationService.swift    # Calculates estimated fare based on distance
│   │   ├── LocationService.swift           # Manages user location and updates
│   │   └── RideBookingService.swift        # Handles booking state (searching → assigned → cancel)
│   └── AppContainer.swift                  # Dependency injection container
│
├── Features/
│   ├── Booking/
│   │   ├── BookingViewModel.swift          # Manages booking logic, fare updates, and state
│   │   └── BookingPanelView.swift          # Bottom booking panel with ride request UI
│   └── Map/
│       ├── MapViewModel.swift              # Controls map region, drivers, and destinations
│       ├── MapView.swift                   # Renders live map with annotations
│       └── RideHailingScreen.swift         # Combines map and booking panel in one view
│
├── Shared/
│   ├── Components/
│   │   └── DriverAnnotationView.swift      # Custom annotation for drivers (status colors + pulse)
│   ├── Extensions/
│   │   └── CLLocationCoordinate2D+Extensions.swift  # Coordinate math helpers (distance, bearing)
│   └── Assets/                             # Accent color, app icon, and asset catalog
│
├── VeezuRideDemoApp.swift                  # SwiftUI entry point (@main)
│
└── VeezuRideDemoTests/
    ├── CLLocationCoordinate2DExtensionsTests.swift  # Verifies distance/bearing logic
    └── FareCalculationServiceTests.swift            # Tests fare calculation and multipliers
```

---

##  Architecture Highlights

| Layer | Description |
|-------|-------------|
| **Core** | Foundation layer — includes all domain models, constants, and services. These are independent and testable. |
| **Features** | Contains feature-specific UI and logic. Each subfolder is self-contained (View + ViewModel). |
| **Shared** | Common components and utilities reused across multiple features. |
| **Tests** | Unit tests for validating logic and ensuring code reliability. |

---

## Design Rationale

1. **Feature-based grouping** keeps modules independent.
2. **MVVM pattern** ensures clear separation between logic and UI.
3. **Combine** provides reactive updates — location and booking states update automatically.
4. **AppContainer** centralizes dependency management for clean initialization.
5. **SwiftUI-first design** delivers fast iteration, live previews, and lightweight code.

---

## Technical Stack

| Technology | Purpose |
|------------|---------|
| **SwiftUI** | Declarative and reactive UI framework |
| **Combine** | Data binding and state updates |
| **CoreLocation** | Real-time user location updates |
| **MapKit** | Map rendering and annotation control |
| **Async/Await** | Smooth asynchronous operations |
| **XCTest** | Unit testing for reliability and correctness |

---

##  Summary

This structure mirrors modern iOS production patterns, focusing on clarity, modularity, and ease of extension. Each module handles one concern, making the codebase easy to test and scale.

---

##  Design & Demo

A few visuals to showcase the app's interface and simulation in action.

### Mock up 
<img width="1536" height="1024" alt="Prototype" src="https://github.com/user-attachments/assets/3a331b33-44d8-4c77-a253-b3cc894191b8" />


### Screenshots



| Light Mode | Dark Mode |
|------------|-----------|
| <img width="1179" height="2556" alt="Simulator Screenshot - iPhone 16 - 2025-10-29 at 15 48 12" src="https://github.com/user-attachments/assets/7161d3ce-2c35-4c43-86a9-329001ce4e56" /> | <img width="1179" height="2556" alt="Simulator Screenshot - iPhone 16 - 2025-10-29 at 15 47 59" src="https://github.com/user-attachments/assets/88899cd7-62fa-4915-91fa-dacbe1bb0886" /> |

*Interactive map simulation showing available drivers with real-time location updates and booking panel*

---

### Booking Flow States

| Request Ride State | Searching State | Driver Assigned State |
|:------------------:|:---------------:|:----------------------:|
| <img width="1179" height="2556" alt="image" src="https://github.com/user-attachments/assets/8a153aed-fae9-4ff2-8970-f291e778969d" /> | <img width="1179" height="2556" alt="image" src="https://github.com/user-attachments/assets/75e9ed70-2a13-421f-9adb-463536c910fe" /> |<img width="1179" height="2556" alt="image" src="https://github.com/user-attachments/assets/a6f41597-3e10-41be-a032-1d21a7ee8d43" />|





---

## Setup & Installation

### Requirements
- **Xcode** 15 or later  
- **iOS Deployment Target:** 17.0+  
- **Swift:** 5.9+

##  Getting Started

### Steps

1. **Clone Repository**
   ```bash
   git clone <https://github.com/ayodejiayankola/VeezuRideDemo>
   cd VeezuRideDemo
   ```

2. **Open Project**
   ```bash
   open VeezuRideDemo.xcodeproj
   ```

3. **Add Location Permission to Info.plist**
   ```xml
   <key>NSLocationWhenInUseUsageDescription</key>
   <string>We need your location to show nearby drivers and provide pickup services.</string>
   ```

4. **Build and Run**
   - Choose an iPhone simulator (iOS 17+)
   - Press `Cmd + R`
   - Grant location permissions when prompted

