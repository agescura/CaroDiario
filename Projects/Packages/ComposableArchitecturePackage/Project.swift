import ProjectDescription

import ProjectDescriptionHelpers

let project: Project = .framework(
	name: "ComposableArchitecturePackage",
	dependencies: [
		.external(name: "ComposableArchitecture")
	]
)
