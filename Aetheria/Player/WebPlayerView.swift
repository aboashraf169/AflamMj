import SwiftUI
import WebKit

// MARK: - Player view

struct WebPlayerView: View {
    let movie: Movie
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.black.ignoresSafeArea()

            WebView(url: movie.streamURL)
                .ignoresSafeArea()

            // Close button
            Button {
                Haptics.tap()
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(10)
                    .background(.ultraThinMaterial, in: Circle())
                    .overlay(Circle().stroke(AppColors.glassStroke, lineWidth: 1))
            }
            .buttonStyle(.pressable)
            .padding(.top, 52)
            .padding(.leading, Spacing.l)
        }
        .preferredColorScheme(.dark)
        .statusBarHidden(true)
        .persistentSystemOverlays(.hidden)
        .onAppear {
            // Unlock all orientations when player opens
            AppDelegate.allowAllOrientations = true
            let windowScene = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }.first
            windowScene?.requestGeometryUpdate(
                .iOS(interfaceOrientations: .all)
            )
        }
        .onDisappear {
            // Lock back to portrait when player closes
            AppDelegate.allowAllOrientations = false
            let windowScene = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }.first
            windowScene?.requestGeometryUpdate(
                .iOS(interfaceOrientations: .portrait)
            )
        }
    }
}

// MARK: - WKWebView wrapper

private struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.websiteDataStore = .default()

        let wv = WKWebView(frame: .zero, configuration: config)
        wv.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
        wv.backgroundColor = .black
        wv.scrollView.backgroundColor = .black
        wv.isOpaque = false
        wv.scrollView.isScrollEnabled = false

        var request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 30)
        request.addValue("1", forHTTPHeaderField: "Save-Data")
        wv.load(request)
        return wv
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

// MARK: - Preview

#Preview {
    let movie = Movie(
        id: "1266127", title: "A Minecraft Movie", tagline: "", synopsis: "",
        year: "2025", duration: 100, rating: 7.0, kind: .movie,
        genres: [.action], cast: [], director: "",
        isExclusive: false,
        streamURL: URL(string: "https://streamimdb.ru/embed/movie/1266127")!,
        trailerURL: nil, availableQualities: [.fhd], subtitleLanguages: [], seasons: []
    )
    WebPlayerView(movie: movie)
}
