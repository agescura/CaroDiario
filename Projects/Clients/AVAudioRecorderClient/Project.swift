import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .framework(
	name: "AVAudioRecorderClient",
	dependencies: [
		.package("ComposableArchitecturePackage"),
		.models
	]
)
