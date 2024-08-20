// swift-tools-version: 5.10
import PackageDescription

#if TUIST
import ProjectDescription

let packageSettings = PackageSettings(
	productTypes: [
		"ComposableArchitecture": .framework,
		"SnapshotTesting": .framework,
		"Dependencies": .framework,
		"Clocks": .framework,
		"ConcurrencyExtras": .framework,
		"CombineSchedulers": .framework,
		"IdentifiedCollections": .framework,
		"OrderedCollections": .framework,
		"_CollectionsUtilities": .framework,
		"DependenciesMacros": .framework,
		"SwiftUINavigationCore": .framework,
		"Perception": .framework,
		"CasePaths": .framework,
		"CustomDump": .framework,
		"XCTestDynamicOverlay": .framework,
		"IssueReporting": .framework,
		"InternalCollectionsUtilities": .framework
	]
)
#endif

let package = Package(
	name: "CaroDiario",
	dependencies: [
		.package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.12.1"),
		.package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.17.3"),
	]
)
