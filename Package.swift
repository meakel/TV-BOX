// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MacTVBox",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "MacTVBox",
            targets: ["MacTVBox"]
        )
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "MacTVBox",
            dependencies: [],
            path: "Sources/MacTVBox",
            resources: []
        )
    ]
)
