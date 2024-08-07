import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .feature(
	name: "OnboardingFeature",
	dependencies: [
		.package("ComposableArchitecturePackage"),
		.feature("EntriesFeature", grouped: .entries),
//		.client("FeedbackGeneratorClient")
	]
)
