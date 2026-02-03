// swift-tools-version: 6.2

import PackageDescription

let package = Package(
  name: "CaroDiario",
  platforms: [.iOS(.v26)],
  products: [
    .library(
      name: "CaroDiario",
      targets: ["CaroDiario"]
    ),
  ],
  targets: [
    .target(
      name: "CaroDiario"
    ),
    .testTarget(
      name: "CaroDiarioTests",
      dependencies: ["CaroDiario"]
    ),
  ]
)
