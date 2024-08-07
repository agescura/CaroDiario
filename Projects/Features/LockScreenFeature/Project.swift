import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .feature(
	name: "LockScreenFeature",
	dependencies: [
		.package("ComposableArchitecturePackage"),
		.client("LocalAuthenticationClient"),
		.client("UserDefaultsClient"),
//		.client("FeedbackGeneratorClient"),
		.helper("Styles"),
		.helper("Views"),
		.helper("Localizables")
	]
)
