import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .feature(
	name: "AboutFeature",
	dependencies: [
		.client("UIApplicationClient"),
		.client("UserDefaultsClient"),
		.package("ComposableArchitecturePackage"),
		.helper("Localizables"),
		.helper("SwiftUIHelper"),
		.helper("Views")
	]
)
