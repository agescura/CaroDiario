import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .feature(
	name: "PDFPreviewFeature",
	dependencies: [
		.package("ComposableArchitecturePackage"),
		.helper("Views"),
		.helper("Localizables")
	]
)
