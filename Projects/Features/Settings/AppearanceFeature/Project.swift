import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .feature(
	name: "AppearanceFeature",
	dependencies: [
		.package("ComposableArchitecturePackage"),
		.feature("EntriesFeature", grouped: .entries),
//		.client("FeedbackGeneratorClient")
	]
)
