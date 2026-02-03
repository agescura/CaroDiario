// swift-tools-version: 6.2

import PackageDescription

let package = Package(
  name: "CaroDiario",
  defaultLocalization: "en",
  platforms: [.iOS(.v26)],
  products: [
    .library(
      name: "AboutFeature",
      targets: ["AboutFeature"]
    ),
    .library(
      name: "ApplicationClient",
      targets: ["ApplicationClient"]
    ),
    .library(
      name: "Localizables",
      targets: ["Localizables"]
    ),
    .library(
      name: "Models",
      targets: ["Models"]
    ),
    .library(
      name: "DesignSystem",
      targets: ["DesignSystem"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/sqlite-data", exact: "1.5.1"),
    .package(url: "https://github.com/pointfreeco/swift-dependencies", exact: "1.10.1"),
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", exact: "1.23.1"),
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", exact: "1.18.9"),
  ],
  targets: [
    .target(
      name: "AboutFeature",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "ApplicationClient",
        "DesignSystem",
        "Localizables"
      ]
    ),
    .testTarget(
      name: "AboutFeatureTests",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
        "AboutFeature",
      ]
    ),
    .target(
      name: "ApplicationClient",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "DependenciesMacros", package: "swift-dependencies")
      ]
    ),
    .target(
      name: "Localizables",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "Models"
      ],
      resources: [.process("Resources")]
    ),
    .target(
      name: "Models",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ]
    ),
    .target(
      name: "DesignSystem",
      dependencies: [],
      resources: [.process("Resources")]
    ),
  ]
)
