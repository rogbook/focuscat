package com.rogbook.focuscat

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
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
                setOnClickPendingIntent(R.id.root, launchIntent(context))
            }
            appWidgetManager.updateAppWidget(id, views)
        }
    }

    /// 위젯 탭으로 앱을 여는 인텐트.
    ///
    /// home_widget이 만들어 주는 것을 쓰지 않고 직접 만드는 이유는 플래그
    /// 때문이다. 플래그가 없으면 안드로이드가 상황에 따라 MainActivity를
    /// 하나 더 띄우고, 그러면 Flutter 엔진이 둘이 되어 타이머와 배경음이
    /// 각각 돌아간다(실기기에서 그렇게 겹쳐 돌았다). SINGLE_TOP과
    /// CLEAR_TOP을 함께 걸어 이미 떠 있는 화면을 재사용하게 한다.
    private fun launchIntent(context: Context): PendingIntent {
        val intent = Intent(context, MainActivity::class.java).apply {
            action = HomeWidgetLaunchIntent.HOME_WIDGET_LAUNCH_ACTION
            data = Uri.parse("focuscat://start")
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                Intent.FLAG_ACTIVITY_SINGLE_TOP or
                Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        return PendingIntent.getActivity(
            context,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }
}
