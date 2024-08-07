import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .framework(
	name: "LocalAuthenticationClient",
	dependencies: [
		.package("ComposableArchitecturePackage"),
		.models
	]
)
