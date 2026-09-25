package com.example.mobile

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

/**
 * Renders the day-streak home-screen widget from data `StreakWidgetService`
 * (lib/core/widget/streak_widget_service.dart) pushes via the `home_widget`
 * plugin. Refresh is app-driven only (see that class's docstring) — this
 * provider never fetches anything itself, only re-reads whatever was last
 * written to `HomeWidgetPlugin`'s shared prefs.
 */
class StreakWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        val prefs = HomeWidgetPlugin.getData(context)
        val currentStreak = prefs.getInt("currentStreak", 0)
        val last7Days = prefs.getString("last7Days", "0000000") ?: "0000000"

        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.streak_widget)
            views.setTextViewText(R.id.streak_widget_count, currentStreak.toString())
            views.setTextViewText(
                R.id.streak_widget_label,
                context.getString(R.string.streak_widget_label),
            )

            val dotIds = intArrayOf(
                R.id.streak_widget_dot_0,
                R.id.streak_widget_dot_1,
                R.id.streak_widget_dot_2,
                R.id.streak_widget_dot_3,
                R.id.streak_widget_dot_4,
                R.id.streak_widget_dot_5,
                R.id.streak_widget_dot_6,
            )
            for (i in dotIds.indices) {
                val active = last7Days.getOrNull(i) == '1'
                views.setInt(
                    dotIds[i],
                    "setBackgroundResource",
                    if (active) {
                        R.drawable.streak_widget_dot_active
                    } else {
                        R.drawable.streak_widget_dot_inactive
                    },
                )
            }

            val openApp = Intent(context, MainActivity::class.java)
            val pendingIntent = PendingIntent.getActivity(
                context,
                appWidgetId,
                openApp,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            views.setOnClickPendingIntent(R.id.streak_widget_root, pendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
