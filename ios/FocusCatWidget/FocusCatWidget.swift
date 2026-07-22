//
//  FocusCatWidget.swift
//  FocusCatWidget
//
//  홈 화면 위젯 — 고양이와 오늘 집중 기록.
//  값은 Flutter 쪽(home_widget)이 App Group의 UserDefaults에 써 둔 것을 읽는다.
//  위젯은 애니메이션을 재생할 수 없어 고양이는 정지 그림(Cat.imageset)이다.
//

import WidgetKit
import SwiftUI

private let appGroup = "group.com.rogbook.focuscat"
private let teal = Color(red: 0x50 / 255, green: 0xC2 / 255, blue: 0xC9 / 255)

struct CatEntry: TimelineEntry {
    let date: Date
    /// 문구는 앱이 기기 언어로 만들어 App Group에 써 둔 것을 그대로 쓴다.
    /// 위젯이 번역 파일을 따로 갖지 않아도 앱의 언어를 그대로 따라간다.
    let message: String
    let total: String
}

struct Provider: TimelineProvider {
    private func read() -> CatEntry {
        let defaults = UserDefaults(suiteName: appGroup)
        return CatEntry(
            date: Date(),
            message: defaults?.string(forKey: "message") ?? "",
            total: defaults?.string(forKey: "total") ?? ""
        )
    }

    func placeholder(in context: Context) -> CatEntry {
        CatEntry(date: Date(), message: "", total: "")
    }

    func getSnapshot(in context: Context, completion: @escaping (CatEntry) -> Void) {
        completion(read())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CatEntry>) -> Void) {
        // 앱이 세션을 기록할 때마다 직접 갱신을 요청하므로 타임라인은 한 칸이면
        // 충분하다. 자정에 '오늘'이 바뀌니 그때 한 번 다시 그린다.
        let midnight = Calendar.current.nextDate(
            after: Date(),
            matching: DateComponents(hour: 0, minute: 0),
            matchingPolicy: .nextTime
        ) ?? Date().addingTimeInterval(3600)
        completion(Timeline(entries: [read()], policy: .after(midnight)))
    }
}

struct FocusCatWidgetEntryView: View {
    var entry: CatEntry

    var body: some View {
        VStack(spacing: 6) {
            Image("Cat")
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 62)
            Text(entry.message)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.primary)
            Text(entry.total)
                .font(.system(size: 11))
                .foregroundStyle(teal)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // 탭하면 앱이 열리면서 곧바로 집중이 시작된다.
        // homeWidget 쿼리는 home_widget 플러그인이 위젯 URL을 가려내는 표식이라
        // 빼면 앱이 열리기만 하고 아무 일도 일어나지 않는다(isWidgetUrl 참고).
        .widgetURL(URL(string: "focuscat://start?homeWidget=true"))
    }
}

struct FocusCatWidget: Widget {
    let kind: String = "FocusCatWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                FocusCatWidgetEntryView(entry: entry)
                    .containerBackground(Color(white: 1.0), for: .widget)
            } else {
                FocusCatWidgetEntryView(entry: entry).padding().background()
            }
        }
        .configurationDisplayName("집중냥이")
        .description("고양이와 오늘의 집중 기록을 봅니다.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    FocusCatWidget()
} timeline: {
    CatEntry(date: .now, message: "오늘 첫 집중 대기 중", total: "누적 집중 0분")
    CatEntry(date: .now, message: "오늘 3번 집중했어요", total: "누적 집중 75분")
}
