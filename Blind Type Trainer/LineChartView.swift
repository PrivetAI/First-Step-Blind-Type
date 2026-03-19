import SwiftUI

struct LineChartView: View {
    let dataPoints: [Double]
    let lineColor: Color

    var body: some View {
        GeometryReader { geo in
            if dataPoints.count < 2 {
                Text("Not enough data")
                    .font(.system(size: 14, weight: .medium, design: .default))
                    .foregroundColor(.white.opacity(0.3))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                let minVal = (dataPoints.min() ?? 0) * 0.9
                let maxVal = max((dataPoints.max() ?? 1) * 1.1, minVal + 1)
                let w = geo.size.width
                let h = geo.size.height
                let stepX = w / CGFloat(dataPoints.count - 1)

                ZStack {
                    // Grid lines
                    ForEach(0..<5, id: \.self) { i in
                        let y = h * CGFloat(i) / 4
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: y))
                            path.addLine(to: CGPoint(x: w, y: y))
                        }
                        .stroke(Color.white.opacity(0.06), lineWidth: 0.5)
                    }

                    // Gradient fill
                    Path { path in
                        for (index, value) in dataPoints.enumerated() {
                            let x = CGFloat(index) * stepX
                            let normalized = CGFloat((value - minVal) / (maxVal - minVal))
                            let y = h - (normalized * h)
                            if index == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                        path.addLine(to: CGPoint(x: CGFloat(dataPoints.count - 1) * stepX, y: h))
                        path.addLine(to: CGPoint(x: 0, y: h))
                        path.closeSubpath()
                    }
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [lineColor.opacity(0.3), lineColor.opacity(0.0)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                    // Line
                    Path { path in
                        for (index, value) in dataPoints.enumerated() {
                            let x = CGFloat(index) * stepX
                            let normalized = CGFloat((value - minVal) / (maxVal - minVal))
                            let y = h - (normalized * h)
                            if index == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                    .stroke(lineColor, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))

                    // Dots
                    ForEach(Array(dataPoints.enumerated()), id: \.offset) { index, value in
                        let x = CGFloat(index) * stepX
                        let normalized = CGFloat((value - minVal) / (maxVal - minVal))
                        let y = h - (normalized * h)
                        Circle()
                            .fill(lineColor)
                            .frame(width: 6, height: 6)
                            .position(x: x, y: y)
                    }
                }
            }
        }
    }
}
