import SwiftUI

// MARK: - Preview

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()
        SettingsView()
            .environmentObject(AppState())
    }
    .preferredColorScheme(.dark)
}

struct SettingsView: View {
    @StateObject private var vm = SettingsViewModel()
    @EnvironmentObject private var appState: AppState

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: Spacing.l) {
                header
                profileCard

                section(title: "Playback") {
                    pickerRow(title: "Default quality",
                              icon: "sparkles",
                              selection: Binding(get: { vm.defaultQuality },
                                                 set: { vm.defaultQuality = $0 })) {
                        ForEach(VideoQuality.allCases) { q in
                            Text(q.rawValue).tag(q)
                        }
                    }
                    pickerRow(title: "Subtitle language",
                              icon: "captions.bubble",
                              selection: $vm.subtitleLanguage) {
                        ForEach(["English", "Arabic", "Spanish", "French", "Japanese"], id: \.self) {
                            Text($0).tag($0)
                        }
                    }
                    toggleRow(title: "Autoplay next episode", icon: "forward.fill", value: $vm.autoplayNext)
                    toggleRow(title: "Skip intros", icon: "chevron.forward.2", value: $vm.skipIntro)
                }

                section(title: "Downloads") {
                    toggleRow(title: "Wi-Fi only", icon: "wifi", value: $vm.downloadsOnWifiOnly)
                    actionRow(title: "Clear cache",
                              icon: "trash.fill",
                              detail: "\(Int(vm.cacheSizeMB)) MB",
                              tint: AppColors.danger) {
                        vm.clearCache()
                    }
                }

                section(title: "Experience") {
                    toggleRow(title: "Haptic feedback", icon: "iphone.radiowaves.left.and.right",
                              value: Binding(
                                get: { vm.hapticsEnabled },
                                set: { vm.hapticsEnabled = $0; Haptics.enabled = $0 }
                              ))
                    toggleRow(title: "Reduced motion", icon: "wand.and.stars", value: $vm.reducedMotion)
                    toggleRow(title: "New episode alerts", icon: "bell.fill", value: $vm.notifyNewEpisodes)
                }

                section(title: "About") {
                    infoRow(title: "Version", value: "1.0.0", icon: "info.circle")
                    infoRow(title: "Build", value: "100", icon: "hammer.fill")
                    actionRow(title: "Help & Support", icon: "questionmark.circle.fill") { }
                    actionRow(title: "Privacy policy", icon: "lock.shield.fill") { }
                    actionRow(title: "Terms of service", icon: "doc.text.fill") { }
                }

                Text("AFLAMJ — Cinema, reimagined.")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.mutedText)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)

                Color.clear.frame(height: ScreenMetrics.tabBarClearance)
            }
            .padding(.top, 12)
        }
        .onAppear { Haptics.enabled = vm.hapticsEnabled }
    }

    // MARK: - Building blocks

    private var header: some View {
        HStack {
            Text("Settings")
                .font(AppTypography.title2)
                .foregroundStyle(AppColors.primaryText)
            Spacer()
        }
        .padding(.horizontal, Spacing.l)
    }

    private var profileCard: some View {
        GlassCard {
            HStack(spacing: 14) {
                ZStack {
                    Circle().fill(AppGradients.accent)
                        .frame(width: 56, height: 56)
                        .glow(color: AppColors.violet, radius: 14, intensity: 0.5)
                    Text("AT")
                        .font(.system(size: 20, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("AflamMj Member")
                        .font(AppTypography.headline)
                        .foregroundStyle(AppColors.primaryText)
                    HStack(spacing: 4) {
                        Image(systemName: "diamond.fill")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(AppColors.aqua)
                        Text("Premium Plan • 4K HDR")
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.subtleText)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(AppColors.mutedText)
            }
        }
        .padding(.horizontal, Spacing.l)
    }

    @ViewBuilder
    private func section<Content: View>(title: String, @ViewBuilder content: @escaping () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title.uppercased())
                .font(AppTypography.caption)
                .tracking(1.2)
                .foregroundStyle(AppColors.mutedText)
                .padding(.horizontal, Spacing.l + 4)

            GlassCard {
                VStack(spacing: 14) { content() }
            }
            .padding(.horizontal, Spacing.l)
        }
    }

    private func toggleRow(title: String, icon: String, value: Binding<Bool>) -> some View {
        HStack {
            Image(systemName: icon).frame(width: 22).foregroundStyle(AppColors.aqua)
            Text(title).font(AppTypography.body).foregroundStyle(AppColors.primaryText)
            Spacer()
            Toggle("", isOn: value).labelsHidden().tint(AppColors.violet)
        }
    }

    private func pickerRow<Content: View, V: Hashable>(title: String,
                                                       icon: String,
                                                       selection: Binding<V>,
                                                       @ViewBuilder picker: () -> Content) -> some View {
        HStack {
            Image(systemName: icon).frame(width: 22).foregroundStyle(AppColors.aqua)
            Text(title).font(AppTypography.body).foregroundStyle(AppColors.primaryText)
            Spacer()
            Picker("", selection: selection) { picker() }
                .pickerStyle(.menu)
                .tint(AppColors.subtleText)
        }
    }

    private func actionRow(title: String, icon: String, detail: String? = nil, tint: Color = .white, action: @escaping () -> Void) -> some View {
        Button(action: { Haptics.tap(); action() }) {
            HStack {
                Image(systemName: icon).frame(width: 22).foregroundStyle(tint == .white ? AppColors.aqua : tint)
                Text(title).font(AppTypography.body).foregroundStyle(AppColors.primaryText)
                Spacer()
                if let detail {
                    Text(detail).font(AppTypography.subhead).foregroundStyle(AppColors.subtleText)
                }
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(AppColors.mutedText)
            }
        }
        .buttonStyle(.plain)
    }

    private func infoRow(title: String, value: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon).frame(width: 22).foregroundStyle(AppColors.aqua)
            Text(title).font(AppTypography.body).foregroundStyle(AppColors.primaryText)
            Spacer()
            Text(value).font(AppTypography.subhead).foregroundStyle(AppColors.subtleText)
        }
    }
}
