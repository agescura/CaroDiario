import ProjectDescription

public struct ProjectEnvironment {
		public let name: String
		public let organizationName: String
		public let deploymentTarget: DeploymentTargets
		public let destinations: Destinations
		public let baseSetting: SettingsDictionary
}

extension ProjectEnvironment {
	static public var caroDiario: Self {
		ProjectEnvironment(
			name: "Caro Diario",
			organizationName: "com.albertgil.carodiario",
			deploymentTarget: .iOS("17.0"),
			destinations: Set([.iPhone]),
			baseSetting: [:]
		)
	}
}

