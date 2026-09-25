package com.example.mobile

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class StreakWidgetProvider : AppWidgetProvider() {
    override fun onAppWidgetOptionsChanged(
        context: Context,
        manager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle,
    ) {
        // Launcher calls this after resize, not onUpdate(). Re-render now so
        // layout switches between square and wide without waiting 30 minutes.
        onUpdate(context, manager, intArrayOf(appWidgetId))
    }

    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        val prefs = HomeWidgetPlugin.getData(context)
        val streak = prefs.getInt("current_streak", 0)
        val heatmap = prefs.getString("weekly_heatmap", "0000000") ?: "0000000"
        val message = prefs.getString("message_text", "Bacaaa yuk!") ?: "Bacaaa yuk!"
        val background = prefs.getString("background_res_name", "widget_bg_calm_a") ?: "widget_bg_calm_a"
        val mascot = prefs.getString("mascot_res_name", "mascot_calm_a") ?: "mascot_calm_a"

        for (id in ids) {
            val options = manager.getAppWidgetOptions(id)
            val width = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH)
            val height = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT)
            val layout = if (width >= height * 1.5) R.layout.streak_widget_medium else R.layout.streak_widget_small
            val views = RemoteViews(context.packageName, layout)
            val backgroundId = context.resources.getIdentifier(background, "drawable", context.packageName)
            val mascotId = context.resources.getIdentifier(mascot, "drawable", context.packageName)
            if (backgroundId != 0) views.setInt(R.id.streak_widget_root, "setBackgroundResource", backgroundId)
            if (mascotId != 0) views.setImageViewResource(R.id.streak_widget_mascot, mascotId)
            views.setTextViewText(R.id.streak_widget_count, streak.toString())
            views.setTextViewText(R.id.streak_widget_message, message)

            if (layout == R.layout.streak_widget_medium) {
                val dots = intArrayOf(R.id.streak_widget_dot_0, R.id.streak_widget_dot_1, R.id.streak_widget_dot_2, R.id.streak_widget_dot_3, R.id.streak_widget_dot_4, R.id.streak_widget_dot_5, R.id.streak_widget_dot_6)
                dots.forEachIndexed { index, dot ->
                    views.setImageViewResource(dot, if (heatmap.getOrNull(index) == '1') R.drawable.streak_widget_dot_active else R.drawable.streak_widget_dot_inactive)
                }
            }

            val intent = Intent(Intent.ACTION_VIEW, Uri.parse("bacayu://widget/start-session"), context, MainActivity::class.java)
            val tap = PendingIntent.getActivity(context, id, intent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
            views.setOnClickPendingIntent(R.id.streak_widget_root, tap)
            manager.updateAppWidget(id, views)
        }
    }
}
