import SwiftUI

public enum LatoFonts: String, CaseIterable {
	case latoItalic = "Lato-Italic"
	case latoLightItalic = "Lato-LightItalic"
	case latoThin = "Lato-Thin"
	case latoBold = "Lato-Bold"
	case latoBlack = "Lato-Black"
	case latoRegular = "Lato-Regular"
	case latoBlackItalic = "Lato-BlackItalic"
	case latoBoldItalic = "Lato-BoldItalic"
	case latoLight = "Lato-Light"
	case latoThinItalic = "Lato-ThinItalic"
}

extension View {
	public func adaptiveFont(
		_ name: LatoFonts,
		size: CGFloat,
		configure: @escaping (Font) -> Font = { $0 }
	) -> some View {
		modifier(AdaptiveFont(name: name.rawValue, size: size, configure: configure))
	}
}

private struct AdaptiveFont: ViewModifier {
	@Environment(\.adaptiveSize) var adaptiveSize
	
	let name: String
	let size: CGFloat
	let configure: (Font) -> Font
	
	func body(content: Content) -> some View {
		content.font(configure(.custom(name, size: size + adaptiveSize.padding)))
	}
}

import UIKit

public func registerFonts() {
	for font in LatoFonts.allCases {
		_ = UIFont.registerFont(bundle: .module, fontName: font.rawValue, fontExtension: "ttf")
	}
}

extension UIFont {
	static func registerFont(bundle: Bundle, fontName: String, fontExtension: String) -> Bool {
		
		guard let fontURL = bundle.url(forResource: fontName, withExtension: fontExtension) else {
			fatalError("Couldn't find font \(fontName)")
		}
		
		guard let fontDataProvider = CGDataProvider(url: fontURL as CFURL) else {
			fatalError("Couldn't load data from the font \(fontName)")
		}
		
		guard let font = CGFont(fontDataProvider) else {
			fatalError("Couldn't create font from data")
		}
		
		var error: Unmanaged<CFError>?
		let success = CTFontManagerRegisterGraphicsFont(font, &error)
		guard success else {
			print("Error registering font: maybe it was already registered.")
			return false
		}
		
		return true
	}
}
