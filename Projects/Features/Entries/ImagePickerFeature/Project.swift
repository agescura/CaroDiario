import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .feature(
	name: "ImagePickerFeature",
	dependencies: [
		.package("ComposableArchitecturePackage")
	]
)
