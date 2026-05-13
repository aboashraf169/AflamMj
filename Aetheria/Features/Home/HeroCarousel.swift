import SwiftUI

struct HeroCarousel: View {
    let items: [Movie]
    let height: CGFloat
    var namespace: Namespace.ID
    var onPlay: (Movie) -> Void
    var onSelect: (Movie) -> Void

    @State private var currentIndex: Int = 0
    @State private var autoTask: Task<Void, Never>? = nil

    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(Array(items.enumerated()), id: \.element.id) { idx, movie in
                HeroSlide(
                    movie: movie,
                    namespace: namespace,
                    onPlay: { onPlay(movie) },
                    onSelect: { onSelect(movie) }
                )
                .padding(.bottom, 24) // space for the page indicator
                .tag(idx)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(height: height)
        .overlay(alignment: .bottom) {
            PageIndicator(count: items.count, current: currentIndex)
                .padding(.bottom, 6)
        }
        .onAppear { startAutoplay() }
        .onDisappear { autoTask?.cancel() }
        .onChange(of: currentIndex) { _, _ in Haptics.tap() }
    }

    private func startAutoplay() {
        autoTask?.cancel()
        autoTask = Task { [items] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 6_000_000_000)
                guard !items.isEmpty, !Task.isCancelled else { break }
                await MainActor.run {
                    withAnimation(.smooth(duration: 0.7)) {
                        currentIndex = (currentIndex + 1) % items.count
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    @Previewable @Namespace var ns
    let movie = Movie(
        id: "872585", title: "Oppenheimer", tagline: "The world forever changes.", synopsis: "The story of J. Robert Oppenheimer.",
        year: "2023", duration: 180, rating: 8.9, kind: .movie,
        genres: [.drama, .thriller], cast: [], director: "Christopher Nolan",
        isExclusive: true, streamURL: URL(string: "https://streamimdb.ru/embed/movie/872585")!,
        trailerURL: nil, availableQualities: [.fhd, .uhd], subtitleLanguages: [], seasons: [],
        posterURL: "https://image.tmdb.org/t/p/w500/8Gxv8gSFCU0XGDykEGv7zR1n2ua.jpg",
        backdropURL: "https://image.tmdb.org/t/p/w1280/rLb2cwF3Pazuxaj0sRXQ037tGI1.jpg"
    )
    let movie2 = Movie(
        id: "155", title: "The Dark Knight", tagline: "Why so serious?", synopsis: "Batman raises the stakes in his war on crime.",
        year: "2008", duration: 152, rating: 9.0, kind: .movie,
        genres: [.action, .thriller], cast: [], director: "Christopher Nolan",
        isExclusive: false, streamURL: URL(string: "https://streamimdb.ru/embed/movie/155")!,
        trailerURL: nil, availableQualities: [.fhd, .uhd], subtitleLanguages: [], seasons: [],
        posterURL: "https://image.tmdb.org/t/p/w500/qJ2tW6WMUDux911r6m7haRef0WH.jpg",
        backdropURL: "https://image.tmdb.org/t/p/w1280/nMKdUUepR0i5zn0y1T4CejMUsaj.jpg"
    )
    ZStack {
        AppColors.background.ignoresSafeArea()
        HeroCarousel(items: [movie, movie2], height: 340, namespace: ns, onPlay: { _ in }, onSelect: { _ in })
    }
    .preferredColorScheme(.dark)
}

private struct HeroSlide: View {
    let movie: Movie
    let namespace: Namespace.ID
    let onPlay: () -> Void
    let onSelect: () -> Void

    @State private var appeared = false

    // MARK: - Background

    @ViewBuilder
    private var heroBackground: some View {
        // Prefer the wider backdrop (16:9) for the hero; fall back to poster then gradient
        let urlStr = movie.backdropURL ?? movie.posterURL
        if let urlStr, let url = URL(string: urlStr) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable()
                        .scaledToFill()
                default:
                    AppGradients.posterFallback(for: movie.id.hashValue)
                }
            }
        } else {
            AppGradients.posterFallback(for: movie.id.hashValue)
        }
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            GeometryReader { geo in
                heroBackground
                    .frame(width: geo.size.width, height: geo.size.height)
                    .overlay(AppGradients.heroOverlay)
                    .scaleEffect(appeared ? 1.03 : 1.0)
                    .animation(.easeOut(duration: 1.4), value: appeared)
                    .clipped()
            }

            VStack(alignment: .leading, spacing: 8) {
                if movie.isExclusive { ExclusiveBadge() }

                Text(movie.title)
                    .font(AppTypography.title2)
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.7), radius: 10, y: 3)
                    .matchedGeometryEffect(id: "title-\(movie.id)", in: namespace)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)

                Text(movie.tagline)
                    .font(AppTypography.caption)
                    .foregroundStyle(.white.opacity(0.85))
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Text(movie.year)
                    Text("•")
                    Text(movie.prettyDuration)
                    Text("•")
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .foregroundStyle(AppColors.warning)
                        Text(String(format: "%.1f", movie.rating))
                    }
                }
                .font(AppTypography.caption)
                .foregroundStyle(.white.opacity(0.85))
                .lineLimit(1)

                HStack(spacing: 8) {
                    HeroButton(title: "Play", icon: "play.fill", style: .accent, action: onPlay)
                    HeroButton(title: "Details", icon: "info.circle", style: .glass, action: onSelect)
                }
                .padding(.top, 2)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity)
        .clipped()
        .onTapGesture { onSelect() }
        .onAppear { appeared = true }
    }
}

// MARK: - Compact hero button (smaller than PrimaryButton for tight spaces)

private struct HeroButton: View {
    let title: String
    let icon: String
    var style: PrimaryButton.Style = .accent
    let action: () -> Void

    var body: some View {
        Button {
            Haptics.medium()
            action()
        } label: {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .bold))
                Text(title)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background {
                switch style {
                case .accent: AppGradients.accent
                case .glass:
                    Color.white.opacity(0.10).background(.ultraThinMaterial)
                case .danger: AppGradients.danger
                }
            }
            .clipShape(Capsule())
            .overlay {
                if style == .glass {
                    Capsule().stroke(AppColors.glassStroke, lineWidth: 1)
                }
            }
            .shadow(color: style == .accent ? AppColors.violet.opacity(0.5) : .clear,
                    radius: 10, y: 4)
        }
        .buttonStyle(.pressable)
    }
}

private struct PageIndicator: View {
    let count: Int
    let current: Int

    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<count, id: \.self) { i in
                Capsule()
                    .fill(i == current
                          ? AppGradients.accent
                          : LinearGradient(colors: [.white.opacity(0.3)], startPoint: .leading, endPoint: .trailing))
                    .frame(width: i == current ? 16 : 5, height: 5)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: current)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(Capsule().stroke(AppColors.glassStroke, lineWidth: 1))
    }
}
