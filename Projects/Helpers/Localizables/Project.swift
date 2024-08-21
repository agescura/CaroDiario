import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .framework(
	name: "Localizables",
	resources: ["Resources/**"],
	dependencies: [
		.package("ComposableArchitecturePackage"),
		.models
	]
)
