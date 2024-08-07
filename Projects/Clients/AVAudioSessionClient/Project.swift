import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .framework(
	name: "AVAudioSessionClient",
	dependencies: [
		.package("ComposableArchitecturePackage"),
		.models
	]
)
