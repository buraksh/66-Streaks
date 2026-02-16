import SwiftUI

// MARK: - Card View Style
enum CardViewStyle: String, CaseIterable {
    case progressBar
    case grid

    var label: String {
        switch self {
        case .progressBar: return "Progress Bar"
        case .grid: return "Grid"
        }
    }

    var icon: String {
        switch self {
        case .progressBar: return "chart.bar.fill"
        case .grid: return "square.grid.3x3.fill"
        }
    }
}

enum AppTheme {
    // MARK: - Primary Accent
    static let accentBlue = Color(hex: "7C5CFC")

    // MARK: - Brand Gradient (inspired by logo)
    /// Warm coral → pink → violet → teal flow
    static let brandGradientColors: [Color] = [
        Color(hex: "F97316"),  // warm coral/orange
        Color(hex: "EC4899"),  // hot pink
        Color(hex: "7C5CFC"),  // violet (primary accent)
        Color(hex: "14B8A6"),  // teal
    ]

    static var brandGradient: LinearGradient {
        LinearGradient(
            colors: brandGradientColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Brand gradient for CTA buttons (pink → violet, matching web style)
    static var ctaGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: "EC4899"),  // hot pink
                Color(hex: "7C5CFC"),  // violet (primary accent)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Success State
    static let successGreen = Color(hex: "10B981")

    // MARK: - Danger State
    static let dangerRed = Color(hex: "EF4444")

    // MARK: - Grid Colors
    static let gridFilledLight = Color(hex: "7C5CFC")
    static let gridEmptyLight = Color(hex: "EEF1F5")
    static let gridFilledDark = Color(hex: "7C5CFC")
    static let gridEmptyDark = Color(hex: "2C2C2E")

    // MARK: - Dark Mode
    static let darkBackground = Color(hex: "111111")
    static let darkCard = Color(hex: "1C1C1E")
    static let darkTextPrimary = Color(hex: "F8FAFC")

    // MARK: - Light Mode
    static let lightBackground = Color(hex: "F9FAFB")
    static let lightCard = Color(hex: "FFFFFF")
    static let lightTextPrimary = Color(hex: "111827")

    // MARK: - Preset Color Palette
    /// Soft colors that look great on both light and dark backgrounds
    static let presetColors: [(name: String, hex: String)] = [
        ("Red",     "EF4444"),  // Red
        ("Rose",    "F43F5E"),  // Red-Pink
        ("Orange",  "F59E0B"),  // Orange
        ("Amber",   "F97316"),  // Yellow-Orange
        ("Lime",    "84CC16"),  // Yellow-Green
        ("Green",   "10B981"),  // Green
        ("Teal",    "14B8A6"),  // Blue-Green
        ("Cyan",    "06B6D4"),  // Light Blue
        ("Blue",    "3B82F6"),  // Blue
        ("Indigo",  "6366F1"),  // Indigo
        ("Purple",  "8B5CF6"),  // Violet
        ("Pink",    "EC4899"),  // Pink
    ]

    // MARK: - Categorized SF Symbol Icons
    struct IconCategory: Identifiable {
        let id = UUID()
        let name: String
        let icons: [String]
    }

    static let iconCategories: [IconCategory] = [
        IconCategory(name: "Fitness & Sports", icons: [
            "dumbbell.fill",
            "figure.run",
            "figure.walk",
            "figure.yoga",
            "figure.pool.swim",
            "figure.mind.and.body",
            "figure.hiking",
            "figure.boxing",
            "bicycle",
            "sportscourt.fill",
            "trophy.fill",
            "medal.fill",
            // New
            "soccerball",
            "basketball.fill",
            "tennis.racket",
            "volleyball.fill",
            "skateboard.fill",
            "surfboard.fill",
            "sailboat.fill",
            "figure.climbing",
            "figure.cooldown",
            "figure.core.training",
            "figure.dance",
            "figure.strengthtraining.traditional"
        ]),
        IconCategory(name: "Health & Wellness", icons: [
            "heart.fill",
            "heart.text.square.fill",
            "drop.fill",
            "leaf.fill",
            "moon.fill",
            "bed.double.fill",
            "pills.fill",
            "cross.case.fill",
            "lungs.fill",
            "brain.head.profile",
            "eye.fill",
            // New
            "bandage.fill",
            "syringe.fill",
            "facemask.fill",
            "staroflife.fill",
            "ear.fill",
            "hand.raised.fill"
        ]),
        IconCategory(name: "Food & Drink", icons: [
            "fork.knife",
            "cup.and.saucer.fill",
            "mug.fill",
            "carrot.fill",
            "takeoutbag.and.cup.and.straw.fill",
            // New
            "waterbottle.fill",
            "wineglass.fill",
            "birthday.cake.fill",
            "fish.fill",
            "popcorn.fill",
            "frying.pan.fill"
        ]),
        IconCategory(name: "Learning & Focus", icons: [
            "book.fill",
            "graduationcap.fill",
            "pencil.line",
            "text.book.closed.fill",
            "brain",
            "lightbulb.fill",
            "puzzlepiece.fill",
            "globe",
            "character.book.closed.fill",
            // New
            "bookmark.fill",
            "doc.text.magnifyingglass",
            "eyeglasses",
            "ruler.fill",
            "backpack.fill",
            "paperclip"
        ]),
        IconCategory(name: "Creative", icons: [
            "music.note",
            "paintbrush.fill",
            "camera.fill",
            "mic.fill",
            "guitars.fill",
            "pianokeys",
            "theatermasks.fill",
            "film.fill",
            // New
            "gamecontroller.fill",
            "headphones",
            "paintpalette.fill",
            "scissors",
            "swatchpalette.fill",
            "photo.artframe"
        ]),
        IconCategory(name: "Productivity", icons: [
            "chevron.left.forwardslash.chevron.right",
            "laptopcomputer",
            "desktopcomputer",
            "clock.fill",
            "calendar",
            "checklist",
            "doc.text.fill",
            "folder.fill",
            "briefcase.fill",
            "chart.line.uptrend.xyaxis",
            // New
            "paperplane.fill",
            "tray.fill",
            "archivebox.fill",
            "printer.fill",
            "externaldrive.fill",
            "server.rack"
        ]),
        IconCategory(name: "Lifestyle", icons: [
            "sunrise.fill",
            "sparkles",
            "star.fill",
            "flame.fill",
            "bolt.fill",
            "target",
            "flag.fill",
            "gift.fill",
            "house.fill",
            "car.fill",
            "airplane",
            "dollarsign.circle.fill",
            // New
            "cart.fill",
            "creditcard.fill",
            "bag.fill",
            "suitcase.fill",
            "tent.fill",
            "tree.fill",
            "pawprint.fill",
            "tshirt.fill",
            "ticket.fill"
        ]),
        IconCategory(name: "Social & Communication", icons: [
            "person.2.fill",
            "bubble.left.fill",
            "phone.fill",
            "envelope.fill",
            "hand.thumbsup.fill",
            "hands.sparkles.fill",
            // New
            "person.3.fill",
            "person.crop.circle.fill",
            "shared.with.you",
            "message.fill",
            "video.fill",
            "mic.circle.fill"
        ]),
    ]
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
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
}

// MARK: - Environment-Aware Colors
extension View {
    func cardBackground(_ colorScheme: ColorScheme) -> some View {
        self.background(colorScheme == .dark ? AppTheme.darkCard : AppTheme.lightCard)
    }
}

struct AdaptiveColors {
    let colorScheme: ColorScheme

    var background: Color {
        colorScheme == .dark ? AppTheme.darkBackground : AppTheme.lightBackground
    }

    var card: Color {
        colorScheme == .dark ? AppTheme.darkCard : AppTheme.lightCard
    }

    var textPrimary: Color {
        colorScheme == .dark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary
    }

    var textSecondary: Color {
        colorScheme == .dark ? Color.gray.opacity(0.7) : Color.gray
    }

    var gridFilled: Color {
        colorScheme == .dark ? AppTheme.gridFilledDark : AppTheme.gridFilledLight
    }

    var gridEmpty: Color {
        colorScheme == .dark ? AppTheme.gridEmptyDark : AppTheme.gridEmptyLight
    }

    var cardBorder: Color {
        colorScheme == .dark ? Color.white.opacity(0.06) : Color.black.opacity(0.08)
    }

    /// Dimmed grid empty for in-card use (slightly more visible)
    var gridEmptyCard: Color {
        colorScheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.06)
    }
}
