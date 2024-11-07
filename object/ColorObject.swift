import SwiftUI

struct ColorObject: Identifiable {
    let id = UUID()
    let color: Color
    var position: CGPoint
}

struct ColorObjectView: View {
    @Binding var colorObject: ColorObject
    @Binding var shouldAnimate: Bool

    var body: some View {
        Circle()
            .fill(colorObject.color)
            .frame(width: 50, height: 50)
            .scaleEffect(shouldAnimate ? 1.2 : 1.0)
            .animation(Animation.easeInOut(duration: 0.2), value: 0.2)
    }
}


extension Color {
    static func random() -> Color {
           let randomHex = String(format: "%06X", Int.random(in: 0x000000...0xFFFFFF))
           return Color(hex: randomHex)
       }
       
       init(hex: String) {
           let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
           var int: UInt64 = 0
           Scanner(string: hex).scanHexInt64(&int)
           let a, r, g, b: UInt64
           switch hex.count {
           case 3: // RGB (12-bit)
               (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
           case 6: // RGB (24-bit)
               (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
           case 8: // ARGB (32-bit)
               (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
           default:
               (a, r, g, b) = (255, 0, 0, 0)
           }
           self.init(
               .sRGB,
               red: Double(r) / 255,
               green: Double(g) / 255,
               blue: Double(b) / 255,
               opacity: Double(a) / 255
           )
       }
       
       func rgbComponents() -> (red: Double, green: Double, blue: Double) {
           var red: CGFloat = 0
           var green: CGFloat = 0
           var blue: CGFloat = 0
           var alpha: CGFloat = 0
           UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
           return (Double(red), Double(green), Double(blue))
       }
   }
