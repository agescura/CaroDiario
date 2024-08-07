import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .feature(
	name: "AddEntryFeature",
	dependencies: [
		.feature("AttachmentsFeature", grouped: .entries),
		.feature("AudioPickerFeature", grouped: .entries),
		.feature("AudioRecordFeature", grouped: .entries),
		.feature("ImagePickerFeature", grouped: .entries),
		.models,
		.client("AVAssetClient"),
		.client("AVAudioPlayerClient"),
		.client("AVAudioRecorderClient"),
		.client("AVAudioSessionClient"),
		.client("AVCaptureDeviceClient"),
		.client("FileClient"),
		.client("UIApplicationClient")
	]
)
