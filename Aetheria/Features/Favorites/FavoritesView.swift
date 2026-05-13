import SwiftUI

// MARK: - Preview

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()
        FavoritesView()
    }
    .preferredColorScheme(.dark)
}

struct FavoritesView: View {
    @EnvironmentObject private var vm: FavoritesViewModel
    @Namespace private var ns
    @State private var presented: Movie? = nil

    private let columns = [GridItem(.adaptive(minimum: ScreenMetrics.gridPosterMin,
                                              maximum: ScreenMetrics.gridPosterMax),
                                    spacing: Spacing.m)]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: Spacing.l) {
                header
                filters

                if vm.filtered.isEmpty {
                    empty
                } else {
                    LazyVGrid(columns: columns, alignment: .leading, spacing: Spacing.m) {
                        ForEach(vm.filtered) { movie in
                            Button {
                                Haptics.selection()
                                presented = movie
                            } label: {
                                PosterCard(movie: movie, width: nil, namespace: ns, heroID: nil)
                                    .overlay(alignment: .topTrailing) {
                                        Button {
                                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                                vm.remove(movie)
                                            }
                                        } label: {
                                            Image(systemName: "heart.slash.fill")
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundStyle(.white)
                                                .padding(8)
                                                .background(AppGradients.danger, in: Circle())
                                                .glow(color: AppColors.danger, radius: 8, intensity: 0.4)
                                        }
                                        .padding(8)
                                    }
                            }
                            .buttonStyle(.pressable(scale: 0.95))
                            .transition(.scale(scale: 0.85).combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal, Spacing.l)
                }

                Color.clear.frame(height: ScreenMetrics.tabBarClearance)
            }
            .padding(.top, 8)
        }
        .sheet(item: $presented) { movie in
            MovieDetailsView(movie: movie, namespace: ns) { }
                .presentationBackground(AppColors.background)
                .presentationDragIndicator(.visible)
        }
    }

    private var header: some View {
        HStack {
            Text("Favorites")
                .font(AppTypography.title2)
                .foregroundStyle(AppColors.primaryText)
            Spacer()
            Menu {
                ForEach(FavoritesSort.allCases) { sort in
                    Button {
                        vm.sort = sort
                        Haptics.selection()
                    } label: {
                        Label(sort.rawValue, systemImage: vm.sort == sort ? "checkmark" : "")
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(vm.sort.rawValue)
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 11, weight: .bold))
                }
                .font(AppTypography.subhead)
                .foregroundStyle(.white)
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(.ultraThinMaterial, in: Capsule())
                .overlay(Capsule().stroke(AppColors.glassStroke, lineWidth: 1))
            }
        }
        .padding(.horizontal, Spacing.l)
    }

    private var filters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ChipView(label: "All", isSelected: vm.filter == nil) { vm.filter = nil }
                ForEach(Genre.all) { g in
                    ChipView(label: g.name, isSelected: vm.filter == g) {
                        vm.filter = (vm.filter == g) ? nil : g
                    }
                }
            }
            .padding(.horizontal, Spacing.l)
        }
    }

    private var empty: some View {
        VStack(spacing: 10) {
            Image(systemName: "heart")
                .font(.system(size: 40))
                .foregroundStyle(AppColors.subtleText)
            Text("Nothing here yet.")
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.primaryText)
            Text("Save titles you love and they'll appear here.")
                .font(AppTypography.subhead)
                .foregroundStyle(AppColors.subtleText)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }
}
