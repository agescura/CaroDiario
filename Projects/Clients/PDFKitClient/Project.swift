import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .framework(
	name: "PDFKitClient",
	dependencies: [
		.package("ComposableArchitecturePackage"),
		.models,
		.helper("Localizables")
	]
)
