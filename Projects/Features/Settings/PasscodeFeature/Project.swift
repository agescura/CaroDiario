import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .feature(
	name: "PasscodeFeature",
	dependencies: [
		.client("LocalAuthenticationClient"),
		.client("UserDefaultsClient"),
		.helper("Views"),
		.helper("Localizables")
	]
)
