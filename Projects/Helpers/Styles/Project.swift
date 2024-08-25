import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .framework(
	name: "Styles",
	resources: ["Resources/**"],
	dependencies: [
		.helper("SwiftUIHelper")
	]
)
