import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .framework(
	name: "TestUtils",
	dependencies: [
		.xctest,
		.external(name: "SnapshotTesting")
	]
)
