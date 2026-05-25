// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "WaterReminder",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "WaterReminder",
            path: "Sources/WaterReminder"
        )
    ]
)
