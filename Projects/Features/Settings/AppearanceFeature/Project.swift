import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .feature(
	name: "AppearanceFeature",
	resources: ["Resources/**"],
	dependencies: [
		.package("ComposableArchitecturePackage"),
		.feature("EntriesFeature", grouped: .entries),
//		.client("FeedbackGeneratorClient")
	]
)
