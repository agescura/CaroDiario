import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .feature(
	name: "ExportFeature",
	dependencies: [
		.client("CoreDataClient"),
		.client("PDFKitClient"),
		.feature("PDFPreviewFeature", grouped: .settings),
		.client("UIApplicationClient")
	]
)
