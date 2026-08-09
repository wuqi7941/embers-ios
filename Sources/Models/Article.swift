import Foundation

struct Article: Identifiable, Decodable, Hashable {
    let slug: String
    let title: String
    let date: String
    let tags: [String]
    let excerpt: String
    let readingTime: String
    let content: String

    var id: String { slug }

    /// 2026-08-14 → 2026年8月14日
    var dateDisplay: String {
        let parts = date.split(separator: "-")
        guard parts.count == 3 else { return date }
        return "\(parts[0])年\(Int(parts[1]) ?? 0)月\(Int(parts[2]) ?? 0)日"
    }
}