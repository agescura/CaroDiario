import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .feature(
	name: "AudioPickerFeature",
	dependencies: [
		.package("ComposableArchitecturePackage")
	]
)
