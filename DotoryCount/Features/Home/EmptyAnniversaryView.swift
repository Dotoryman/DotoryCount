import SwiftUI

struct EmptyAnniversaryView: View {
    let createAction: () -> Void

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    HStack { BrandWordmark(); Spacer() }
                        .padding(.top, 18)
                        .padding(.bottom, 36)
                    VStack(spacing: 12) {
                        Text("소중한 날을\n하나씩 담아요")
                            .font(.system(.largeTitle, design: .serif).weight(.medium))
                            .multilineTextAlignment(.center)
                        Text("하루에 도토리 하나.\n우리의 시간이 한 병 가득 쌓여요.")
                            .font(.subheadline)
                            .lineSpacing(4)
                            .foregroundStyle(AppTheme.secondaryText)
                            .multilineTextAlignment(.center)
                    }
                    JarArtworkView(progress: AnniversaryCalculator.progress(from: .now))
                        .frame(height: max(250, min(350, geometry.size.height - 365)))
                        .padding(.vertical, 12)
                    GlassControlGroup {
                        Button(action: createAction) {
                            HStack {
                                Text("기념일 만들기")
                                Spacer()
                                Image(systemName: "arrow.right")
                            }
                            .font(.headline)
                            .padding(.horizontal, 16)
                            .frame(minHeight: 50)
                        }
                        .modifier(GlassPrimaryActionStyle())
                        .buttonBorderShape(.capsule)
                        .accessibilityIdentifier("create-anniversary-button")
                    }
                    Text("100일과 주년에는 황금도토리가 반짝여요.")
                        .font(.caption)
                        .foregroundStyle(AppTheme.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.top, 18)
                        .padding(.bottom, 28)
                }
                .padding(.horizontal, AppTheme.horizontalPadding)
                .frame(maxWidth: 520)
                .frame(maxWidth: .infinity, minHeight: geometry.size.height)
            }
            .scrollIndicators(.hidden)
        }
        .background { PaperBackdrop() }
        .foregroundStyle(AppTheme.ink)
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview("첫 시작") {
    EmptyAnniversaryView(createAction: {})
}
