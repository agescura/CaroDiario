import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .feature(
	name: "SplashFeature",
	dependencies: [
		.helper("Styles"),
		.tca
	]
)
