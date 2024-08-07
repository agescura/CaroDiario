import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .feature(
	name: "AttachmentsFeature",
	dependencies: [
		.package("ComposableArchitecturePackage"),
		.helper("Views"),
		.client("UIApplicationClient"),
		.client("AVAudioPlayerClient"),
		.client("FileClient"),
		.helper("Localizables"),
		.helper("SwiftHelper")
	]
)
