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
        print("DIAG bundle: \(Bundle.main.bundlePath)")

        let candidates = [
            Bundle.main.url(forResource: "articles", withExtension: "json"),
            Bundle.main.url(forResource: "articles", withExtension: "json", subdirectory: "Resources"),
        ]

        guard let url = candidates.compactMap({ $0 }).first else {
            diagnostics = log.joined(separator: "\n") + "\n✗ 未找到 articles.json"
            print("DIAG fail: 未找到 articles.json; bundle=\(Bundle.main.bundlePath)")
            return
        }
        log.append("found: \(url.path)")
        print("DIAG found: \(url.path)")

        guard let data = try? Data(contentsOf: url) else {
            diagnostics = log.joined(separator: "\n") + "\n✗ 数据读取失败"
            print("DIAG fail: data read error")
            return
        }
        log.append("size: \(data.count)")
        print("DIAG size: \(data.count)")

        if let list = try? JSONDecoder().decode([Article].self, from: data) {
            articles = list.sorted { $0.date > $1.date }
            log.append("✓ 解码成功 \(list.count) 篇")
            log.append("version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "?")")
            diagnostics = log.joined(separator: "\n")
            print("DIAG ok: decoded \(list.count) articles")
            return
        }

        log.append("✗ 整批解码失败，尝试逐篇容错……")
        print("DIAG fail: batch decode error")
        if let objs = (try? JSONSerialization.jsonObject(with: data)) as? [[String: Any]] {
            print("DIAG JSONSerialization ok, objects=\(objs.count)")
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
                        print("DIAG bad article: \(obj["slug"] ?? "?")")
                    }
                }
            }
            articles = ok.sorted { $0.date > $1.date }
            log.append("✓ 逐篇容错: \(ok.count) 成功, \(failed) 失败")
            print("DIAG row-by-row: ok=\(ok.count) failed=\(failed)")
        } else {
            log.append("✗ JSON 结构异常（非数组）")
            print("DIAG fail: JSONSerialization top-level not array")
        }
        diagnostics = log.joined(separator: "\n")
    }
}