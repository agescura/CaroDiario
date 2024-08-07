import ProjectDescription
import ProjectDescriptionHelpers

let project: Project = .feature(
	name: "EntriesFeature",
	dependencies: [
		.feature("AddEntryFeature", grouped: .entries),
		.feature("EntryDetailFeature", grouped: .entries),
		.client("CoreDataClient"),
		.client("UserDefaultsClient")
	]
)
