import SwiftUI
import SwiftData

struct RootView: View {
    @EnvironmentObject private var appState: AppState
    @Namespace private var tabNamespace
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ZStack(alignment: .bottom) {
            AmbientBackground()
                .ignoresSafeArea()

            Group {
                switch appState.selectedTab {
                case .home:      HomeView()
                case .search:    SearchView()
                case .downloads: DownloadsView()
                case .favorites: FavoritesView()
                case .settings:  SettingsView()
                }
            }
            .environmentObject(appState.favoritesVM)
            .transition(.opacity)
            .animation(.smooth(duration: 0.3), value: appState.selectedTab)

            FloatingTabBar(selection: $appState.selectedTab, namespace: tabNamespace)
                .padding(.horizontal, Spacing.m)
                .padding(.bottom, 2)
        }
        .onAppear {
            appState.favoritesVM.load(context: modelContext)
        }
    }
}

// MARK: - Ambient Background

struct AmbientBackground: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            Circle()
                .fill(AppColors.violet.opacity(0.45))
                .frame(width: 420, height: 420)
                .blur(radius: 130)
                .offset(x: animate ? -100 : -140, y: animate ? -240 : -280)

            Circle()
                .fill(AppColors.indigo.opacity(0.35))
                .frame(width: 380, height: 380)
                .blur(radius: 150)
                .offset(x: animate ? 130 : 170, y: animate ? 280 : 320)

            Circle()
                .fill(AppColors.neon.opacity(0.20))
                .frame(width: 320, height: 320)
                .blur(radius: 170)
                .offset(x: animate ? 40 : -30, y: animate ? 40 : 100)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 9).repeatForever(autoreverses: true)) {
                animate.toggle()
            }
        }
    }
}

// MARK: - Floating Tab Bar

struct FloatingTabBar: View {
    @Binding var selection: RootTab
    let namespace: Namespace.ID

    private let items: [(RootTab, String, String)] = [
        (.home,      "Home",    "house.fill"),
        (.search,    "Search",  "magnifyingglass"),
        (.downloads, "Library", "arrow.down.circle.fill"),
        (.favorites, "Saved",   "heart.fill"),
        (.settings,  "Settings","gearshape.fill")
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(items, id: \.0) { tab, title, icon in
                tabItem(tab: tab, title: title, icon: icon)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 8)
        .background { barBackground }
    }

    // MARK: - Single tab item
    private func tabItem(tab: RootTab, title: String, icon: String) -> some View {
        let active = selection == tab
        return Button {
            Haptics.selection()
            withAnimation(.spring(response: 0.38, dampingFraction: 0.72)) {
                selection = tab
            }
        } label: {
            VStack(spacing: 5) {
                iconView(icon: icon, active: active, tab: tab)
                Text(title)
                    .font(.system(size: 9.5,
                                  weight: active ? .semibold : .regular,
                                  design: .rounded))
                    .foregroundStyle(active ? AppColors.primaryText : AppColors.mutedText)
                    .animation(.easeInOut(duration: 0.2), value: active)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Icon zone with indicator
    @ViewBuilder
    private func iconView(icon: String, active: Bool, tab: RootTab) -> some View {
        ZStack {
            // Glowing pill indicator behind the icon
            if active {
                Capsule()
                    .fill(AppGradients.accent.opacity(0.22))
                    .frame(width: 48, height: 30)
                    .matchedGeometryEffect(id: "tabIndicator", in: namespace)
            }

            Image(systemName: icon)
                .font(.system(size: active ? 16 : 15, weight: .semibold))
                .foregroundStyle(
                    active
                        ? AnyShapeStyle(AppGradients.accent)
                        : AnyShapeStyle(Color(white: 0.5))
                )
                // Glow beneath active icon
                .shadow(color: active ? AppColors.violet.opacity(0.9) : .clear,
                        radius: 8, x: 0, y: 0)
                .symbolEffect(.bounce.up.byLayer, value: active)
                .scaleEffect(active ? 1.08 : 1.0)
                .animation(.spring(response: 0.38, dampingFraction: 0.6), value: active)
        }
        .frame(width: 48, height: 30)
    }

    // MARK: - Bar background
    private var barBackground: some View {
        ZStack {
            // Base blur
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.ultraThinMaterial)
            // Gradient border (top-bright, bottom-dark)
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.18), .white.opacity(0.04)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        }
        .shadow(color: .black.opacity(0.5), radius: 24, x: 0, y: 12)
        // Extra violet ambient glow beneath the bar
        .shadow(color: AppColors.violet.opacity(0.15), radius: 30, x: 0, y: 8)
    }
}

#Preview {
    RootView().environmentObject(AppState())
}
