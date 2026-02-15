import SwiftUI

struct StreakGridView: View {
    let completedDays: Int
    let totalDays: Int
    var filledColor: Color? = nil
    @Environment(\.colorScheme) private var colorScheme

    private var colors: AdaptiveColors {
        AdaptiveColors(colorScheme: colorScheme)
    }

    private var activeFill: Color {
        filledColor ?? colors.gridFilled
    }

    /// Compute grid dimensions based on available width
    private let columnsCount = 11

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 3), count: columnsCount)
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: 3) {
            ForEach(0..<totalDays, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(index < completedDays ? activeFill : colors.gridEmptyCard)
                    .aspectRatio(1, contentMode: .fit)
            }
        }
    }
}

#Preview("Light") {
    StreakGridView(completedDays: 23, totalDays: 66, filledColor: Color(hex: "10B981"))
        .padding(20)
        .background(Color.white)
}

#Preview("Dark") {
    StreakGridView(completedDays: 45, totalDays: 66, filledColor: Color(hex: "8B5CF6"))
        .padding(20)
        .background(AppTheme.darkCard)
        .preferredColorScheme(.dark)
}
