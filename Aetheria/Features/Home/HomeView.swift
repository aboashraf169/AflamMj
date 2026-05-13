import SwiftUI

struct HomeView: View {
    @StateObject private var vm = HomeViewModel()
    @Namespace private var heroNamespace
    @State private var presentedMovie: Movie? = nil
    @State private var playingMovie:   Movie? = nil
    @State private var seeAll: SeeAllConfig?  = nil

    var body: some View {
        GeometryReader { proxy in
            let heroHeight = ScreenMetrics.heroHeight(for: proxy.size.height)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: Spacing.l) {
                    // ── Hero carousel (edge-to-edge, no top padding) ────────

                    if vm.featured.isEmpty {
                        ShimmerView(cornerRadius: 0)
                            .frame(height: heroHeight)
                    } else {
                        HeroCarousel(
                            items: vm.featured,
                            height: heroHeight,
                            namespace: heroNamespace,
                            onPlay:   { playingMovie = $0 },
                            onSelect: { presentedMovie = $0 }
                        )
                    }

                    // ── Trending now ───────────────────────────────────────
                    if !vm.trending.isEmpty {
                        ContentRow(
                            title: "Trending now",
                            subtitle: "What everyone's watching.",
                            movies: vm.trending,
                            namespace: heroNamespace,
                            onSeeAll: { seeAll = SeeAllConfig(title: "Trending now", movies: vm.trending) }
                        ) { presentedMovie = $0 }
                    }

                    // ── Latest releases ────────────────────────────────────
                    if !vm.latest.isEmpty {
                        ContentRow(
                            title: "Latest releases",
                            movies: vm.latest,
                            namespace: heroNamespace,
                            onSeeAll: { seeAll = SeeAllConfig(title: "Latest releases", movies: vm.latest) }
                        ) { presentedMovie = $0 }
                    }

                    // ── Top rated ──────────────────────────────────────────
                    if !vm.topRated.isEmpty {
                        ContentRow(
                            title: "Top rated",
                            movies: vm.topRated,
                            namespace: heroNamespace,
                            onSeeAll: { seeAll = SeeAllConfig(title: "Top rated", movies: vm.topRated) }
                        ) { presentedMovie = $0 }
                    }

                    // ── Recommended (TV popular) ───────────────────────────
                    if !vm.recommended.isEmpty {
                        ContentRow(
                            title: "Popular series",
                            movies: vm.recommended,
                            namespace: heroNamespace,
                            onSeeAll: { seeAll = SeeAllConfig(title: "Popular series", movies: vm.recommended) }
                        ) { presentedMovie = $0 }
                    }

                    // ── By genre ───────────────────────────────────────────
                    ForEach([Genre.sciFi, .thriller, .drama, .action], id: \.id) { genre in
                        if let list = vm.byGenre[genre], !list.isEmpty {
                            ContentRow(
                                title: genre.name,
                                movies: list,
                                namespace: heroNamespace,
                                onSeeAll: { seeAll = SeeAllConfig(title: genre.name, movies: list) }
                            ) { presentedMovie = $0 }
                        }
                    }

                    Color.clear.frame(height: ScreenMetrics.tabBarClearance)
                }
            }
            .scrollIndicators(.hidden)
            .ignoresSafeArea(edges: .top)
        }
        .task { await vm.load() }
        // Movie detail sheet
        .sheet(item: $presentedMovie) { movie in
            MovieDetailsView(movie: movie, namespace: heroNamespace) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    playingMovie = movie
                }
            }
            .presentationDragIndicator(.visible)
            .presentationBackground(AppColors.background)
        }
        // See all sheet
        .sheet(item: $seeAll) { config in
            SeeAllView(title: config.title, movies: config.movies)
                .presentationBackground(AppColors.background)
                .presentationDragIndicator(.visible)
        }
        // Player
        .fullScreenCover(item: $playingMovie) { movie in
            WebPlayerView(movie: movie)
        }
    }
}

// MARK: - See All Config

struct SeeAllConfig: Identifiable {
    let id    = UUID()
    let title: String
    let movies: [Movie]
}

// MARK: - Brand Header

private struct BrandHeader: View {
    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(AppGradients.accent)
                    .frame(width: 32, height: 32)
                    .glow(color: AppColors.violet, radius: 10, intensity: 0.5)
                Image(systemName: "diamond.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)
            }
            VStack(alignment: .leading, spacing: 0) {
                Text("AFLAMJ")
                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                    .tracking(1.8)
                    .foregroundStyle(AppColors.primaryText)
                Text("أفلام MJ")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundStyle(AppColors.subtleText)
            }
            Spacer(minLength: 0)
            Button { Haptics.tap() } label: {
                ZStack {
                    Circle().fill(.ultraThinMaterial)
                    Circle().stroke(AppColors.glassStroke, lineWidth: 1)
                    Image(systemName: "bell.fill")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .frame(width: 34, height: 34)
            }
            .buttonStyle(.pressable)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AppState())
        .preferredColorScheme(.dark)
}
