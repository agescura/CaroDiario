import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .feature(
	name: "AgreementsFeature",
	dependencies: [
		.package("ComposableArchitecturePackage"),
		.client("UIApplicationClient"),
		.helper("Views"),
		.helper("Localizables")
	]
)
