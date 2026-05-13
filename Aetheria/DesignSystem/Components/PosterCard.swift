import SwiftUI

/// Cinematic poster card.
/// - Pass an explicit `width` for horizontal rows.
/// - Pass `width: nil` to fill the available column width inside a `LazyVGrid`.
struct PosterCard: View {
    let movie: Movie
    var width: CGFloat? = 120
    var showTitle: Bool = true
    var namespace: Namespace.ID? = nil
    var heroID: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            poster
            if showTitle { caption }
        }
        .frame(width: width)
    }

    // MARK: - Poster

    @ViewBuilder
    private var poster: some View {
        posterImage
            .aspectRatio(2.0 / 3.0, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: Radius.m, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: Radius.m, style: .continuous)
                    .strokeBorder(AppGradients.cardEdge, lineWidth: 1)
            }
            .overlay(alignment: .topLeading) {
                if movie.isExclusive {
                    ExclusiveBadge().padding(6)
                }
            }
            .overlay(alignment: .bottomTrailing) {
                RatingPill(rating: movie.rating).padding(6)
            }
            .ifLet(namespace) { view, ns in
                if let id = heroID {
                    view.matchedGeometryEffect(id: id, in: ns)
                } else { view }
            }
            .cardShadow()
    }

    private var posterImage: some View {
        Group {
            if let urlStr = movie.posterURL, let url = URL(string: urlStr) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .overlay {
                                LinearGradient(
                                    colors: [.black.opacity(0.4), .clear, .black.opacity(0.2)],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            }
                    case .failure:
                        gradientPoster
                    case .empty:
                        // Shimmer while loading — keeps the card from flashing white
                        ShimmerView(cornerRadius: 0)
                    @unknown default:
                        gradientPoster
                    }
                }
            } else {
                gradientPoster
            }
        }
    }

    private var gradientPoster: some View {
        ZStack {
            AppGradients.posterFallback(for: movie.id.hashValue)
            VStack {
                Spacer(minLength: 0)
                Text(movie.title)
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white.opacity(0.95))
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.6)
                    .lineLimit(2)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 12)
                    .shadow(color: .black.opacity(0.6), radius: 6, y: 2)
            }
            AppGradients.posterShine.blendMode(.overlay)
        }
    }

    // MARK: - Caption

    private var caption: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(movie.title)
                .font(AppTypography.subhead)
                .foregroundStyle(AppColors.primaryText)
                .lineLimit(1)
            Text(movie.genres.first?.name ?? movie.year)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.subtleText)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
