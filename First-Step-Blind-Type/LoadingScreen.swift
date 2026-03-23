import SwiftUI

struct TypeLoadingScreen: View {
    @State private var pulse = false

    var body: some View {
        ZStack {
            Color(red: 10/255, green: 10/255, blue: 10/255)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                KeyboardIconShape()
                    .fill(Color(red: 0, green: 230/255, blue: 118/255))
                    .frame(width: 80, height: 60)
                    .scaleEffect(pulse ? 1.1 : 0.95)
                    .animation(
                        Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                        value: pulse
                    )

                Text("Loading...")
                    .font(.system(size: 18, weight: .medium, design: .default))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .onAppear { pulse = true }
    }
}

struct KeyboardIconShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        path.addRoundedRect(in: CGRect(x: 0, y: 0, width: w, height: h), cornerSize: CGSize(width: 8, height: 8))
        let keyW = w * 0.12
        let keyH = h * 0.2
        let gap = w * 0.04
        for row in 0..<3 {
            let y = h * 0.15 + CGFloat(row) * (keyH + gap)
            let count = row == 2 ? 5 : 7
            let totalW = CGFloat(count) * keyW + CGFloat(count - 1) * gap
            let startX = (w - totalW) / 2
            for col in 0..<count {
                let x = startX + CGFloat(col) * (keyW + gap)
                path.addRoundedRect(in: CGRect(x: x, y: y, width: keyW, height: keyH), cornerSize: CGSize(width: 2, height: 2))
            }
        }
        path = path.strokedPath(StrokeStyle(lineWidth: 2))
        return path
    }
}
