import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .feature(
	name: "SearchFeature",
	dependencies: [
		.package("ComposableArchitecturePackage"),
		.feature("EntriesFeature", grouped: .entries)
	]
)
