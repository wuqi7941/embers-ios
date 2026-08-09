import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: ArticleStore
    @State private var appeared = false

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 18) {
                    header
                    if store.articles.isEmpty {
                        emptyState
                    } else {
                        ForEach(store.articles) { article in
                            ArticleCard(article: article)
                                .opacity(appeared ? 1 : 0)
                                .offset(y: appeared ? 0 : 14)
                        }
                    }
                    footer
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
            .background(Ember.coalGradient.ignoresSafeArea())
            .navigationDestination(for: Article.self) { article in
                ArticleDetailView(article: article)
            }
        }
        .tint(Ember.ember)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) { appeared = true }
        }
    }

    // MARK: - 顶部：余烬牌面

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Color.clear.frame(width: 0, height: 0)
            }
            Text("余烬")
                .font(Ember.display(40))
                .foregroundStyle(Ember.paper)
            Text("E M B E R S")
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .kerning(4)
                .foregroundStyle(Ember.ember)
            Text("观烬 · 烧过、和还在烧的想法")
                .font(.system(size: 15))
                .foregroundStyle(Ember.ash)
                .padding(.top, 2)
        }
        .padding(.top, 26)
        .padding(.bottom, 10)
    }

    private var divider: some View {
        HStack(spacing: 10) {
            EmberTick(height: 14)
            Capsule()
                .fill(Ember.hairline)
                .frame(height: 1)
                .frame(maxWidth: 340)
            Spacer(minLength: 0)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Text("尚未装入文字")
                .font(Ember.serif(18))
                .foregroundStyle(Ember.ash)
            if store.articles.isEmpty && !store.diagnostics.isEmpty {
                Text(store.diagnostics)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(Ember.ash.opacity(0.75))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(Ember.panel, in: RoundedRectangle(cornerRadius: 12))
            } else {
                Text("用 publish 脚本从桌面 workbuddy 打包文章。")
                    .font(.system(size: 13))
                    .foregroundStyle(Ember.ash.opacity(0.6))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }

    private var footer: some View {
        VStack(spacing: 6) {
            EmberTick(height: 10)
            Text("余烬 EMBERS · \(store.articles.count) 篇")
                .font(.system(size: 12))
                .foregroundStyle(Ember.ash.opacity(0.7))
            Text("文字自 workbuddy 打包 · 在 iPhone 上读")
                .font(.system(size: 11))
                .foregroundStyle(Ember.ash.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 30)
    }
}

// MARK: - 文章卡片

struct ArticleCard: View {
    let article: Article

    var body: some View {
        NavigationLink(value: article) {
            HStack(alignment: .top, spacing: 14) {
                EmberTick(height: 42)
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Text(article.dateDisplay)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Ember.ash)
                        Text("·")
                            .foregroundStyle(Ember.ash.opacity(0.4))
                        Text(article.readingTime)
                            .font(.system(size: 12))
                            .foregroundStyle(Ember.ash)
                        Spacer(minLength: 0)
                    }
                    Text(article.title)
                        .font(Ember.display(22))
                        .foregroundStyle(Ember.paper)
                        .lineLimit(1)
                    Text(article.excerpt)
                        .font(.system(size: 14))
                        .foregroundStyle(Ember.ash)
                        .lineLimit(2)
                        .lineSpacing(4)
                    tagRow
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Ember.panel)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Ember.hairline, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(article.title)
    }

    private var tagRow: some View {
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
        .padding(.top, 2)
    }
}