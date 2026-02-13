import SwiftUI

extension Color {
	public static let customWhite: Color =  hex(0xfafafa)
	public static let customBlack: Color = hex(0x060606)
	public static let chambrayLight: Color = hex(0x2B5877)
	public static let chambrayDark: Color = hex(0x7FADCC)
	public static let berryRed: Color = hex(0xD93D1A)
	public static let customGreen: Color = hex(0x006600)
	
	public static let backgroundWhite: Color = hex(0xfafafa)
	public static let backgroundBlack: Color = .gray.opacity(0.2)
  
  public static let bluePure: Color = hex(0x006BD5)
  public static let greenPure: Color = hex(0x1CB95A)
  public static let purplePure: Color = hex(0x7D2FD3)
  public static let redDark = Color.hex(0x950000)
  public static let redLight = Color.hex(0xF3A3A8)
  public static let redPure = Color.hex(0xE11926)
  public static let yellowPure = Color.hex(0xFFBE00)
  public static let blackPure = Color.black
  public static let whitePure = Color.white
  public static let orangePure = Color.hex(0xED674A)
  public static let grayPure = Color.hex(0x616D73)
}

extension Color {
	public static let chambray = Self {
		$0.userInterfaceStyle == .dark ? .chambrayDark : .chambrayLight
	}
	
	public static let adaptiveWhite = Self {
		$0.userInterfaceStyle == .dark ? .customBlack : .customWhite
	}
	
	public static let adaptiveBlack = Self {
		$0.userInterfaceStyle == .dark ? .customWhite : .customBlack
	}
	
	public static let adaptiveGray = Self {
		$0.userInterfaceStyle == .dark ? .gray : .gray.inverted()
	}
	
	public static let adaptiveBackground = Self {
		$0.userInterfaceStyle == .dark ?  .backgroundBlack : .backgroundWhite
	}
}

extension Color {
	public static func hex(_ hex: UInt) -> Self {
    Color(
			red: Double((hex & 0xff0000) >> 16) / 255,
			green: Double((hex & 0x00ff00) >> 8) / 255,
			blue: Double(hex & 0x0000ff) / 255,
			opacity: 1
		)
	}
}

#if canImport(UIKit)
import UIKit

extension Color {
	public init(dynamicProvider: @escaping (UITraitCollection) -> Color) {
		self = Color(UIColor { UIColor(dynamicProvider($0)) })
	}
	
	public func inverted() -> Self {
    Color(UIColor(self).inverted())
	}
}

extension UIColor {
	public func inverted() -> Self {
		Self {
			self.resolvedColor(
				with: UITraitCollection(userInterfaceStyle: $0.userInterfaceStyle == .dark ? .light : .dark)
			)
		}
	}
}
#endif
