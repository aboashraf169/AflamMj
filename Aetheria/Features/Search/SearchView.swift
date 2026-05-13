import SwiftUI

struct SearchView: View {
    @StateObject private var vm = SearchViewModel()
    @Namespace private var ns
    @State private var presented:  Movie? = nil
    @State private var playing:    Movie? = nil
    @FocusState private var isFieldFocused: Bool

    private let columns = [GridItem(.adaptive(minimum: ScreenMetrics.gridPosterMin,
                                              maximum: ScreenMetrics.gridPosterMax),
                                    spacing: Spacing.m)]

    var body: some View {
        VStack(spacing: 14) {
            header
            searchField
            genreChips

            if vm.query.isEmpty && vm.selectedGenre == nil {
                discoveryScroll
            } else {
                resultsGrid
            }
        }
        .padding(.top, 8)
        .sheet(item: $presented) { movie in
            MovieDetailsView(movie: movie, namespace: ns) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    playing = movie
                }
            }
            .presentationBackground(AppColors.background)
            .presentationDragIndicator(.visible)
        }
        .fullScreenCover(item: $playing) { movie in
            WebPlayerView(movie: movie)
        }
    }

    private var header: some View {
        HStack {
            Text("Search")
                .font(AppTypography.title2)
                .foregroundStyle(AppColors.primaryText)
            Spacer()
        }
        .padding(.horizontal, Spacing.l)
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(AppColors.subtleText)
            TextField("Movies, shows, genres…", text: $vm.query)
                .focused($isFieldFocused)
                .submitLabel(.search)
                .onSubmit { vm.commitRecent() }
                .font(AppTypography.body)
                .foregroundStyle(AppColors.primaryText)
                .tint(AppColors.aqua)
            if !vm.query.isEmpty {
                Button {
                    Haptics.tap()
                    vm.query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(AppColors.mutedText)
                }
            }
            if vm.isSearching {
                ProgressView().scaleEffect(0.7).tint(AppColors.aqua)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .glassBackground(cornerRadius: Radius.l)
        .overlay(
            RoundedRectangle(cornerRadius: Radius.l, style: .continuous)
                .stroke(isFieldFocused ? AppColors.violet.opacity(0.6) : .clear, lineWidth: 1.5)
        )
        .animation(.smooth(duration: 0.2), value: isFieldFocused)
        .padding(.horizontal, Spacing.l)
    }

    private var genreChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ChipView(label: "All", isSelected: vm.selectedGenre == nil) {
                    vm.selectedGenre = nil
                }
                ForEach(Genre.all) { genre in
                    ChipView(label: genre.name, isSelected: vm.selectedGenre == genre) {
                        vm.selectedGenre = (vm.selectedGenre == genre) ? nil : genre
                    }
                }
            }
            .padding(.horizontal, Spacing.l)
        }
    }

    private var discoveryScroll: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: Spacing.l) {
                if !vm.recent.isEmpty {
                    SectionHeader(title: "Recent", action: {})
                    FlexWrap(vm.recent) { item in
                        ChipView(label: item, icon: "clock") {
                            vm.query = item
                        }
                    }
                    .padding(.horizontal, Spacing.l)
                }

                SectionHeader(title: "Trending searches", action: {})
                FlexWrap(vm.trending) { item in
                    ChipView(label: item, icon: "flame.fill") {
                        vm.query = item
                    }
                }
                .padding(.horizontal, Spacing.l)

                Color.clear.frame(height: ScreenMetrics.tabBarClearance)
            }
            .padding(.top, 4)
        }
    }

    private var resultsGrid: some View {
        ScrollView(showsIndicators: false) {
            LazyVGrid(columns: columns, alignment: .leading, spacing: Spacing.m) {
                ForEach(vm.results) { movie in
                    Button {
                        Haptics.selection()
                        presented = movie
                    } label: {
                        PosterCard(movie: movie, width: nil, namespace: ns, heroID: nil)
                    }
                    .buttonStyle(.pressable(scale: 0.96))
                }
            }
            .padding(.horizontal, Spacing.l)
            .padding(.top, 4)
            .padding(.bottom, ScreenMetrics.tabBarClearance)

            if vm.results.isEmpty && !vm.isSearching {
                VStack(spacing: 8) {
                    Image(systemName: "sparkle.magnifyingglass")
                        .font(.system(size: 32))
                        .foregroundStyle(AppColors.subtleText)
                    Text("No results.")
                        .font(AppTypography.headline)
                        .foregroundStyle(AppColors.primaryText)
                    Text("Try a different keyword or genre.")
                        .font(AppTypography.subhead)
                        .foregroundStyle(AppColors.subtleText)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 50)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()
        SearchView()
    }
    .preferredColorScheme(.dark)
}

// MARK: - Tiny flex layout for chips

private struct FlexWrap<Content: View>: View {
    let items: [String]
    let content: (String) -> Content

    init(_ items: [String], @ViewBuilder content: @escaping (String) -> Content) {
        self.items = items
        self.content = content
    }

    var body: some View {
        FlowLayout(spacing: 6) {
            ForEach(items, id: \.self) { content($0) }
        }
    }
}

private struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var width: CGFloat = 0
        var height: CGFloat = 0
        var rowWidth: CGFloat = 0
        var rowHeight: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if rowWidth + size.width > maxWidth {
                width = max(width, rowWidth)
                height += rowHeight + spacing
                rowWidth = size.width + spacing
                rowHeight = size.height
            } else {
                rowWidth += size.width + spacing
                rowHeight = max(rowHeight, size.height)
            }
        }
        width = max(width, rowWidth)
        height += rowHeight
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x: CGFloat = bounds.minX
        var y: CGFloat = bounds.minY
        var rowHeight: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            view.place(at: CGPoint(x: x, y: y), proposal: .init(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
