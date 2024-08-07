import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .framework(
	name: "UserDefaultsClient",
	dependencies: [
		.package("ComposableArchitecturePackage"),
		.models
	]
)
