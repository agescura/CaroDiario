import SnapshotTesting

public func assertSnapshot<Value: View>(
	_ value: @autoclosure () throws -> Value,
	named name: String? = nil,
	record recording: Bool = false,
	timeout: TimeInterval = 5,
	file: StaticString = #file,
	testName: String = #function,
	line: UInt = #line
) {
	assertSnapshot(
		of: try value(),
		as: .image(perceptualPrecision: 0.98, layout: .device(config: .iPhoneXsMax)),
		named: name,
		record: recording,
		timeout: timeout,
		file: file,
		testName: testName,
		line: line
	)
}
