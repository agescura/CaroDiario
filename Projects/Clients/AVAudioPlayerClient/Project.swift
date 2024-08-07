import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .framework(
	name: "AVAudioPlayerClient",
	dependencies: [
		.package("ComposableArchitecturePackage")
	]
)
