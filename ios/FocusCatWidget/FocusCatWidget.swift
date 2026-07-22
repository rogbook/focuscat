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
    let todayCount: Int
    let totalMinutes: Int
}

struct Provider: TimelineProvider {
    private func read() -> CatEntry {
        let defaults = UserDefaults(suiteName: appGroup)
        return CatEntry(
            date: Date(),
            todayCount: defaults?.integer(forKey: "todayCount") ?? 0,
            totalMinutes: defaults?.integer(forKey: "totalMinutes") ?? 0
        )
    }

    func placeholder(in context: Context) -> CatEntry {
        CatEntry(date: Date(), todayCount: 0, totalMinutes: 0)
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

    private var message: String {
        entry.todayCount > 0 ? "오늘 \(entry.todayCount)번 집중" : "오늘 첫 집중 대기 중"
    }

    var body: some View {
        VStack(spacing: 6) {
            Image("Cat")
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 62)
            Text(message)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.primary)
            Text("누적 \(entry.totalMinutes)분")
                .font(.system(size: 11))
                .foregroundStyle(teal)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
    CatEntry(date: .now, todayCount: 0, totalMinutes: 0)
    CatEntry(date: .now, todayCount: 3, totalMinutes: 75)
}
