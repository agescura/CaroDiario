import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .feature(
	name: "LanguageFeature",
	dependencies: [
		.package("ComposableArchitecturePackage"),
		.models,
		.client("UserDefaultsClient"),
		.helper("Localizables"),
		.helper("SwiftUIHelper"),
		.helper("Styles")
	]
)
