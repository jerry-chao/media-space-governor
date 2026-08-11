import Photos
import SwiftUI
import MediaSpaceGovernorCore

struct ContentView: View {
    @State private var state: ScanState = .requestingAccess
    @State private var measuredSizes: [String: LocalSizeOutcome] = [:]
    @State private var measurementProgress = MeasurementProgress()
    @State private var measurementTask: Task<Void, Never>?

    var body: some View {
        NavigationStack {
            Group {
                switch state {
                case .requestingAccess, .scanning:
                    ProgressView(state.message)
                case .accessDenied:
                    ContentUnavailableView(
                        "需要照片访问权限",
                        systemImage: "photo.on.rectangle.angled",
                        description: Text("请在“设置 → 隐私与安全性 → 照片”中允许 MediaGovernorDemo 访问照片。")
                    )
                case let .ready(result):
                    resultsList(result)
                }
            }
            .navigationTitle("Media Space Governance")
        }
        .task {
            await loadInventory()
        }
    }

    private func resultsList(_ result: ScanResult) -> some View {
        List {
            Section {
                Text(result.isLimitedAccess ? "有限访问 · 已扫描 \(result.resources.count) 项（部分）" : "已扫描 \(result.resources.count) 项")
                    .font(.headline)
                Text("仅使用本机元数据分类；不会上传、删除或读取媒体内容。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("分类结果") {
                ForEach(result.resources.indices, id: \.self) { index in
                    let resource = result.resources[index]
                    let itemState = result.states[index]
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(resource.contentHint.rawValue) · \(resource.mediaType.rawValue)")
                            .font(.headline)
                        Text("热度 \(String(describing: itemState.usageHeat)) · \(itemState.cleanupEligibility.rawValue)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(sizeLine(for: resource.id))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section("空间测量") {
                if measurementProgress.isRunning {
                    Text("正在测量 \(measurementProgress.completed)/\(measurementProgress.total)…")
                    Button("停止测量") {
                        measurementTask?.cancel()
                        measurementProgress.isRunning = false
                    }
                }
                Text("已测得本机原文件空间：\(bytes(measuredTotal))")
                Text("仅统计本机可用的原文件；iCloud 未下载内容不计入。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("建议 (\(result.recommendations.count))") {
                ForEach(result.recommendations, id: \.id) { recommendation in
                    Text(recommendationLine(recommendation))
                }
            }
        }
    }

    private func recommendationLine(_ recommendation: GovernanceRecommendation) -> String {
        switch recommendation.action {
        case .archive:
            return "归档 · \(recommendation.resourceID)"
        case .cleanup:
            let saving = recommendation.spaceSavingBytes.map(bytes) ?? "大小未测得"
            return "清理 · \(recommendation.resourceID) · 节省 \(saving)"
        }
    }

    private func sizeLine(for resourceID: String) -> String {
        switch measuredSizes[resourceID] {
        case .measured(let byteCount):
            "本机原文件 \(bytes(byteCount))"
        case .unavailable:
            "本机无原文件，未计入"
        case nil:
            "大小未测量"
        }
    }

    private var measuredTotal: UInt64 {
        measuredSizes.values.reduce(0) { total, outcome in
            if case .measured(let bytes) = outcome { return total + bytes }
            return total
        }
    }

    private func bytes(_ value: UInt64) -> String {
        ByteCountFormatter.string(fromByteCount: Int64(value), countStyle: .file)
    }

    @MainActor
    private func loadInventory() async {
        measurementTask?.cancel()
        measurementTask = nil

        let authorization = await PhotoLibraryScanner.requestAccess()
        guard authorization == .authorized || authorization == .limited else {
            state = .accessDenied
            return
        }

        state = .scanning
        let scan = await PhotoLibraryScanner.scan(isLimitedAccess: authorization == .limited)
        let resources = scan.items.compactMap { LibraryInventory.resource(for: $0) }

        let now = Date()
        let engine = GovernanceEngine()
        let candidates = engine.measurementCandidates(resources: resources, now: now)

        measuredSizes = [:]
        measurementProgress = MeasurementProgress(total: candidates.count, isRunning: !candidates.isEmpty)
        state = .ready(
            ScanResult(
                resources: resources,
                states: resources.map { engine.classify($0, archiveRecord: nil, now: now) },
                recommendations: engine.recommendations(resources: resources, archiveRecords: [], now: now),
                isLimitedAccess: scan.isLimitedAccess
            )
        )

        guard !candidates.isEmpty else { return }
        let task = Task { @MainActor in
            let measurer = LocalSizeMeasurer()
            var completed = 0
            for resource in candidates {
                if Task.isCancelled { break }
                let outcome = await measure(resource, measurer: measurer)
                if Task.isCancelled { break }
                measuredSizes[resource.id] = outcome
                completed += 1
                measurementProgress.completed = completed
            }
            measurementProgress.isRunning = false

            // Feed measured sizes back so recommendations and totals reflect
            // the real Space Saving Opportunity, then recompute once.
            if case .ready(let result) = state {
                let updated = result.resources.map { resource in
                    if case .measured(let bytes) = measuredSizes[resource.id] {
                        return resource.withMeasuredSize(bytes)
                    }
                    return resource
                }
                state = .ready(
                    ScanResult(
                        resources: updated,
                        states: result.states,
                        recommendations: engine.recommendations(
                            resources: updated,
                            archiveRecords: [],
                            now: now
                        ),
                        isLimitedAccess: result.isLimitedAccess
                    )
                )
            }
        }
        measurementTask = task
    }

    private nonisolated func measure(_ resource: MediaResource, measurer: LocalSizeMeasurer) async -> LocalSizeOutcome {
        guard let asset = PHAsset.fetchAssets(withLocalIdentifiers: [resource.id], options: nil).firstObject else {
            return .unavailable
        }
        return await measurer.measure(asset)
    }
}

private enum ScanState {
    case requestingAccess
    case scanning
    case accessDenied
    case ready(ScanResult)

    var message: String {
        switch self {
        case .requestingAccess:
            "正在请求照片访问权限…"
        case .scanning:
            "正在扫描本机照片和视频…"
        case .accessDenied, .ready:
            ""
        }
    }
}

private struct ScanResult {
    let resources: [MediaResource]
    let states: [ResourceGovernanceState]
    let recommendations: [GovernanceRecommendation]
    let isLimitedAccess: Bool
}

private struct MeasurementProgress {
    var completed = 0
    var total = 0
    var isRunning = false
}

#Preview {
    ContentView()
}
