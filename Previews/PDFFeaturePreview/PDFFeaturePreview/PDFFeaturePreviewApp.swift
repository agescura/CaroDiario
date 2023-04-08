import SwiftUI
import ExportFeature
import ComposableArchitecture

@main
struct PDFFeaturePreviewApp: App {
    var body: some Scene {
        WindowGroup {
            ExportView(
                store: .init(
                    initialState: .init(),
                    reducer: Export()
                )
            )
        }
    }
}
