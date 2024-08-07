import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .framework(
	name: "Views",
	dependencies: [
		.helper("SwiftUIHelper"),
		.helper("Styles")
	]
)
