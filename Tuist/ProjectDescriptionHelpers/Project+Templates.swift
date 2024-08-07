import ProjectDescription

extension Path {
	public static func relativeToModels() -> Path {
		.relativeToRoot("Projects/Models/")
	}
	public static func relativeToTCA() -> Path {
		.relativeToRoot("Projects/Packages/ComposableArchitecturePackage")
	}
}

extension Path {
	public static func relativeToClient(_ framework: String) -> Path {
		.relativeToRoot("Projects/Clients/\(framework)")
	}
}

extension Path {
	public static func relativeToHelpers(_ framework: String) -> Path {
		.relativeToRoot("Projects/Helpers/\(framework)")
	}
}

extension Path {
	public static func relativeToPackages(_ framework: String) -> Path {
		.relativeToRoot("Projects/Packages/\(framework)")
	}
}

extension Path {
	public static func relativeToFeatures(_ framework: String) -> Path {
		.relativeToRoot("Projects/Features/\(framework)")
	}
	public static func relativeToEntries(_ framework: String) -> Path {
		.relativeToRoot("Projects/Features/Entries/\(framework)")
	}
	public static func relativeToSettings(_ framework: String) -> Path {
		.relativeToRoot("Projects/Features/Settings/\(framework)")
	}
}

extension TargetDependency {
	public static var models: TargetDependency {
		.project(target: "Models", path: .relativeToModels())
	}
	public static var tca: TargetDependency {
		.project(target: "ComposableArchitecturePackage", path: .relativeToTCA())
	}
}

extension TargetDependency {
	public static func client(_ name: String) -> TargetDependency {
		.project(target: name, path: .relativeToClient(name))
	}
}

extension TargetDependency {
	public static func helper(_ name: String) -> TargetDependency {
		.project(target: name, path: .relativeToHelpers(name))
	}
}

extension TargetDependency {
	public static func package(_ name: String) -> TargetDependency {
		.project(target: name, path: .relativeToPackages(name))
	}
}

extension TargetDependency {
	public enum Group {
		case settings
		case entries
	}
	public static func feature(_ name: String, grouped: Group? = .none) -> TargetDependency {
		switch grouped {
			case .settings:
				return .project(target: name, path: .relativeToSettings(name))
			case .entries:
				return .project(target: name, path: .relativeToEntries(name))
			case .none:
				return .project(target: name, path: .relativeToFeatures(name))
		}
	}
}

extension Project {
	public static func framework(
		name: String,
		resources: ProjectDescription.ResourceFileElements? = nil,
		dependencies: [ProjectDescription.TargetDependency] = [],
		coreDataModels: [ProjectDescription.CoreDataModel] = [],
		environment: ProjectEnvironment = .caroDiario
	) -> Self {
		Project(
			name: name,
			targets: [
				.target(
					name: name,
					destinations: .iOS,
					product: .framework,
					bundleId: "\(environment.organizationName)\(name)",
					deploymentTargets: ProjectEnvironment.caroDiario.deploymentTarget,
					sources: ["Sources/**"],
					resources: resources,
					dependencies: dependencies ,
					coreDataModels: coreDataModels
				)
			]
		)
	}
}

extension Project {
	static public func feature(
		name: String,
		dependencies: [ProjectDescription.TargetDependency] = [],
		environment: ProjectEnvironment = .caroDiario
	) -> Self {
		Project(
			name: name,
			targets: [
				.target(
					name: name,
					destinations: .iOS,
					product: .framework,
					bundleId: "\(environment.organizationName)\(name)",
					deploymentTargets: ProjectEnvironment.caroDiario.deploymentTarget,
					sources: ["Sources/**"],
					dependencies: dependencies
				),
				.target(
					name: "\(name)Tests",
					destinations: .iOS,
					product: .unitTests,
					bundleId: "\(environment.organizationName)\(name)",
					deploymentTargets: ProjectEnvironment.caroDiario.deploymentTarget,
					infoPlist: .default,
					sources: ["Tests/**"],
					dependencies: [
						.target(name: name),
						.helper("TestUtils"),
						.tca
					]
				),
				.target(
					name: "\(name)Demo",
					destinations: .iOS,
					product: .app,
					bundleId: "\(environment.organizationName)\(name)Demo",
					deploymentTargets: ProjectEnvironment.caroDiario.deploymentTarget,
					infoPlist: .extendingDefault(
						with: [
							"UILaunchStoryboardName": "LaunchScreen.storyboard",
						]
					),
					sources: ["Demo/Sources/**"],
					dependencies: [
						.tca,
						.target(name: name)
					]
				),
			]
		)
	}
}
