import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .feature(
	name: "CameraFeature",
	dependencies: [
		.client("AVCaptureDeviceClient"),
//		.client("FeedbackGeneratorClient"),
		.client("UIApplicationClient"),
		.helper("Localizables"),
		.helper("Styles"),
		.helper("SwiftUIHelper")
	]
)
