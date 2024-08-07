import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .framework(
	name: "FeedbackGeneratorClient",
	dependencies: [
		.package("ComposableArchitecturePackage")
	]
)
