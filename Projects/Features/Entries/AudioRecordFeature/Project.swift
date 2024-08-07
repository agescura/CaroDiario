import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .feature(
	name: "AudioRecordFeature",
	dependencies: [
		.client("AVAudioRecorderClient"),
		.client("AVAudioPlayerClient"),
		.client("UIApplicationClient"),
		.client("FileClient"),
		.helper("Localizables"),
		.helper("SwiftHelper"),
		.helper("Styles"),
		.helper("Views"),
		.models
	]
)
