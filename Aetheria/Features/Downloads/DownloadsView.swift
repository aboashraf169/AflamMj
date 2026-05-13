import SwiftUI

// MARK: - Preview

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()
        DownloadsView()
    }
    .preferredColorScheme(.dark)
}

struct DownloadsView: View {
    @StateObject private var vm = DownloadsViewModel()

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: Spacing.l) {
                HStack {
                    Text("Library")
                        .font(AppTypography.title2)
                        .foregroundStyle(AppColors.primaryText)
                    Spacer()
                }
                .padding(.horizontal, Spacing.l)

                storageCard
                    .padding(.horizontal, Spacing.l)

                ForEach(vm.items) { row in
                    DownloadRowView(row: row,
                                    onToggle: { vm.toggle(row) },
                                    onRemove: { vm.remove(row) })
                        .padding(.horizontal, Spacing.l)
                }

                Color.clear.frame(height: ScreenMetrics.tabBarClearance)
            }
            .padding(.top, 12)
        }
    }

    private var storageCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "internaldrive.fill")
                        .foregroundStyle(AppColors.aqua)
                    Text("Storage")
                        .font(AppTypography.headline)
                        .foregroundStyle(AppColors.primaryText)
                    Spacer()
                    Text("\(Int(vm.totalUsedMB / 1024)) / \(Int(vm.totalLimitMB / 1024)) GB")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.subtleText)
                        .lineLimit(1)
                }
                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule().fill(.white.opacity(0.08))
                        Capsule()
                            .fill(AppGradients.accent)
                            .frame(width: proxy.size.width * (vm.totalUsedMB / vm.totalLimitMB))
                            .glow(color: AppColors.violet, radius: 12, intensity: 0.5)
                    }
                }
                .frame(height: 8)
            }
        }
    }
}

private struct DownloadRowView: View {
    let row: DownloadRow
    let onToggle: () -> Void
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: Spacing.s) {
            ZStack {
                AppGradients.posterFallback(for: row.movie.id.hashValue)
                Text(row.quality.rawValue)
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 5).padding(.vertical, 2)
                    .background(.ultraThinMaterial, in: Capsule())
                    .padding(5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            }
            .frame(width: 70, height: 105)
            .clipShape(RoundedRectangle(cornerRadius: Radius.s, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                Text(row.movie.title)
                    .font(AppTypography.subhead)
                    .foregroundStyle(AppColors.primaryText)
                    .lineLimit(1)
                Text(statusLabel)
                    .font(AppTypography.caption)
                    .foregroundStyle(statusColor)

                if row.status == .downloading || row.status == .paused {
                    ProgressView(value: row.progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: AppColors.violet))
                        .scaleEffect(x: 1, y: 1.4, anchor: .center)
                }

                HStack(spacing: 8) {
                    Button {
                        Haptics.tap(); onToggle()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: toggleIcon)
                            Text(toggleLabel)
                        }
                        .font(AppTypography.caption)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(AppGradients.accent, in: Capsule())
                    }
                    .buttonStyle(.pressable)
                    .opacity(row.status == .completed ? 0.4 : 1)
                    .disabled(row.status == .completed)

                    Button {
                        Haptics.warning(); onRemove()
                    } label: {
                        Image(systemName: "trash.fill")
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.danger)
                            .padding(6)
                            .background(.ultraThinMaterial, in: Capsule())
                    }
                    .buttonStyle(.pressable)

                    Spacer()
                    Text("\(Int(row.sizeMB * row.progress)) / \(Int(row.sizeMB)) MB")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.mutedText)
                }
            }
        }
        .padding(10)
        .glassBackground(cornerRadius: Radius.m)
    }

    private var statusLabel: String {
        switch row.status {
        case .downloading: "Downloading • \(Int(row.progress * 100))%"
        case .paused:      "Paused • \(Int(row.progress * 100))%"
        case .queued:      "Queued"
        case .completed:   "Ready to watch offline"
        case .failed:      "Failed"
        }
    }

    private var statusColor: Color {
        switch row.status {
        case .downloading: AppColors.aqua
        case .paused:      AppColors.warning
        case .queued:      AppColors.subtleText
        case .completed:   AppColors.success
        case .failed:      AppColors.danger
        }
    }

    private var toggleIcon: String {
        row.status == .downloading ? "pause.fill" : "play.fill"
    }

    private var toggleLabel: String {
        row.status == .downloading ? "Pause" : "Resume"
    }
}
