import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .framework(
	name: "AVAssetClient",
	dependencies: [
		.package("ComposableArchitecturePackage"),
		.models
	]
)
