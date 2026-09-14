# BacaYu Mobile — Prompt untuk Eksekusi (Claude Code)

**Dokumen Terkait:**

- [CLAUDE.md Mobile](./CLAUDE_mobile.md) — acuan seluruh prompt di sini
- [PRD BacaYu](./PRD_BacaYu.md), [Style Guide](./BacaYu_Style_Guide.md)
- Backend sudah selesai (auth, books, shelf, sessions, badges, stats, feed, social, notifications) — mobile ini konsumen API-nya.

Sama seperti backend: **jangan minta semua sekaligus**, ikuti fase, review sebelum lanjut.

---

## Fase 0 — Scaffolding

```
Setup skeleton awal project Flutter untuk BacaYu sesuai CLAUDE.md (repo mobile).

1. flutter create dengan nama package yang sesuai, target iOS + Android.
2. Tambahkan dependencies di pubspec.yaml: flutter_bloc, equatable, dio, dartz, drift + drift_dev + sqlite3_flutter_libs (dev), mobile_scanner, get_it, injectable + injectable_generator (dev), build_runner (dev), go_router, firebase_messaging, firebase_core, fl_chart, connectivity_plus, workmanager, flutter_secure_storage, google_fonts (atau bundle font Nunito .ttf manual di assets/fonts — pilih salah satu, kalau bundle manual, daftarkan di pubspec fonts section), uuid, intl.
3. Buat seluruh struktur folder kosong sesuai CLAUDE.md Section 4: lib/core/{di,network,error,router,theme,storage,constants,utils}, lib/features/{auth,onboarding,books,shelf,sessions,stats,badges,feed,social,notifications} (masing-masing dengan domain/data/presentation kosong).
4. Buat lib/core/theme/app_colors.dart dan app_typography.dart — isi PERSIS sesuai token di Style Guide Section 2 & 3 (Tangerine #FF6A3D, Lagoon #14B8A6, Sunshine #FFC93C, Berry #FF4D6D, Ink #2B2117, Background #FFF8F2, dst — termasuk ramp 50/100/300/500/700/900). Font Nunito, weight 400/600/700/800.
5. Buat lib/core/network/api_response.dart: model generic ApiResponse<T> yang match PERSIS response envelope backend (success, status_code, timestamp, request_id, message, data) — lihat CLAUDE.md backend Section 5.4.
6. Buat lib/core/error/failure.dart: sealed class Failure (NetworkFailure, ServerFailure(code,message), CacheFailure, ValidationFailure(details)) — ini yang dipakai sebagai tipe `Left` di `Either<Failure, T>` (dartz) di semua repository, TIDAK perlu bikin wrapper Result<T> custom karena dartz sudah menyediakan Either.
7. Buat lib/main.dart dan lib/app.dart minimal — MaterialApp.router kosong dengan theme dari core/theme, belum ada route/fitur.

Jangan buat business logic fitur apa pun dulu di fase ini.
```

---

## Fase 1 — Core Infrastructure Wiring

```
Lanjutkan dari skeleton. Implementasikan seluruh internal core/ sesuai CLAUDE.md.

1. lib/core/network/dio_client.dart: instance Dio dengan base URL dari --dart-define (API_BASE_URL), interceptor untuk (a) attach auth token dari secure storage ke header, (b) log request/response termasuk request_id, (c) map DioException & response error envelope ke Failure yang sesuai (lihat CLAUDE.md Section 5.3) — mapping ini SATU tempat saja, dipakai semua datasource.
2. lib/core/storage/app_database.dart: setup Drift database kosong (belum ada tabel spesifik fitur, itu ditambahkan tiap fitur dibangun) + secure storage terpisah (flutter_secure_storage) khusus untuk auth token (JANGAN simpan token di Drift biasa).
3. lib/core/di/injection.dart: setup get_it + injectable, configureDependencies() function, generate lewat build_runner.
4. lib/core/router/app_router.dart: go_router skeleton dengan named routes sebagai konstanta, redirect guard untuk route yang butuh auth (cek token ada/tidak dari secure storage) — arahkan ke /login kalau belum ada token.
5. lib/core/theme/app_theme.dart: ThemeData lengkap (colorScheme, textTheme dari Nunito, radius button/card sesuai Style Guide Section 4 — pill untuk button, rounded 16-24px untuk card).
6. Buat splash screen sederhana (lib/features/auth/presentation/pages/splash_page.dart boleh dibuat sekarang sebagai pengecualian kecil) yang cek token, redirect ke onboarding/login/home.

Tulis unit test untuk `Either<Failure, T>` mapping di dio_client (mock DioException berbagai skenario: network error, 401, 404, 422 validation) — pastikan tiap skenario menghasilkan `Left(FailureYangSesuai)`, bukan exception yang lolos ke atas.
```

---

## Fase 1.5 — Localization (i18n) Setup

Kerjakan ini SEBELUM mulai Fase 2 — mumpung belum ada 1 pun layar fitur yang ditulis, jadi tidak perlu bongkar ulang widget yang sudah ada.

```
Setup infrastruktur localization untuk BacaYu (Bahasa Indonesia + English, sesuai PRD Section 2.2).

1. Tambahkan flutter_localizations (dari Flutter SDK) ke pubspec.yaml, intl sudah ada dari Fase 0. Tambahkan `generate: true` di section flutter: pada pubspec.yaml.
2. Buat l10n.yaml di root project: arb-dir: lib/l10n, template-arb-file: app_en.arb, output-localization-file: app_localizations.dart, output-class: AppLocalizations.
3. Buat lib/l10n/app_en.arb dan lib/l10n/app_id.arb — isi dulu dengan key generik yang sudah pasti kepakai di semua fitur (mis. "retry", "cancel", "save", "loading", "somethingWentWrong", "noInternetConnection") — key spesifik per fitur ditambahkan saat fitur itu dibangun, bukan diisi semua sekarang.
4. Buat extension lib/core/localization/build_context_extension.dart: `extension L10nExtension on BuildContext { AppLocalizations get l10n => AppLocalizations.of(this)!; }` — supaya pemanggilan di widget cukup `context.l10n.retry` bukan `AppLocalizations.of(context)!.retry`.
5. Wire ke lib/app.dart: localizationsDelegates: AppLocalizations.localizationsDelegates + GlobalMaterialLocalizations.delegates, supportedLocales: AppLocalizations.supportedLocales.
6. Buat lib/core/localization/locale_cubit.dart: Cubit sederhana untuk locale aktif user, persist pilihan ke secure storage/shared_preferences (baru, tambahkan shared_preferences ke pubspec kalau belum ada — ini bukan data sensitif jadi tidak perlu flutter_secure_storage), default ikut locale device kalau belum pernah pilih manual.
7. PENTING — buat lib/core/error/failure_localizer.dart: fungsi/extension yang mapping Failure.code (mis. "SESSION_NOT_FOUND", "VALIDATION_ERROR", "NETWORK_ERROR") ke context.l10n key yang sesuai. Kalau code dari backend belum ada mapping-nya di mobile (kasus umum: backend nambah error code baru duluan), FALLBACK ke Failure.message asli dari backend (raw string, bukan hilang/crash) — supaya app tetap jalan wajar walau belum sempat nambah terjemahan untuk error code yang baru.

Update CLAUDE.md: tambahkan section "Localization" di bawah Section 5 — SEMUA string yang tampil ke user (label, button, error message, empty state) WAJIB lewat context.l10n.xxx, TIDAK ADA string hardcoded di widget manapun mulai Fase 2 dan seterusnya. Ini masuk Golden Rules juga.

Tulis unit test untuk failure_localizer (kasus code dikenal vs tidak dikenal → fallback ke message asli).
```

---

## Fase 2 — Fitur per Fitur

Urutan: **auth → books → shelf → onboarding → sessions → stats → badges → feed → social → notifications**.

**Catatan penting — beda dari urutan backend:** di backend, `onboarding` bukan modul tersendiri (cuma komposisi endpoint dari `auth`+`books`+`shelf`), tapi urutan _pembangunannya_ di backend tetap `auth → books → shelf → sessions → ...` sejak awal — TIDAK ada fitur bernama "onboarding" yang dibangun terpisah di backend. Di **mobile**, `onboarding` justru jadi 1 fitur presentation tersendiri (karena butuh UI orkestrasi lintas fitur), jadi urutannya digeser: **`books` & `shelf` mobile harus jadi dulu**, baru `onboarding` bisa disusun (step 3-nya re-use widget dari keduanya). Kalau dibangun sesuai urutan lama (`onboarding` sebelum `books`/`shelf`), step 3 tidak akan punya apa-apa untuk di-reuse.

### Contoh konkret — fitur `auth`:

```
Implementasikan fitur "auth" sesuai CLAUDE.md.

Scope:
- domain/: entity User, abstract AuthRepository (login, register, getCurrentUser, logout), usecases Login, Register, GetCurrentUser, Logout
- data/: UserModel (fromJson sesuai response backend), AuthRemoteDataSource (Dio call ke /auth/register, /auth/login, /users/me), AuthRepositoryImpl (simpan token ke secure storage setelah login sukses)
- presentation/: AuthCubit (state: initial/loading/authenticated/unauthenticated/error), LoginPage, RegisterPage — desain visual ikuti Style Guide (pill button primary, warm background)

Setelah login/register sukses, token disimpan ke secure storage (BUKAN Drift biasa), lalu redirect ke onboarding (kalau user baru) atau home (kalau sudah pernah onboarding — cek dari field di response GetCurrentUser).

RETROFIT (setelah backend menambahkan kolom onboarding_completed_at): tambahkan field onboardingCompletedAt (nullable DateTime) ke UserModel/User entity, update redirect logic di AuthCubit/router jadi eksplisit cek field ini (null → onboarding, ada isinya → home) — bukan lagi asumsi/placeholder generik.

Tulis unit test untuk AuthCubit (mock repository): kasus login sukses, login gagal (kredensial salah → ServerFailure), network error.

Semua label/pesan di LoginPage/RegisterPage lewat context.l10n, bukan hardcoded.
```

### Contoh konkret — fitur `books`:

```
Implementasikan fitur "books" sesuai CLAUDE.md.

Scope:
- domain/entities/book.dart: Book (id, source, googleBooksId, isbn10, isbn13, title, authors List<String>, description, coverUrl, totalPages, language, genres List<String>, publishedDate)
- domain/repositories/book_repository.dart: abstract BookRepository { searchBooks(query), importFromGoogle(googleBooksId), lookupByIsbn(isbn), addManual(BookInput), getBookDetail(bookId) }
- domain/usecases/: SearchBooks, ImportBookFromGoogle, LookupBookByIsbn, AddManualBook, GetBookDetail — masing-masing return Either<Failure, T> sesuai konvensi
- data/models/book_model.dart: fromJson sesuai response backend (cek field yang benar-benar dikembalikan endpoint books, termasuk id internal setelah import/lookup)
- data/datasources/book_remote_datasource.dart: Dio ke GET /books/search?q=, POST /books/import, GET /books/lookup?isbn=, POST /books (manual), GET /books/:id (detail)
- data/repositories/book_repository_impl.dart: implementasi, tidak perlu cache lokal (search hasil ephemeral, sesuai desain backend)

- presentation/bloc/book_search_bloc.dart: PAKAI BLOC (bukan Cubit) untuk search — sesuai CLAUDE.md Section 5.2, search-as-you-type butuh debounce. Event: SearchQueryChanged(query) dengan debounce ~400ms (pakai Stream.transform + debounce manual atau package bloc_concurrency dengan transformer restartable), SearchResultSelected(book) yang trigger ImportBookFromGoogle lalu emit state berisi book dengan id internal siap dipakai.
- presentation/pages/book_search_page.dart: search bar (UI Generation Prompts Section 4), list hasil (BookResultCard: cover, title, author, page count, tombol "+")
- presentation/pages/barcode_scanner_page.dart: full-screen camera (mobile_scanner), guide box overlay rounded, bottom sheet muncul setelah scan sukses (hasil LookupBookByIsbn) menampilkan book + tombol "Add to shelf"
- presentation/pages/book_detail_page.dart (BARU): halaman detail buku by book_id, pakai GetBookDetail — ini yang jadi tujuan navigasi dari SEMUA tempat yang cuma punya book_id tanpa konteks shelf milik user sendiri (paling utama: tap buku di social feed/activity teman). Reusable, JANGAN bikin halaman detail terpisah lagi di fitur "shelf"/"feed"/"social" — semua arahkan ke sini.
- presentation/widgets/book_result_card.dart: reusable, dipakai di search results DAN barcode scan result sheet

PENTING — fitur ini TIDAK melakukan "add to shelf" sendiri (itu tanggung jawab fitur "shelf"). Setelah user tap "+" di search result / "Add to shelf" di scan sheet, fitur books hanya bertanggung jawab sampai dapat book_id internal (via ImportBookFromGoogle atau LookupBookByIsbn) — lalu compose/panggil usecase AddToShelf milik fitur "shelf" (yang harus sudah ada duluan, atau di-stub dulu kalau shelf belum selesai). JANGAN duplikasi logic add-to-shelf di sini.

Tulis unit test untuk BookSearchBloc (pastikan debounce bekerja — ketik cepat berturut-turut hanya trigger 1 request terakhir, mock repository call count = 1) dan ImportBookFromGoogle usecase (mock repository).

Semua label lewat context.l10n.
```

### Contoh konkret — fitur `shelf`:

```
Implementasikan fitur "shelf" sesuai CLAUDE.md.

Scope:
- domain/entities/user_book.dart: UserBook (id, book (nested Book entity untuk display), status enum, format enum nullable, currentPage, startedAt, finishedAt, rating nullable, isReread)
- domain/repositories/shelf_repository.dart: abstract ShelfRepository { addToShelf(bookId, status), listShelf({status filter, page}), updateShelfStatus(userBookId, {status, currentPage, rating}) }
- domain/usecases/: AddToShelf, ListShelf, UpdateShelfStatus
- data/models/user_book_model.dart: fromJson sesuai response backend (termasuk nested book object kalau backend return join)
- data/datasources/shelf_remote_datasource.dart: Dio ke POST /shelf, GET /shelf?status=, PATCH /shelf/:id
- data/repositories/shelf_repository_impl.dart

- presentation/cubit/shelf_cubit.dart: Cubit biasa cukup (tidak perlu debounce/event kompleks di sini), state berisi list + filter status aktif
- presentation/pages/shelf_page.dart: filter pill tabs (All/Want to Read/Reading/Finished/DNF) sesuai UI Generation Prompts Section 3, list ShelfBookCard (cover, title, status chip warna sesuai Style Guide Section 6.5, progress bar Lagoon untuk status Reading)
- presentation/widgets/shelf_book_card.dart — tap card navigasi ke book_detail_page milik fitur "books" (reuse, JANGAN bikin halaman detail baru di sini — sesuai catatan di retrofit books kemarin)

CATATAN UX — jangan berharap badges_unlocked muncul di response AddToShelf/UpdateShelfStatus: fast-path badge sinkron cuma diimplementasikan di endpoint sessions (lihat CLAUDE.md backend Section 8.4), bukan di shelf. Kalau user menyelesaikan buku (status→finished) dan itu trigger badge books_finished, badge-nya baru muncul async lewat push notification atau saat buka tab Badge — BUKAN langsung di response PATCH ini. Jangan bikin UI yang menunggu/berharap field itu ada di response shelf.

Tulis unit test untuk ShelfCubit (mock repository): filter berganti trigger fetch ulang dengan status yang benar, updateStatus ke "finished" sukses mengupdate item di list lokal tanpa perlu refetch semua.

Semua label lewat context.l10n.
```

### Contoh konkret — fitur `onboarding` (kerjakan SETELAH `books` & `shelf` jadi, lihat catatan urutan di atas):

```
Implementasikan fitur "onboarding" sesuai CLAUDE.md dan PRD Section 3.1. Fitur ini TIDAK punya domain/data sendiri yang berat — dia orkestrasi dari fitur auth (update profile) + books (search/scan/manual) + shelf (add to shelf) yang sudah/akan dibuat, jadi presentation-heavy.

Scope:
- presentation/: OnboardingCubit (step index: welcome/preferences/addFirstBook), 3 halaman sesuai UI Generation Prompts Section 1 (Welcome, Preferences dengan genre chips + goal stepper, Add First Book dengan search/scan/manual)
- Preferences step panggil usecase UpdateProfile milik fitur "auth" (favorite_genres, yearly_goal_books, daily_goal_minutes)
- Add First Book step re-use widget/usecase dari fitur "books" (search) dan "shelf" (add to shelf) — JANGAN duplikasi logic search/add di sini, cukup compose Cubit/usecase yang sudah ada dari fitur lain.
- Skip link di step 3 langsung ke home tanpa nambah buku (empty state ditangani di Home nanti).
- PENTING: baik lewat "selesai normal" maupun "skip", panggil POST /users/me/complete-onboarding SEBELUM navigasi ke home — ini set flag onboarding_completed_at di backend (retrofit yang baru ditambahkan ke fitur auth), dipakai AuthCubit untuk redirect logic saat login berikutnya. Kalau ini terlewat, user akan diarahkan ke onboarding lagi setiap kali login walau sudah pernah selesai.

Progress indicator (dot) di atas tiap halaman sesuai Style Guide.

Semua copy onboarding (headline, genre chip label, CTA) lewat context.l10n.
```

### Contoh konkret — fitur `sessions` (paling kritikal, offline-first):

```
Implementasikan fitur "sessions" sesuai CLAUDE.md, khususnya Section 6 (Offline-First Session, termasuk Section 6.1 Akurasi Timer & 6.2 Offline-First Sync) — WAJIB dibaca ulang sebelum mulai.

Scope:
- domain/: entity ReadingSession + PauseInterval, abstract SessionRepository (submitSession, getHistory), usecases SubmitSession, GetSessionHistory
- data/:
  - Tambahkan tabel Drift PendingSessions (client_id PK, payload JSON, synced bool, created_at) di app_database.dart — ini HANYA untuk sesi yang sudah di-Stop & lengkap datanya (Tahap B), BUKAN untuk timer yang masih berjalan (Tahap A tidak perlu persistence apa pun, lihat CLAUDE.md 6.1)
  - SessionRemoteDataSource: POST /sessions, GET /sessions
  - SessionLocalDataSource: enqueue(session) ke PendingSessions, markSynced(clientId), getUnsynced()
  - SessionRepositoryImpl: submitSession() enqueue local DULU (return sukses ke Cubit dari local save, tidak nunggu network), lalu coba kirim ke remote di background; kalau gagal, biarkan row tetap unsynced untuk di-retry sync worker
  - SessionSyncWorker: pakai workmanager atau listener connectivity_plus, jalan periodik/saat reconnect, kirim ulang semua PendingSessions yang unsynced, exponential backoff sederhana
- presentation/:
  - BookPickerBottomSheet — daftar buku status "Reading" untuk dipilih sebelum mulai timer. REUSE ListShelf usecase milik fitur "shelf" (filter status=reading), JANGAN query ulang/duplikasi logic di sini.
  - SessionTimerCubit — state machine idle/running/paused/stopped/submitting/submitted/error. WAJIB hitung active_duration_seconds dari SELISIH TIMESTAMP (start_time, pause_intervals dengan pausedAt/resumedAt, DateTime.now() saat perlu), BUKAN dari counter yang di-increment Timer.periodic. Implementasikan WidgetsBindingObserver untuk detect AppLifecycleState: saat paused/inactive cukup hentikan UI ticker kosmetik (tanpa menambah pause_interval — app di-background TIDAK dianggap pause, sesuai keputusan produk), saat resumed hitung ulang elapsed dari timestamp & restart ticker dengan nilai benar.
  - Kalau app di-kill total saat status masih running/paused (belum sempat Stop): terima sebagai reset, SessionTimerCubit mulai dari idle lagi saat app dibuka — ini keputusan produk yang disengaja, JANGAN implementasikan mekanisme recovery/restore untuk kasus ini.
  - SessionTimerPage — UI sesuai UI Generation Prompts Section 5 (circular timer, pause/stop button)
  - SessionSummaryPage — setelah stop, input start_page (PREFILL dari UserBook.currentPage milik buku yang dipilih — ambil dari data shelf yang sudah di-load di BookPickerBottomSheet, jangan minta user ketik manual dari 0 tiap kali) & end_page, tampilkan badges_unlocked kalau ada di response (fast-path badge dari backend)

client_id di-generate pakai package uuid SAAT user tap "Start", bukan saat submit — ini cuma soal kapan ID-nya dibuat (dipakai nanti pas submit ke tahap B), BUKAN untuk resume timer yang crash di tahap A (yang sudah disepakati: reset saja, tidak ada recovery).

Tulis unit test untuk SessionTimerCubit: state transition idle→running→paused→running→stopped (pastikan pause_intervals ter-record dengan benar), DAN kasus khusus — simulasikan app background lalu resume (mock DateTime/lifecycle), pastikan active_duration_seconds dihitung benar dari timestamp meski UI ticker sempat berhenti selama "background". Tulis juga unit test SessionRepositoryImpl (submit saat offline harus tetap "sukses" dari sisi Cubit, tersimpan di PendingSessions, tidak error ke UI).

Semua label di SessionTimerPage/SessionSummaryPage lewat context.l10n.
```

### Contoh konkret — fitur `badges`:

```
Implementasikan fitur "badges" sesuai CLAUDE.md.

Scope:
- domain/: entity Badge (id, name, icon, description, unlocked, unlockedAt), abstract BadgeRepository (getAllBadges), usecase GetAllBadges
- data/: BadgeModel, BadgeRemoteDataSource (GET /badges), BadgeRepositoryImpl
- presentation/: BadgeCubit, BadgeGalleryPage (grid medal, locked=grayscale sesuai Style Guide Section 6.4), BadgeUnlockedModal (widget reusable, dipanggil dari fitur "sessions" saat response submit ada badges_unlocked, DAN dari push notification handler fitur "notifications" saat app dibuka dari notif badge unlock)

BadgeUnlockedModal HARUS jadi widget reusable di lib/features/badges/presentation/widgets/ (bukan di-inline di halaman sessions), karena dipanggil dari lebih dari 1 tempat (lihat Section 6 poin terakhir CLAUDE.md soal badge unlock via push notification saat app di background).

Tulis unit test untuk BadgeCubit, dan widget test untuk BadgeUnlockedModal (pastikan animasi/konten render benar dengan data badge dummy).

Nama/deskripsi badge sendiri datang dari backend (dinamis, tidak dilokalisasi mobile) — tapi label UI di sekitarnya ("Badge baru!", tombol "Keren!") tetap lewat context.l10n.
```

### Template generik untuk fitur sisanya (`stats`, `feed`, `social`, `notifications`):

```
Implementasikan fitur "{nama_fitur}" sesuai CLAUDE.md.

Scope:
- domain/: entity {daftar entity}, abstract repository, usecases {daftar usecase}
- data/: model + fromJson sesuai response backend endpoint {daftar endpoint}, datasource remote (Dio), repository impl
- presentation/: Cubit/Bloc, halaman sesuai UI Generation Prompts Section {nomor terkait}, widget custom kalau ada

Referensi kontrak API ada di backend (endpoint sudah jadi, cek response envelope-nya langsung kalau perlu).

Semua string yang tampil ke user WAJIB lewat context.l10n.xxx (tambahkan key baru ke lib/l10n/app_en.arb & app_id.arb kalau belum ada) — TIDAK ADA string hardcoded di widget, sesuai CLAUDE.md Section Localization.

Tulis unit test untuk Cubit (mock repository).
```

---

## Fase 3 — Hardening

```
Setelah semua fitur v1 + Social selesai:

1. Cek semua widget pakai token dari core/theme/ — cari hardcoded Color()/fontSize yang lolos review per-fitur.
2. Cek ulang semua Cubit/Bloc state class pakai Equatable/sealed class dengan benar (rebuild UI yang tidak perlu gampang lolos kalau lupa ini).
3. Jalankan flutter analyze, perbaiki semua warning.
4. Golden test untuk komponen visual kunci (medal badge, timer display, bottom nav dengan FAB) kalau belum ada.
5. Cek ulang flow offline-first "sessions" secara manual: matikan network saat submit sesi, pastikan UI tetap responsif & data tidak hilang, nyalakan lagi network, pastikan sync worker jalan otomatis.
6. Cek ulang push notification badge unlock: kirim test notification dari backend/FCM console, pastikan tap notification membuka BadgeUnlockedModal yang benar (bukan cuma buka app ke home).
```

---

## Tips Tambahan

- Kalau ada perbedaan bentuk response antara asumsi mobile dan backend asli (field hilang/beda nama), cross-check ke CLAUDE.md backend Section 5.4 dulu sebelum ubah model mobile — jangan asumsi backend yang salah tanpa dicek.
- Untuk fitur yang butuh data dummy sebelum backend endpoint tertentu dites end-to-end, minta Claude Code buat mock `AuthRepository`/`BadgeRepository` dulu supaya development UI tidak terblokir menunggu integrasi asli.
- Setelah tiap fase, minta ringkasan singkat perubahan — sama seperti workflow backend.
