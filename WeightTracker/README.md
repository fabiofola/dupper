# WeightTracker

An iOS app built with SwiftUI that helps you log your weight, visualize progress, and keep track of long-term trends.

## Features

- Quick logging of weight measurements with optional notes.
- Automatic replacement of entries logged for the same day.
- Overview cards highlighting latest weight, weekly change, 30-day average, and longest logging streak.
- Interactive chart (iOS 16+) to review historical measurements.
- Persistent storage backed by a lightweight JSON file so that data survives app relaunches.
- Unit and UI test targets ready for expansion.

## Requirements

- Xcode 15 or later
- iOS 16.0 or later deployment target

## Getting Started

1. Open `WeightTracker/WeightTracker.xcodeproj` in Xcode.
2. Select the **WeightTracker** scheme and an iOS simulator or device running iOS 16 or newer.
3. Build and run.

To execute the bundled tests, choose the **Product ▸ Test** menu in Xcode or run `xcodebuild test -scheme WeightTracker -destination 'platform=iOS Simulator,name=iPhone 15'` from Terminal on macOS.
