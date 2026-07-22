package com.rogbook.focuscat

import android.appwidget.AppWidgetManager
import android.content.Context
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * 홈 화면 위젯 — 고양이와 오늘의 집중 기록.
 * 값은 Flutter 쪽(home_widget)이 SharedPreferences에 써 둔 것을 읽는다.
 * iOS 위젯과 마찬가지로 애니메이션은 불가능해 고양이는 정지 그림이다.
 */
class FocusCatWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: android.content.SharedPreferences,
    ) {
        val today = widgetData.getInt("todayCount", 0)
        val minutes = widgetData.getInt("totalMinutes", 0)

        appWidgetIds.forEach { id ->
            val views = RemoteViews(context.packageName, R.layout.focuscat_widget).apply {
                setTextViewText(
                    R.id.message,
                    if (today > 0) "오늘 ${today}번 집중" else "오늘 첫 집중 대기 중",
                )
                setTextViewText(R.id.total, "누적 ${minutes}분")
                // 탭하면 앱이 열리면서 곧바로 집중이 시작된다.
                setOnClickPendingIntent(
                    R.id.root,
                    HomeWidgetLaunchIntent.getActivity(
                        context,
                        MainActivity::class.java,
                        Uri.parse("focuscat://start"),
                    ),
                )
            }
            appWidgetManager.updateAppWidget(id, views)
        }
    }
}
