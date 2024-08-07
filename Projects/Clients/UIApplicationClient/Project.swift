import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .framework(
	name: "UIApplicationClient",
	dependencies: [
		.models,
		.package("ComposableArchitecturePackage")
	]
)
