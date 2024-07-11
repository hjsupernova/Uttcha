//
//  FireworkView.swift
//  Uttcha
//
//  Created by KHJ on 7/10/24.
//
// swiftlint:disable all

import SwiftUI

/// - Parameters:
///  - pieceCount: amount of confetti
///  - colors: list of colors that is applied to the default shapes
///  - pieceSize: size that confetti and emojis are scaled to
///  - radius: explosion radius
///  - repetitions: number of repetitions of the explosion
///  - repetitionInterval: duration between the repetitions
struct FireworkConfig {
    let pieceCount: Int
    let pieceType: [FireworkType]
    let colors: [Color]
    let pieceSize: CGFloat
    let radius: CGFloat
    var repetitions: Int
    let repetitionInterval: Double
    let explosionAnimationDuration: Double
    let launchAnimDuration: Double

    init(pieceCount: Int = 20,
         pieceType: [FireworkType] = [.text("😆"), .text("😁"), .text("🤣")],
         colors: [Color] = [
            Color(hex: "f88f22"),
            Color(hex: "9c1d08"),
            Color(hex: "ce7117"),
            Color(hex: "f24d24"),
            Color(hex: "113bc6"),
            Color(hex: "c54a85"),
            Color(hex: "92af96"),
            Color(hex: "d23508")
         ],
         pieceSize: CGFloat = 50,
         radius: CGFloat = 100,
         repetitions: Int = 4,
         repetitionInterval: Double = 1.0,
         explosionAnimDuration: Double = 1.2,
         launchAnimDuration: Double = 1.5) {
        self.pieceCount = pieceCount
        self.pieceType = pieceType
        self.colors = colors
        self.pieceSize = pieceSize
        self.radius = radius
        self.repetitions = repetitions
        self.repetitionInterval = repetitionInterval
        self.explosionAnimationDuration = explosionAnimDuration
        self.launchAnimDuration = launchAnimDuration
    }

    func getShapes() -> [AnyView] {
        var shapes = [AnyView]()
        for firework in pieceType{
            switch firework {
            case .shape(_):
                shapes.append(AnyView(firework.view.frame(width: pieceSize, height: pieceSize, alignment: .center)))
            default:
                shapes.append(AnyView(firework.view.font(.system(size: pieceSize))))
            }
        }
        return shapes
    }
}

struct FireworkView: View {
    @ObservedObject var vm: HomeViewModel
    @State var animate = 0
    @State var finishedAnimationCounter = 0
    @State var firstAppear = false

    var body: some View{
        ZStack{
            ForEach(finishedAnimationCounter..<animate, id:\.self){ i in
                FireworkContainer(
                    vm: vm,
                    finishedAnimationCounter: $finishedAnimationCounter
                )
            }
        }
        .onAppear(){
            firstAppear = true
        }
        .onChange(of: vm.fireworkTrigger){value in
            if firstAppear{
                for i in 0...vm.fireworkConfiguration.repetitions{
                    DispatchQueue.main.asyncAfter(deadline: .now() + vm.fireworkConfiguration.repetitionInterval * Double(i)) {
                        animate += 1
                    }
                }
            }
        }
    }
}

struct FireworkContainer: View {

    @ObservedObject var vm: HomeViewModel
    @Binding var finishedAnimationCounter:Int
    @State var firstAppear = true
    @State var randomX = Double.random(in: -100...100)
    @State var randomY = Double.random(in: 200.0...UIScreen.main.bounds.size.height-200)
    @State var location: CGPoint = CGPoint(x: 0, y: 0)
    @State var withPath = Int.random(in: 0...1)

    var body: some View{
        ZStack{
            ForEach(0..<vm.fireworkConfiguration.pieceCount, id:\.self){ i in
                FireworkFrame(
                    vm: vm,
                    index: i,
                    launchHeight: randomY,
                    color: getColor(),
                    withPath: withPath,
                    duration: getExplosionAnimationDuration()
                )
            }
        }
        .offset(x: location.x, y: location.y)
        .onAppear(){
            if firstAppear{
                withAnimation(Animation.timingCurve(0.075, 0.690, 0.330, 0.870, duration: vm.fireworkConfiguration.launchAnimDuration).repeatCount(1)) {
                    location.x = randomX
                    location.y = -randomY
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + getAnimDuration()) {
                    //Clear
                    self.finishedAnimationCounter += 1
                }
                firstAppear = false
            }
        }
    }
    func getAnimDuration() -> CGFloat{
        return vm.fireworkConfiguration.explosionAnimationDuration + vm.fireworkConfiguration.launchAnimDuration
    }
    func getColor() -> Color{
        return vm.fireworkConfiguration.colors.randomElement()!
    }
    func getRandomExplosionTimeVariation() -> CGFloat {
        return CGFloat((0...999).randomElement()!) / 2100
    }
    func getExplosionAnimationDuration() -> CGFloat {
        return vm.fireworkConfiguration.explosionAnimationDuration + getRandomExplosionTimeVariation()
    }
}

struct FireworkFrame: View{

    @ObservedObject var vm: HomeViewModel
    @State var location: CGPoint = CGPoint(x: 0, y: 0)
    @State var index: Int
    @State var launchHeight: CGFloat
    @State var percentage: CGFloat = 0.0
    @State var strokeWidth: CGFloat = 2.0
    @State var color: Color
    @State var withPath: Int
    @State var duration: CGFloat

    var body: some View{
        ZStack{
            FireworkItem(vm: vm, shape: getShape(), size: vm.fireworkConfiguration.pieceSize, color: color)
                .offset(x: location.x, y: location.y)
                .onAppear{
                    withAnimation(
                        Animation
                            .timingCurve(0.0, 1.0, 1.0, 1.0, duration: duration)
                            .delay(vm.fireworkConfiguration.launchAnimDuration).repeatCount(1)
                    ){
                        location.x = getDistance() * cos(deg2rad(getRandomAngle()))
                        location.y = -getDistance() * sin(deg2rad(getRandomAngle()))
                    }
                }

            if withPath == 0{
                Path { path in
                    path.move(to: .zero)
                    path.addLine(
                        to: CGPoint(
                            x: getDistance() * cos(deg2rad(getRandomAngle())),
                            y: -getDistance() * sin(deg2rad(getRandomAngle()))
                        )
                    )
                }.trim(from: 0.0, to: percentage)
                 .stroke(color, lineWidth: strokeWidth)
                 .frame(width: 1.0, height: 1.0)
                 .onAppear{
                     withAnimation(
                         Animation
                             .timingCurve(0.0, 1.0, 1.0, 1.0, duration: duration)
                             .delay(vm.fireworkConfiguration.launchAnimDuration).repeatCount(1)
                     ){
                         percentage = 1.0
                         strokeWidth = 0.0
                     }
                 }
            }
        }
    }
    func getRandomAngle() -> CGFloat{
        return (360.0 / Double(vm.fireworkConfiguration.pieceCount)) * Double(index)
    }
    func getShape() -> AnyView {
        return vm.fireworkConfiguration.getShapes().randomElement()!
    }
    func getDistance() -> CGFloat {
        return vm.fireworkConfiguration.radius + (launchHeight / 10)
    }
    func deg2rad(_ number: CGFloat) -> CGFloat {
        return number * CGFloat.pi / 180
    }
}

struct FireworkItem: View {

    @ObservedObject var vm: HomeViewModel
    @State var shape: AnyView
    @State var size: CGFloat
    @State var color: Color
    @State var scale = 1.0
    @State var move = false

    var body: some View {
        shape
            .frame(width: size, height: size)
            .scaleEffect(scale)
            .foregroundColor(color)
            .onAppear() {
                withAnimation(
                    Animation
                        .linear(duration: vm.fireworkConfiguration.explosionAnimationDuration)
                        .delay(vm.fireworkConfiguration.launchAnimDuration)
                        .repeatCount(1)
                ) {
                    scale = 0.0
                }
            }
    }
}

public enum FireworkType: CaseIterable, Hashable {
    public enum Shape {
        case circle
        case triangle
        case square
        case slimRectangle
        case roundedCross
    }

    case shape(Shape)
    case text(String)
    case sfSymbol(symbolName: String)

    public var view:AnyView{
        switch self {
        case .shape(.square):
            return AnyView(Rectangle())
        case .shape(.circle):
            return AnyView(Circle())
        case .shape(.triangle):
            return AnyView(Triangle())
        case .shape(.slimRectangle):
            return AnyView(SlimRectangle())
        case .shape(.roundedCross):
            return AnyView(RoundedCross())
        case let .text(text):
            return AnyView(Text(text))
        case .sfSymbol(let symbolName):
            return AnyView(Image(systemName: symbolName))
        }
    }
    public static var allCases: [FireworkType] {
        return [.shape(.circle), .shape(.triangle), .shape(.square), .shape(.slimRectangle), .shape(.roundedCross)]
    }
}


// MARK: - Shapes

public struct RoundedCross: Shape {
    public func path(in rect: CGRect) -> Path {

        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY/3))
        path.addQuadCurve(to: CGPoint(x: rect.maxX/3, y: rect.minY), control: CGPoint(x: rect.maxX/3, y: rect.maxY/3))
        path.addLine(to: CGPoint(x: 2*rect.maxX/3, y: rect.minY))

        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.maxY/3), control: CGPoint(x: 2*rect.maxX/3, y: rect.maxY/3))
        path.addLine(to: CGPoint(x: rect.maxX, y: 2*rect.maxY/3))

        path.addQuadCurve(to: CGPoint(x: 2*rect.maxX/3, y: rect.maxY), control: CGPoint(x: 2*rect.maxX/3, y: 2*rect.maxY/3))
        path.addLine(to: CGPoint(x: rect.maxX/3, y: rect.maxY))

        path.addQuadCurve(to: CGPoint(x: 2*rect.minX/3, y: 2*rect.maxY/3), control: CGPoint(x: rect.maxX/3, y: 2*rect.maxY/3))
        return path
    }
}


public struct SlimRectangle: Shape {
    public func path(in rect: CGRect) -> Path {

        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: 4*rect.maxY/5))
        path.addLine(to: CGPoint(x: rect.maxX, y: 4*rect.maxY/5))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        return path
    }
}


public struct Triangle: Shape {
    public func path(in rect: CGRect) -> Path {

        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        return path
    }
}

extension Color {
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
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

//#Preview {
//    FireworkView(vm.counter: .constant(1))
//}

// swiftlint:enable all
