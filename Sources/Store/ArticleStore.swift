import Foundation
import Combine

final class ArticleStore: ObservableObject {
    @Published var articles: [Article] = []
    @Published var diagnostics: String = ""

    init() {
        load()
    }

    func load() {
        var log: [String] = []
        log.append("bundle: \(Bundle.main.bundlePath)")

        let candidates = [
            Bundle.main.url(forResource: "articles", withExtension: "json"),
            Bundle.main.url(forResource: "articles", withExtension: "json", subdirectory: "Resources"),
        ]

        guard let url = candidates.compactMap({ $0 }).first else {
            diagnostics = log.joined(separator: "\n") + "\n✗ 未找到 articles.json"
            return
        }
        log.append("found: \(url.path)")

        guard let data = try? Data(contentsOf: url) else {
            diagnostics = log.joined(separator: "\n") + "\n✗ 数据读取失败"
            return
        }
        log.append("size: \(data.count)")

        if let list = try? JSONDecoder().decode([Article].self, from: data) {
            articles = list.sorted { $0.date > $1.date }
            log.append("✓ 解码成功 \(list.count) 篇")
            log.append("version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "?")")
            diagnostics = log.joined(separator: "\n")
            return
        }

        log.append("✗ 整批解码失败，尝试逐篇容错……")
        if let objs = (try? JSONSerialization.jsonObject(with: data)) as? [[String: Any]] {
            var ok: [Article] = []
            var failed = 0
            for obj in objs {
                if let d = try? JSONSerialization.data(withJSONObject: obj),
                   let a = try? JSONDecoder().decode(Article.self, from: d) {
                    ok.append(a)
                } else {
                    failed += 1
                    if failed <= 3 {
                        log.append("  坏篇: \(obj["slug"] ?? "?")")
                    }
                }
            }
            articles = ok.sorted { $0.date > $1.date }
            log.append("✓ 逐篇容错: \(ok.count) 成功, \(failed) 失败")
        } else {
            log.append("✗ JSON 结构异常（非数组）")
        }
        diagnostics = log.joined(separator: "\n")
    }
}