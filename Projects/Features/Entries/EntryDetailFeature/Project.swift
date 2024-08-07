import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .feature(
	name: "EntryDetailFeature",
	dependencies: [
		.models,
		.feature("AddEntryFeature", grouped: .entries),
		.feature("AttachmentsFeature", grouped: .entries),
		.client("UIApplicationClient"),
		.client("FileClient")
	]
)
