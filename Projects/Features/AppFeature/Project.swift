import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .feature(
	name: "AppFeature",
	dependencies: [
		.package("ComposableArchitecturePackage"),
		.feature("HomeFeature"),
		.feature("LockScreenFeature"),
		.feature("OnboardingFeature"),
		.feature("SplashFeature")
	]
)
