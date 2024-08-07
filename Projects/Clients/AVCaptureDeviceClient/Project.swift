import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .framework(
	name: "AVCaptureDeviceClient",
	dependencies: [
		.package("ComposableArchitecturePackage"),
		.models
	]
)
