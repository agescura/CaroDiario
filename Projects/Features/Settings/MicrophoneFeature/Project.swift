import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .feature(
	name: "MicrophoneFeature",
	dependencies: [
		.client("AVAudioSessionClient"),
//		.client("FeedbackGeneratorClient"),
		.client("UIApplicationClient"),
		.models,
		.helper("Localizables"),
		.helper("Styles"),
		.helper("SwiftUIHelper")
	]
)
