import SwiftUI

struct ArticleDetailView: View {
    let article: Article
    private let blocks: [MarkdownBlock]

    init(article: Article) {
        self.article = article
        self.blocks = MarkdownParser.parse(article.content)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                meta
                titleBlock
                divider
                ForEach(Array(blocks.enumerated()), id: \.offset) { _, block in
                    blockView(block)
                }
                colophon
            }
            .padding(.horizontal, 22)
            .padding(.top, 12)
            .padding(.bottom, 60)
        }
        .background(Ember.coalGradient.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Ember.coal, for: .navigationBar)
    }

    private var meta: some View {
        HStack(spacing: 8) {
            EmberTick(height: 16)
            Text(article.dateDisplay)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Ember.emberGold)
            Text("·")
                .foregroundStyle(Ember.ash.opacity(0.4))
            Text(article.readingTime)
                .font(.system(size: 13))
                .foregroundStyle(Ember.ash)
            Spacer(minLength: 0)
        }
        .padding(.top, 6)
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(article.title)
                .font(Ember.display(32))
                .foregroundStyle(Ember.paper)
                .lineSpacing(4)
            HStack(spacing: 8) {
                ForEach(article.tags, id: \.self) { tag in
                    Text(tag)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Ember.emberGold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Ember.ember.opacity(0.12))
                        )
                }
            }
        }
    }

    private var divider: some View {
        HStack(spacing: 10) {
            EmberTick(height: 18)
            Capsule()
                .fill(Ember.hairline)
                .frame(height: 1)
            Spacer(minLength: 0)
        }
        .padding(.vertical, 4)
    }

    /// 落款：书页合上时的一点余烬
    private var colophon: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(Ember.ember.opacity(0.16))
                    .frame(width: 64, height: 64)
                Circle()
                    .fill(Ember.emberGradient)
                    .frame(width: 34, height: 34)
                    .shadow(color: Ember.ember.opacity(0.6), radius: 14)
            }
            Text("余烬 · EMBERS")
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .kerning(3)
                .foregroundStyle(Ember.ash)
            Text("读完这一段，火还亮着。")
                .font(Ember.serifItalic(13))
                .foregroundStyle(Ember.ash.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 44)
    }
}