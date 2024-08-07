import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .framework(
	name: "CoreDataClient",
	dependencies: [
		.package("ComposableArchitecturePackage"),
		.models
	],
	coreDataModels: [
		.coreDataModel("./CoreDataModel.xcdatamodeld")
	]
)
