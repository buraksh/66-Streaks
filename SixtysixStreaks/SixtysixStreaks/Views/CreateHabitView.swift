import SwiftUI
import SwiftData

struct CreateHabitView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Query private var habits: [Habit]

    let isOnboarding: Bool
    var onComplete: (() -> Void)?
    var editingHabit: Habit?

    @State private var title = ""
    @State private var selectedIcon = "flame.fill"
    @State private var selectedColorHex = "10B981"
    @State private var reminderTime = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
    @State private var checkInWindowStart = 6
    @State private var checkInWindowEnd = 23
    @State private var morningMotivationEnabled = false
    @State private var showIconPicker = false

    private var colors: AdaptiveColors {
        AdaptiveColors(colorScheme: colorScheme)
    }

    private var selectedColor: Color {
        Color(hex: selectedColorHex)
    }

    private var isEditing: Bool {
        editingHabit != nil
    }

    private var canCreate: Bool {
        let hasTitle = !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        if isEditing { return hasTitle }
        return hasTitle && habits.count < 10
    }

    init(isOnboarding: Bool, onComplete: (() -> Void)? = nil, editingHabit: Habit? = nil) {
        self.isOnboarding = isOnboarding
        self.onComplete = onComplete
        self.editingHabit = editingHabit

        if let habit = editingHabit {
            _title = State(initialValue: habit.title)
            _selectedIcon = State(initialValue: habit.iconName)
            _selectedColorHex = State(initialValue: habit.colorHex)
            _reminderTime = State(initialValue: habit.reminderTime)
            _checkInWindowStart = State(initialValue: habit.checkInWindowStart)
            _checkInWindowEnd = State(initialValue: habit.checkInWindowEnd)
            _morningMotivationEnabled = State(initialValue: habit.morningMotivationEnabled)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                colors.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 28) {
                            titleSection
                            iconSection
                            colorPickerSection
                            reminderSection
                            checkInWindowSection
                            motivationToggle
                        }
                        .padding(24)
                        .padding(.bottom, 16)
                    }

                    // Sticky CTA — always visible
                    VStack(spacing: 0) {
                        Divider()
                            .opacity(0.3)
                        createButton
                            .padding(.horizontal, 24)
                            .padding(.top, 12)
                            .padding(.bottom, 16)
                    }
                    .background(colors.background)
                }
            }
            .navigationTitle(isEditing ? "Edit Streak" : (isOnboarding ? "Your First Streak" : "New Streak"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !isOnboarding || isEditing {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") { dismiss() }
                    }
                }
            }
        }
    }

    // MARK: - Title Section
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("HABIT NAME")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(colors.textSecondary)
                .tracking(1)

            TextField("e.g. Go to the gym", text: $title)
                .font(.system(size: 17))
                .padding(16)
                .background(colors.card)
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                )
        }
    }

    // MARK: - Icon Section
    private var iconSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("ICON")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(colors.textSecondary)
                .tracking(1)

            Button {
                showIconPicker = true
            } label: {
                HStack(spacing: 14) {
                    Image(systemName: selectedIcon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(selectedColor)
                        .frame(width: 44, height: 44)
                        .background(selectedColor.opacity(colorScheme == .dark ? 0.2 : 0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    Text("Choose Icon")
                        .font(.system(size: 16))
                        .foregroundColor(colors.textPrimary)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(colors.textSecondary)
                }
                .padding(12)
                .background(colors.card)
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                )
            }
        }
        .sheet(isPresented: $showIconPicker) {
            iconPickerSheet
        }
    }

    // MARK: - Icon Picker Sheet
    private var iconPickerSheet: some View {
        NavigationStack {
            ZStack {
                colors.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        ForEach(AppTheme.iconCategories) { category in
                            VStack(alignment: .leading, spacing: 10) {
                                Text(category.name.uppercased())
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(colors.textSecondary)
                                    .tracking(0.8)
                                    .padding(.horizontal, 4)

                                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 5), spacing: 10) {
                                    ForEach(category.icons, id: \.self) { icon in
                                        Image(systemName: icon)
                                            .font(.system(size: 20, weight: .medium))
                                            .foregroundColor(selectedIcon == icon ? selectedColor : colors.textSecondary)
                                            .frame(width: 52, height: 52)
                                            .background(
                                                selectedIcon == icon
                                                    ? selectedColor.opacity(colorScheme == .dark ? 0.2 : 0.12)
                                                    : colors.card
                                            )
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(
                                                        selectedIcon == icon ? selectedColor.opacity(0.5) : colors.cardBorder,
                                                        lineWidth: selectedIcon == icon ? 2 : 1
                                                    )
                                            )
                                            .onTapGesture {
                                                selectedIcon = icon
                                                showIconPicker = false
                                            }
                                    }
                                }
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Choose Icon")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { showIconPicker = false }
                }
            }
        }
        .presentationDetents([.large])
    }

    // MARK: - Color Picker
    private var colorPickerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("COLOR")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(colors.textSecondary)
                .tracking(1)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 6), spacing: 12) {
                ForEach(AppTheme.presetColors, id: \.hex) { preset in
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(hex: preset.hex))
                        .frame(width: 40, height: 40)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white, lineWidth: selectedColorHex == preset.hex ? 3 : 0)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(colors.cardBorder, lineWidth: selectedColorHex == preset.hex ? 0 : 1)
                        )
                        .shadow(color: selectedColorHex == preset.hex ? Color(hex: preset.hex).opacity(0.4) : .clear, radius: 4)
                        .scaleEffect(selectedColorHex == preset.hex ? 1.1 : 1.0)
                        .animation(.spring(response: 0.3), value: selectedColorHex)
                        .onTapGesture {
                            selectedColorHex = preset.hex
                        }
                }
            }
            .padding(16)
            .background(colors.card)
            .cornerRadius(14)
        }
    }

    // MARK: - Reminder Section
    private var reminderSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("DAILY REMINDER")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(colors.textSecondary)
                .tracking(1)

            HStack {
                Image(systemName: "bell.fill")
                    .foregroundColor(AppTheme.accentBlue)

                DatePicker("", selection: $reminderTime, displayedComponents: .hourAndMinute)
                    .labelsHidden()

                Spacer()
            }
            .padding(16)
            .background(colors.card)
            .cornerRadius(14)
        }
    }

    // MARK: - Check-in Window
    private var checkInWindowSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("CHECK-IN WINDOW")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(colors.textSecondary)
                .tracking(1)

            VStack(spacing: 16) {
                HStack {
                    Text("Start")
                        .foregroundColor(colors.textPrimary)
                    Spacer()
                    Picker("", selection: $checkInWindowStart) {
                        ForEach(0..<24, id: \.self) { hour in
                            Text(formatHour(hour)).tag(hour)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(AppTheme.accentBlue)
                }

                Divider()

                HStack {
                    Text("End")
                        .foregroundColor(colors.textPrimary)
                    Spacer()
                    Picker("", selection: $checkInWindowEnd) {
                        ForEach(0..<24, id: \.self) { hour in
                            Text(formatHour(hour)).tag(hour)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(AppTheme.accentBlue)
                }
            }
            .padding(16)
            .background(colors.card)
            .cornerRadius(14)
        }
    }

    // MARK: - Morning Motivation
    private var motivationToggle: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("OPTIONAL")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(colors.textSecondary)
                .tracking(1)

            Toggle(isOn: $morningMotivationEnabled) {
                HStack(spacing: 12) {
                    Image(systemName: "sunrise.fill")
                        .foregroundColor(.orange)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Morning Motivation")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(colors.textPrimary)
                        Text("Get an 8 AM boost message")
                            .font(.system(size: 13))
                            .foregroundColor(colors.textSecondary)
                    }
                }
            }
            .tint(AppTheme.accentBlue)
            .padding(16)
            .background(colors.card)
            .cornerRadius(14)
        }
    }

    // MARK: - Create / Save Button
    private var createButton: some View {
        Button {
            if isEditing {
                saveHabit()
            } else {
                createHabit()
            }
        } label: {
            Text(isEditing ? "Save Changes" : "Start 66-Day Challenge")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(canCreate ? AppTheme.accentBlue : Color.gray.opacity(0.4))
                .cornerRadius(16)
        }
        .disabled(!canCreate)
    }

    // MARK: - Actions
    private func saveHabit() {
        guard let habit = editingHabit else { return }
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }

        habit.title = trimmedTitle
        habit.iconName = selectedIcon
        habit.colorHex = selectedColorHex
        habit.reminderTime = reminderTime
        habit.checkInWindowStart = checkInWindowStart
        habit.checkInWindowEnd = checkInWindowEnd
        habit.morningMotivationEnabled = morningMotivationEnabled

        NotificationManager.shared.cancelNotifications(for: habit)
        NotificationManager.shared.scheduleReminder(for: habit)
        NotificationManager.shared.scheduleMorningMotivation(for: habit)

        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()

        dismiss()
    }

    private func createHabit() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }

        let habit = Habit(
            title: trimmedTitle,
            iconName: selectedIcon,
            colorHex: selectedColorHex,
            reminderTime: reminderTime,
            checkInWindowStart: checkInWindowStart,
            checkInWindowEnd: checkInWindowEnd,
            morningMotivationEnabled: morningMotivationEnabled
        )

        modelContext.insert(habit)

        NotificationManager.shared.requestPermission()
        NotificationManager.shared.scheduleReminder(for: habit)
        NotificationManager.shared.scheduleMorningMotivation(for: habit)

        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()

        if isOnboarding {
            onComplete?()
        } else {
            dismiss()
        }
    }

    private func formatHour(_ hour: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h a"
        let date = Calendar.current.date(from: DateComponents(hour: hour)) ?? Date()
        return formatter.string(from: date)
    }
}

#Preview {
    CreateHabitView(isOnboarding: false)
        .modelContainer(for: Habit.self, inMemory: true)
}
