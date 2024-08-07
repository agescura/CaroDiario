import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .framework(
	name: "StoreKitClient",
	dependencies: [
		.package("ComposableArchitecturePackage")
	]
)
