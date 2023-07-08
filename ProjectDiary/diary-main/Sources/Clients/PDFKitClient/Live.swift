//
//  Live.swift  
//
//  Created by Albert Gil Escura on 18/9/21.
//

import Foundation
import PDFKit
import ComposableArchitecture
import Models
import Localizables
import Dependencies

extension PDFKitClient: DependencyKey {
  public static var liveValue: PDFKitClient { .live }
}

extension PDFKitClient {
	 
	 public static var live = Self(
		  generatePDF: { entries, date in
				let pdfMetaData = [
					 kCGPDFContextCreator: "Caro Diario",
					 kCGPDFContextAuthor: "@agescura"
				]
				let format = UIGraphicsPDFRendererFormat()
				format.documentInfo = pdfMetaData as [String: Any]
				
				let pageWidth = 8.5 * 72.0
				let pageHeight = 11 * 72.0
				let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
				let marginPoint: CGPoint = CGPoint(x: 50, y: 50)
				let marginSize: CGSize = CGSize(width: marginPoint.x * 2, height: marginPoint.y * 2)
				let textContainerSize = CGSize(width: pageWidth - marginSize.width, height: pageHeight - marginSize.height)
				
				let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
				let data = renderer.pdfData { (context) in
					 context.beginPage()
					 
					 for day in entries {
						  for entry in day {
								add(
									 entry,
									 context: context
								)
								context.beginPage()
						  }
					 }
				}
				
				return data
		  }
	 )
}

@discardableResult
func add(_ entry : Entry, context : UIGraphicsPDFRendererContext) -> CGFloat {
	 let textFont = UIFont.systemFont(ofSize: 14.0, weight: .regular)
	 let paragraphStyle = NSMutableParagraphStyle()
	 paragraphStyle.alignment = .natural
	 paragraphStyle.lineBreakMode = .byWordWrapping
	 let textAttributes = [
		  NSAttributedString.Key.paragraphStyle: paragraphStyle,
		  NSAttributedString.Key.font: textFont
	 ]
	 let newText = "\("PDF.Date".localized) \(entry.date.full) \n\n\(entry.text.message)"
	 let currentText = CFAttributedStringCreate(nil,
															  newText as CFString,
															  textAttributes as CFDictionary)
	 let framesetter = CTFramesetterCreateWithAttributedString(currentText!)

	 var currentRange = CFRangeMake(0, 0)
	 var currentPage = 0
	 var done = false
	 repeat {

		  if currentPage != 0 {
		  context.beginPage()
		  }

		  currentPage += 1
		  drawPageNumber(currentPage)

		  currentRange = renderPage(currentPage,
											 withTextRange: currentRange,
											 andFramesetter: framesetter)

		  if currentRange.location == CFAttributedStringGetLength(currentText) {
				done = true
		  }

	 } while !done

	 return CGFloat(currentRange.location + currentRange.length)
}

func renderPage(_ pageNum: Int, withTextRange currentRange: CFRange, andFramesetter framesetter: CTFramesetter?) -> CFRange {
	 var currentRange = currentRange
	 let currentContext = UIGraphicsGetCurrentContext()
	 currentContext?.textMatrix = .identity

	 let frameRect = CGRect(x: marginPoint.x, y: marginPoint.y, width: pageWidth - marginSize.width, height: pageHeight - marginSize.height)
	 let framePath = CGMutablePath()
	 framePath.addRect(frameRect, transform: .identity)
	 let frameRef = CTFramesetterCreateFrame(framesetter!, currentRange, framePath, nil)

	 currentContext?.translateBy(x: 0, y: pageHeight)
	 currentContext?.scaleBy(x: 1.0, y: -1.0)

	 CTFrameDraw(frameRef, currentContext!)

	 currentRange = CTFrameGetVisibleStringRange(frameRef)
	 currentRange.location += currentRange.length
	 currentRange.length = CFIndex(0)

	 return currentRange
}

func drawPageNumber(_ pageNum: Int) {
	 let theFont = UIFont.systemFont(ofSize: 20)
	 let pageString = NSMutableAttributedString(string: "\("PDF.Page".localized) \(pageNum)")
	 pageString.addAttribute(NSAttributedString.Key.font, value: theFont, range: NSRange(location: 0, length: pageString.length))
	 let pageStringSize =  pageString.size()
	 let stringRect = CGRect(x: (pageRect.width - pageStringSize.width) / 2.0,
									 y: pageRect.height - (pageStringSize.height) / 2.0 - 15,
									 width: pageStringSize.width,
									 height: pageStringSize.height)
	 pageString.draw(in: stringRect)
}


var pageWidth : CGFloat  = 8.5 * 72.0
var pageHeight : CGFloat = 11 * 72.0
var pageRect : CGRect = CGRect(x: 0, y: 0, width: 8.5 * 72.0, height: 11 * 72.0)
var marginPoint : CGPoint = CGPoint(x: 10, y: 10)
var marginSize : CGSize = CGSize(width: 10 * 2 , height: 10 * 2)

extension Date {
	 var full: String {
		  let formatter = DateFormatter()
		  formatter.dateFormat = "EEEE, d MMMM yyyy HH:mm:ss"
		  return formatter.string(from: self)
	 }
}
