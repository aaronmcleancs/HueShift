import SwiftUI

struct DotMatrix: View {
    @State private var animate = false
    @State private var animationAmount: CGFloat = 0
    @State private var viewId = UUID()
    @Environment(\.scenePhase) private var scenePhase

    private let columns = 11
    private let rows = 23

    let gradient = LinearGradient(gradient: Gradient(colors: [Color.gray, Color.secondary]), startPoint: .top, endPoint: .bottom)

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let cellWidth = width / CGFloat(columns)
            let cellHeight = height / CGFloat(rows)

            ForEach(0..<rows, id: \.self) { row in
                ForEach(0..<columns, id: \.self) { column in
                    Circle()
                        .fill(gradient)
                        .frame(width: cellWidth / 6, height: cellHeight / 6)
                        .offset(
                            x: (cellWidth * CGFloat(column) - geometry.safeAreaInsets.leading) + animationAmount,
                            y: (cellHeight * CGFloat(row) - geometry.safeAreaInsets.top) + animationAmount
                        )
                        .opacity(animate ? 0.5 : 1.0)
                        .animation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true).delay(Double(row + column) * 0.07))
                }
            }
        }
        .id(viewId)  // Add this line to redraw the view each time it appears
        .onAppear {
            animate = true
            animationAmount = 6
            viewId = UUID()  // Generate a new id each time the view appears
        }
        .onChange(of: scenePhase) { newScenePhase in
            if newScenePhase == .active {
                animate = false
                animationAmount = 0
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    animate = true
                    animationAmount = 6
                    viewId = UUID()  // Generate a new id each time the view becomes active
                }
            }
        }
        .background(Color(.secondarySystemBackground).edgesIgnoringSafeArea(.all))
    }
}

struct DotMatrix_Previews: PreviewProvider {
    static var previews: some View {
        DotMatrix()
    }
}
