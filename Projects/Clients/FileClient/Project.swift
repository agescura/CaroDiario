import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .framework(
	name: "FileClient",
	dependencies: [
		.package("ComposableArchitecturePackage"),
		.models,
		.helper("SwiftHelper")
	]
)
