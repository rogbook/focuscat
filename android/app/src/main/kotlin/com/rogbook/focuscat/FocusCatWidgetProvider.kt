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
        // 문구는 앱이 기기 언어로 만들어 둔 것을 그대로 쓴다 — 위젯이 번역
        // 파일을 따로 갖지 않아도 앱의 언어를 그대로 따라간다.
        val message = widgetData.getString("message", "") ?: ""
        val total = widgetData.getString("total", "") ?: ""

        appWidgetIds.forEach { id ->
            val views = RemoteViews(context.packageName, R.layout.focuscat_widget).apply {
                setTextViewText(R.id.message, message)
                setTextViewText(R.id.total, total)
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
