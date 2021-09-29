//
//  PDFViewRepresentable.swift
//
//  Created by Albert Gil Escura on 19/9/21.
//

import PDFKit
import SwiftUI

struct PDFViewRepresentable: UIViewRepresentable {
    let data: Data

    init(data: Data) {
        self.data = data
    }

    func makeUIView(context: UIViewRepresentableContext<PDFViewRepresentable>) -> PDFViewRepresentable.UIViewType {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.document = PDFDocument(data: data)
        return pdfView
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PDFViewRepresentable>) {}
}
