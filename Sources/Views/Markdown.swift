import SwiftUI

// MARK: - 极简 Markdown 块解析
// 文章是散文：标题 / 段落 / 引用 / 列表 / 行内粗体斜体。足够，不需要完整解析器。

enum MarkdownBlock: Equatable {
    case heading1(String)
    case heading2(String)
    case paragraph(String)
    case quote(String)
    case list([String])
}

enum MarkdownParser {
    static func parse(_ markdown: String) -> [MarkdownBlock] {
        var blocks: [MarkdownBlock] = []
        var listBuffer: [String] = []

        func flushList() {
            guard !listBuffer.isEmpty else { return }
            blocks.append(.list(listBuffer))
            listBuffer = []
        }

        for rawLine in markdown.components(separatedBy: "\n") {
            let line = rawLine.trimmingCharacters(in: .whitespaces)
            if line.isEmpty {
                flushList()
                continue
            }
            if line.hasPrefix("# ") {
                flushList()
                blocks.append(.heading1(String(line.dropFirst(2))))
            } else if line.hasPrefix("## ") {
                flushList()
                blocks.append(.heading2(String(line.dropFirst(3))))
            } else if line.hasPrefix("> ") {
                flushList()
                blocks.append(.quote(String(line.dropFirst(2))))
            } else if line.hasPrefix("- ") || line.hasPrefix("* ") {
                listBuffer.append(String(line.dropFirst(2)))
            } else if let match = line.range(of: #"^\d{1,3}[\.、]"#, options: .regularExpression) {
                listBuffer.append(String(line[match.upperBound...]))
            } else {
                flushList()
                blocks.append(.paragraph(line))
            }
        }
        flushList()
        return blocks
    }
}

// MARK: - 行内渲染（**加粗** / *斜体* / `等宽`）

func inlineText(_ string: String) -> Text {
    if let attr = try? AttributedString(markdown: string) {
        return Text(attr)
    }
    return Text(string)
}

// MARK: - 块渲染

@ViewBuilder
func blockView(_ block: MarkdownBlock) -> some View {
    switch block {
    case .heading1(let text):
        inlineText(text)
            .font(Ember.display(30))
            .foregroundStyle(Ember.paper)
            .lineSpacing(6)
            .padding(.bottom, 20)

    case .heading2(let text):
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                EmberTick(height: 22)
                inlineText(text)
                    .font(Ember.display(21))
                    .foregroundStyle(Ember.paper)
            }
        }
        .padding(.top, 26)
        .padding(.bottom, 14)

    case .paragraph(let text):
        inlineText(text)
            .font(.system(size: 17, weight: .regular))
            .foregroundStyle(Ember.paper.opacity(0.92))
            .lineSpacing(8)

    case .quote(let text):
        HStack(alignment: .top, spacing: 12) {
            RoundedRectangle(cornerRadius: 1.5)
                .fill(Ember.ember.opacity(0.55))
                .frame(width: 2.5)
            inlineText(text)
                .font(Ember.serifItalic(16))
                .foregroundStyle(Ember.ash)
                .lineSpacing(6)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Ember.panel, in: RoundedRectangle(cornerRadius: 12))

    case .list(let items):
        VStack(alignment: .leading, spacing: 10) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Circle()
                        .fill(Ember.ember.opacity(0.7))
                        .frame(width: 4, height: 4)
                        .padding(.top, 7)
                    inlineText(item)
                        .font(.system(size: 17))
                        .foregroundStyle(Ember.paper.opacity(0.92))
                        .lineSpacing(6)
                }
            }
        }
    }
}