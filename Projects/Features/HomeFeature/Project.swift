import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .feature(
	name: "HomeFeature",
	dependencies: [
		.package("ComposableArchitecturePackage"),
		.feature("SearchFeature", grouped: .entries),
		.feature("EntriesFeature", grouped: .entries),
		.feature("SettingsFeature", grouped: .settings)
	]
)
