# Execution Prompt — BacaYu Home Screen Streak Widget (Android)

Gunakan prompt ini sebagai instruksi implementasi untuk coding agent (Claude Code atau serupa). Referensi desain lengkap ada di dua dokumen pendamping — lampirkan/paste isinya bareng prompt ini:
- `widget-streak-state-bundle-spec.md` — definisi state, bundle, warna, teks
- `widget-illustration-prompt-guide.md` — daftar aset mascot yang harus sudah di-generate lebih dulu

---

## Konteks

BacaYu adalah aplikasi reading tracker (Flutter + Go backend). Kita membangun **home screen widget Android** yang menampilkan current reading streak, mirip widget Duolingo. Aset visual (mascot PNG transparan) sudah/akan di-generate manual sesuai `widget-illustration-prompt-guide.md` — task ini murni soal **kode integrasi**, bukan generate gambar.

## Scope

- Android home screen widget, 2 ukuran: **1:1 (small)** dan **2:1 (medium)**.
- iOS WidgetKit **di luar scope** task ini (kerjakan terpisah, butuh Swift/Xcode).
- Data source: state `current_streak`, `read_today`, dan (untuk widget medium) rekap 7 hari terakhir dari `daily_reading_stats`.

## Logic State (dari `widget-streak-state-bundle-spec.md`)

Implementasikan resolver yang menentukan state aktif berdasarkan input `read_today: bool`, `current_streak: int`, `now: DateTime`, dan opsional `streak_frozen: bool`:

| State | Kondisi |
|---|---|
| `repair` | `current_streak == 0` (prioritas tertinggi — override kondisi waktu) |
| `frozen_safe` | `streak_frozen == true && read_today == false` |
| `done` | `read_today == true` |
| `calm` | `read_today == false`, jam < 10:00 |
| `reminder` | `read_today == false`, jam 10:00–22:00 |
| `urgent` | `read_today == false`, jam 22:00–23:30 |
| `critical` | `read_today == false`, jam > 23:30 |

## Bundle Selection

Setiap state punya beberapa bundle (background + mascot pose berpasangan) dan pool teks independen — lihat tabel lengkap di `widget-streak-state-bundle-spec.md` Section 2.

**Aturan pemilihan (implementasikan persis ini, jangan random murni):**
1. Bundle & teks di-roll ulang **hanya saat state berubah** dari state sebelumnya (bandingkan dengan state yang tersimpan di run terakhir) — bukan setiap kali `onUpdate()`/refresh berkala dipanggil.
2. Random seed = `hash(user_id + yyyy-MM-dd + state_name)` — supaya konsisten sepanjang hari yang sama, tapi berbeda di hari berikutnya.
3. Bundle dan teks di-roll **independen** (dua random call terpisah dengan seed yang sama basisnya tapi tidak saling memengaruhi satu sama lain).
4. Simpan state terakhir + bundle terpilih + teks terpilih ke local storage (SharedPreferences via `home_widget`), supaya re-roll di atas benar-benar hanya terjadi saat transisi state.

## Flutter Side

**File:** `lib/services/widget_service.dart` (sudah ada draf sebelumnya — kembangkan, jangan tulis ulang dari nol)

Tugas:
1. Tambahkan fungsi `resolveWidgetState({required bool readToday, required int currentStreak, required DateTime now, bool streakFrozen = false})` yang mengembalikan enum `WidgetStreakState` sesuai tabel di atas.
2. Tambahkan fungsi `selectBundleAndText(WidgetStreakState state, String userId, DateTime today)` yang mengimplementasikan aturan seeded-random di atas, mengembalikan `{bundleId, backgroundRes, mascotAsset, text}`.
3. Update `updateStreakWidget(...)` supaya:
   - Cek state tersimpan sebelumnya (baca dari `HomeWidget.getWidgetData`).
   - Kalau state berubah → panggil `selectBundleAndText`, simpan hasil barunya.
   - Kalau state sama → pakai bundle/teks yang sudah tersimpan.
   - Simpan semua field yang dibutuhkan native (`bundle_id`, `background_res_name`, `mascot_res_name`, `message_text`, `current_streak`, `weekly_heatmap` — array 7 boolean untuk widget medium).
4. Panggil `updateStreakWidget` di titik-titik ini (integrasi ke kode yang sudah ada, jangan bikin call site baru yang terpisah):
   - Setelah submit reading session sukses (Section 3.7/4.3 PRD).
   - Saat app cold start / Bloc bootstrap.
   - Idealnya juga via periodic background task (WorkManager) tiap pergantian jam, supaya transisi state (misal `calm` → `reminder`) tetap ke-trigger walau user tidak buka app — cek dulu apakah `home_widget` atau `workmanager` package yang lebih pas untuk kebutuhan ini, sesuaikan dengan yang sudah dipakai di stack Flutter/Bloc BacaYu.

## Android Native Side

**Struktur file:**
```
android/app/src/main/kotlin/com/bacayu/app/widget/StreakWidgetProvider.kt
android/app/src/main/res/layout/streak_widget_small.xml     (1:1)
android/app/src/main/res/layout/streak_widget_medium.xml    (2:1)
android/app/src/main/res/xml/streak_widget_info.xml
android/app/src/main/res/drawable/widget_bg_{bundle_id}.xml (16 file, sesuai spec)
android/app/src/main/res/drawable-nodpi/mascot_{bundle_id}.png (16 file, dari hasil generate)
```

Tugas:
1. **Responsive layout selection** — di `onUpdate()`, cek ukuran widget yang dipasang user via `appWidgetManager.getAppWidgetOptions(widgetId)` (`OPTION_APPWIDGET_MIN_WIDTH`/`MIN_HEIGHT`), tentukan pakai `streak_widget_small.xml` atau `streak_widget_medium.xml`. Kalau target minSdk mendukung, boleh pakai `RemoteViews` API 31+ multi-layout constructor sebagai alternatif — pilih pendekatan yang konsisten dengan minSdk project ini (cek `android/app/build.gradle`).
2. **Background & mascot dari data**: baca `background_res_name` dan `mascot_res_name` dari `HomeWidgetPlugin.getData(context)`, resolve ke resource ID via `resources.getIdentifier(...)`, set ke `RemoteViews` (`setInt(..., "setBackgroundResource", ...)` untuk background, `setImageViewResource(...)` untuk mascot).
3. **Layout 1:1 (`streak_widget_small.xml`)**:
   - Icon flame + angka streak di **atas** (bukan pojok).
   - Teks pesan di bawah icon+angka.
   - Mascot `ImageView` full-bleed, `scaleType="fitCenter"` atau `centerCrop` tergantung hasil visual — mascot muncul bawah-tengah sesuai desain aset.
   - **Tanpa heatmap.**
4. **Layout 2:1 (`streak_widget_medium.xml`)**:
   - Icon flame + angka streak + teks di **pojok kiri-atas** (bukan tengah).
   - Tambahkan **weekly heatmap**: 7 dot horizontal (label hari pendek: Sn/Sl/Rb/Km/Jm/Sb/Mg), checkmark untuk hari yang `session_count > 0`, dot polos untuk yang belum — render dari array `weekly_heatmap` yang dikirim dari Flutter, gunakan `RemoteViews.setImageViewResource` per dot (7 `ImageView` statis di layout, di-loop di provider) karena `RemoteViews` tidak mendukung dynamic list tanpa `RemoteViewsService`/`ListView` yang lebih kompleks — 7 item tetap cukup pakai pendekatan statis ini.
   - Mascot `ImageView` di-anchor bawah-kanan (`layout_gravity="bottom|end"`), pertahankan aspect ratio, biarkan bagian atas mascot terpotong oleh batas frame yang lebih pendek — ini disengaja, jangan diperbaiki dengan scale-down yang malah bikin mascot kekecilan.
5. **Manifest**: registrasi `<receiver>` untuk provider (contoh ada di draf sebelumnya) + `streak_widget_info.xml` dengan `resizeMode="horizontal|vertical"` supaya user bisa switch antar 1:1/2:1.
6. **Tap-to-deeplink**: pertahankan `PendingIntent` ke `bacayu://widget/start-session` yang sudah didesain sebelumnya.
7. **Update trigger**: `updatePeriodMillis` di `streak_widget_info.xml` tetap ada sebagai fallback (Android minimum ~30 menit), tapi update utama tetap dari trigger eksplisit sisi Flutter (submit session, cold start, WorkManager) — jangan andalkan `updatePeriodMillis` sebagai satu-satunya sumber refresh karena terlalu jarang untuk transisi state per jam.

## Non-Goals (jangan dikerjakan di task ini)

- iOS WidgetKit implementation (Swift/SwiftUI — task terpisah).
- Fitur streak-freeze end-to-end (state `frozen_safe` di logic sudah disiapkan, tapi trigger/consume item freeze itu sendiri di luar scope).
- Generate aset mascot/background — asumsikan 16 PNG + 16 drawable XML sudah tersedia sesuai spec, kalau belum ada gunakan placeholder sementara dan tandai TODO.

## Acceptance Criteria

- [ ] Widget bisa dipasang di 2 ukuran (1:1 dan 2:1), tampilan sesuai spec masing-masing.
- [ ] State berubah otomatis sesuai jam tanpa perlu buka app (via WorkManager atau minimum via `updatePeriodMillis`).
- [ ] Bundle & teks tidak berubah-ubah dalam state yang sama di hari yang sama (no flicker), tapi berbeda dari hari sebelumnya.
- [ ] Tap widget membuka app langsung ke halaman start session.
- [ ] Heatmap 7-hari di widget medium akurat sesuai `daily_reading_stats`.
