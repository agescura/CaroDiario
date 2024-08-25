import ProjectDescription
import ProjectDescriptionHelpers

let name = "App"

let project = Project(
	name: name,
	targets: [
		.target(
			name: name,
			destinations: .iOS,
			product: .app,
			bundleId: "\(ProjectEnvironment.caroDiario.organizationName)App",
			deploymentTargets: ProjectEnvironment.caroDiario.deploymentTarget,
			infoPlist: .extendingDefault(
				with: [
					"UILaunchStoryboardName": "LaunchScreen.storyboard",
					"NSCameraUsageDescription": "Camera Usage Description",
					"NSMicrophoneUsageDescription": "Microphone Usage Description",
					"NSFaceIDUsageDescription": "Face ID Usage Description",
					"CFBundleDisplayName": "Caro Diario",
					"CFBundleIcons": [
						"CFBundleAlternateIcons": [
							"AppIcon-2": [
								"CFBundleIconFiles": ["Icon-2"],
								"UIPrerenderedIcon": false
							]
						],
						"CFBundlePrimaryIcon": [
							"CFBundleIconFiles": ["Icon-1"],
							"UIPrerenderedIcon": false
						]
					]
				]
			),
			sources: ["Sources/**"],
			resources: ["Resources/**"],
			entitlements: Entitlements.file(path: "Entitlements/App.entitlements"),
			dependencies: [
				.feature("AppFeature")
			]
		),
		.target(
			name: "\(name)Tests",
			destinations: .iOS,
			product: .unitTests,
			bundleId: "\(ProjectEnvironment.caroDiario.organizationName)Tests",
			deploymentTargets: ProjectEnvironment.caroDiario.deploymentTarget,
			infoPlist: .default,
			sources: ["Tests/**"],
			resources: [],
			dependencies: [.target(name: "App")]
		)
	]
)
