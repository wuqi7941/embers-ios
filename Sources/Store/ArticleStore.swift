import Foundation
import Combine

final class ArticleStore: ObservableObject {
    @Published var articles: [Article] = []

    init() {
        load()
    }

    func load() {
        guard
            let url = Bundle.main.url(forResource: "articles", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let list = try? JSONDecoder().decode([Article].self, from: data)
        else { return }
        articles = list.sorted { $0.date > $1.date }
    }
}