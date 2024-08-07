import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .feature(
	name: "SettingsFeature",
	dependencies: [
		.package("ComposableArchitecturePackage"),
		.feature("AboutFeature", grouped: .settings),
		.feature("AgreementsFeature", grouped: .settings),
		.feature("AppearanceFeature", grouped: .settings),
		.feature("CameraFeature", grouped: .settings),
		.feature("ExportFeature", grouped: .settings),
		.feature("LanguageFeature", grouped: .settings),
		.feature("MicrophoneFeature", grouped: .settings),
		.feature("PasscodeFeature", grouped: .settings),
		.feature("EntriesFeature", grouped: .entries),
		.client("StoreKitClient"),
		.client("LocalAuthenticationClient"),
		.models
	]
)
