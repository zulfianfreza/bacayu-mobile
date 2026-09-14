# CLAUDE.md — BacaYu Mobile

**Dokumen Terkait:**

- [PRD BacaYu](./docs/PRD_BacaYu.md)
- [Style Guide](./docs/BacaYu_Style_Guide.md) — sumber token warna/tipografi di `core/theme/`
- Backend: repo `bacayu-backend`, lihat `CLAUDE.md` di sana untuk kontrak API & response envelope

Panduan kerja untuk siapa pun (manusia atau AI coding agent) yang menulis kode di repo mobile BacaYu. Filosofinya sama persis dengan backend: **Clean Architecture + feature-first** — kalau belum baca CLAUDE.md backend, konsep dasarnya sama, cuma nama layer-nya beda idiom (Flutter pakai domain/data/presentation, bukan domain/usecase/delivery/repository).

---

## 1. Project Overview

**Tech stack:**
| Layer | Pilihan |
|---|---|
| Framework | Flutter |
| State management | Bloc/Cubit (`flutter_bloc`) |
| HTTP client | Dio |
| Local persistence (offline) | Drift (`drift` — type-safe, reactive, cocok dipadukan Bloc) |
| Barcode scanning | `mobile_scanner` |
| Dependency Injection | `get_it` + `injectable` |
| Routing | `go_router` |
| Push notification | `firebase_messaging` |
| Charts | `fl_chart` |
| Font | Nunito (lihat Style Guide) |
| Functional error handling | `dartz` (`Either<Failure, T>`) |

---

## 2. Architecture Philosophy: Clean Architecture + Feature-First

Sama seperti backend: folder dikelompokkan **per fitur** (`auth`, `onboarding`, `books`, `shelf`, `sessions`, `stats`, `badges`, `feed`, `social`, `notifications`), dan **di dalam tiap fitur** baru dipecah 3 layer:

```
delivery arah dependency:  presentation ──> domain <── data
```

- **`domain`**: entity murni (Dart class polos, bukan model JSON), abstract repository interface (port), usecase (1 aksi bisnis = 1 class `Callable`/method `call()`). **Tidak boleh** import `flutter_bloc`, `dio`, atau apa pun dari `data`/`presentation`.
- **`data`**: model (subclass/extension entity dengan `fromJson`/`toJson`), datasource (remote via Dio, local via Drift), implementasi konkret dari repository interface milik `domain`.
- **`presentation`**: Bloc/Cubit, halaman (`pages/`), widget (`widgets/`). Bergantung ke `domain` (panggil usecase), **tidak pernah** langsung panggil datasource/Dio.

**Aturan emas sama dengan backend:** `domain` tidak pernah tahu soal Flutter widget, Dio, atau Drift. Kalau ada import melingkar/salah arah, arsitekturnya salah.

---

## 3. Anatomi 1 Feature Module (contoh: `sessions`)

```
lib/features/sessions/
├── domain/
│   ├── entities/
│   │   └── reading_session.dart      # entity murni + PauseInterval
│   ├── repositories/
│   │   └── session_repository.dart   # abstract class (port)
│   └── usecases/
│       ├── start_session_timer.dart
│       ├── submit_session.dart
│       └── get_session_history.dart
├── data/
│   ├── models/
│   │   └── reading_session_model.dart  # extends entity, fromJson/toJson
│   ├── datasources/
│   │   ├── session_remote_datasource.dart  # panggil Dio ke POST/GET /sessions
│   │   └── session_local_datasource.dart   # Drift: queue offline, cache history
│   └── repositories/
│       └── session_repository_impl.dart    # implements domain/repositories, orkestrasi remote+local
└── presentation/
    ├── cubit/
    │   ├── session_timer_cubit.dart   # state machine timer (idle/running/paused/stopped)
    │   └── session_timer_state.dart
    ├── pages/
    │   └── session_timer_page.dart
    └── widgets/
        └── timer_display.dart
```

### 3.1 Contoh kode per layer

**`domain/entities/reading_session.dart`** — entity murni:

```dart
class ReadingSession {
  final String clientId;
  final String userBookId;
  final DateTime startTime;
  final DateTime? endTime;
  final int activeDurationSeconds;
  final List<PauseInterval> pauseIntervals;
  final int startPage;
  final int endPage;

  const ReadingSession({
    required this.clientId,
    required this.userBookId,
    required this.startTime,
    this.endTime,
    required this.activeDurationSeconds,
    required this.pauseIntervals,
    required this.startPage,
    required this.endPage,
  });
}

class PauseInterval {
  final DateTime pausedAt;
  final DateTime? resumedAt;
  const PauseInterval({required this.pausedAt, this.resumedAt});
}
```

**`domain/repositories/session_repository.dart`** — interface, di-depend usecase & Cubit:

```dart
abstract class SessionRepository {
  Future<Either<Failure, ReadingSession>> submitSession(ReadingSession session);
  Future<Either<Failure, List<ReadingSession>>> getHistory({int page = 1});
}
```

**`domain/usecases/submit_session.dart`** — 1 usecase = 1 class:

```dart
class SubmitSession {
  final SessionRepository repository;
  SubmitSession(this.repository);

  Future<Either<Failure, ReadingSession>> call(ReadingSession session) {
    return repository.submitSession(session);
  }
}
```

**`presentation/cubit/session_timer_cubit.dart`** — Cubit panggil usecase, tidak pernah panggil Dio/Drift langsung:

```dart
class SessionTimerCubit extends Cubit<SessionTimerState> {
  final SubmitSession submitSession;
  SessionTimerCubit(this.submitSession) : super(SessionTimerIdle());

  Future<void> stop() async {
    emit(SessionTimerSubmitting());
    final result = await submitSession(_buildSessionFromState());
    result.fold(
      (failure) => emit(SessionTimerError(failure)),
      (session) => emit(SessionTimerSubmitted(session)),
    );
  }
}
```

**`data/repositories/session_repository_impl.dart`** — implementasi konkret, offline-first:

```dart
class SessionRepositoryImpl implements SessionRepository {
  final SessionRemoteDataSource remote;
  final SessionLocalDataSource local;
  SessionRepositoryImpl(this.remote, this.local);

  @override
  Future<Either<Failure, ReadingSession>> submitSession(ReadingSession session) async {
    // Simpan ke local queue DULU (offline-first) — lihat Section 8
    await local.enqueue(session);
    try {
      final result = await remote.submit(session);
      await local.markSynced(session.clientId);
      return Right(result);
    } on DioException catch (e) {
      // Tetap "sukses" dari sudut pandang UI — akan di-retry oleh sync worker
      return Right(session);
    }
  }
}
```

---

## 4. Struktur Folder Lengkap (Root)

```
bacayu-mobile/
├── lib/
│   ├── main.dart                    # entrypoint, init DI, run App
│   ├── app.dart                     # MaterialApp.router, theme, top-level BlocProviders
│   ├── core/
│   │   ├── di/
│   │   │   └── injection.dart       # get_it + injectable setup (@injectable annotations)
│   │   ├── network/
│   │   │   ├── dio_client.dart      # Dio instance + interceptor (auth token, logging, request_id)
│   │   │   ├── api_response.dart    # model envelope {success, status_code, timestamp, request_id, message, data} — SAMA PERSIS format backend
│   │   │   └── (Either<Failure, T> dari package dartz dipakai langsung — tidak perlu bikin Result<T> custom)
│   │   ├── error/
│   │   │   └── failure.dart         # sealed Failure: NetworkFailure, ServerFailure(code,message), CacheFailure, ValidationFailure(details)
│   │   ├── router/
│   │   │   └── app_router.dart      # go_router config
│   │   ├── theme/
│   │   │   ├── app_colors.dart      # dari Style Guide: tangerine500, lagoon500, dst
│   │   │   ├── app_typography.dart  # Nunito text theme, type scale dari Style Guide Section 3
│   │   │   └── app_theme.dart       # ThemeData gabungan, radius/spacing tokens
│   │   ├── storage/
│   │   │   └── app_database.dart    # Drift database, semua tabel lokal (termasuk pending session queue)
│   │   ├── constants/
│   │   └── utils/
│   └── features/
│       ├── auth/
│       ├── onboarding/
│       ├── books/
│       ├── shelf/
│       ├── sessions/
│       ├── stats/
│       ├── badges/
│       ├── feed/
│       ├── social/
│       └── notifications/
├── test/                            # struktur mirror lib/, per fitur
├── assets/
│   └── fonts/                       # Nunito .ttf kalau tidak pakai google_fonts package
├── pubspec.yaml
└── CLAUDE.md
```

**Aturan penempatan** sama semangatnya dengan backend: kode spesifik 1 fitur → `features/<nama>/`; wrapper teknis lintas fitur (Dio client, Drift database, router) → `core/`; **jangan** taruh business logic (usecase) di `core/`.

---

## 5. Konvensi Kode

### 5.1 Naming

- File: `snake_case.dart`. Class: `PascalCase`. 1 usecase = 1 class dengan method `call()` (bisa dipanggil seperti function: `submitSession(session)`).
- Cubit state pakai `sealed class` (Dart 3) per fitur, bukan 1 class besar dengan banyak nullable field — `SessionTimerIdle`, `SessionTimerRunning`, `SessionTimerPaused`, `SessionTimerError` sebagai subclass terpisah, bukan `SessionTimerState(status: ..., error: ...)` generik.
- Semua state class **wajib** `extends Equatable` (atau pakai `sealed class` + pattern matching Dart 3 sebagai gantinya) supaya Bloc tidak rebuild UI karena perbandingan objek yang salah.

### 5.2 Cubit vs Bloc — kapan pakai yang mana

- **Default: Cubit.** Sebagian besar layar cukup method langsung (`fetch()`, `submit()`) tanpa perlu event class terpisah.
- **Pakai Bloc (dengan Event)** hanya kalau butuh: debounce/throttle (mis. search-as-you-type di `books`), atau state machine dengan banyak trigger berbeda yang perlu di-log/diaudit urutannya (mis. `SessionTimerBloc` kalau ternyata perlu event `TimerTicked`, `TimerPaused`, `TimerResumed` sebagai audit trail eksplisit — boleh upgrade dari Cubit ke Bloc kalau kompleksitasnya sampai situ).
- Jangan mulai dari Bloc "just in case" — mulai dari Cubit, upgrade kalau memang kebutuhannya jelas.

### 5.3 Error Handling — `Either<Failure, T>` (dartz), bukan try/catch tersebar

- Semua method repository return `Future<Either<Failure, T>>` (dari package **`dartz`**) — `Left` untuk error, `Right` untuk hasil sukses (konvensi standar dartz: "Right is right"). **Bukan** melempar exception ke atas untuk ditangkap sembarangan di widget.
- `Failure` adalah sealed class custom kita sendiri di `core/error/failure.dart` (dartz cuma menyediakan `Either`-nya, bukan tipe error-nya) — dipakai sebagai tipe `Left` di semua `Either`.
- Mapping dari response API (`{success:false, data:{code, details}, message}`) ke `ServerFailure`/`ValidationFailure` terjadi **satu tempat** di `core/network/dio_client.dart` (interceptor/error handler), bukan diulang manual di tiap datasource.
- Cubit/Bloc pakai `result.fold((failure) => ..., (success) => ...)` untuk emit state yang sesuai — jangan `try { } catch (e) { }` generik di presentation layer.
- Untuk chaining beberapa operasi yang masing-masing bisa gagal, manfaatkan `.flatMap()`/`.map()` milik `Either` alih-alih nested `if/else` manual — tapi jangan dipaksakan untuk kasus sederhana 1 langkah, itu cukup `.fold()` biasa.

### 5.4 Networking — samakan dengan kontrak backend

- `ApiResponse<T>` model **harus** persis mengikuti bentuk response envelope backend (`success`, `status_code`, `timestamp`, `request_id`, `message`, `data`) — lihat CLAUDE.md backend Section 5.4. Kalau backend ubah format, model ini yang pertama harus diupdate, dan idealnya ketahuan lewat compile error/test gagal, bukan silent parse failure.
- Log `request_id` dari response header/body di setiap error — memudahkan korelasi ke log backend saat debugging bareng tim backend.
- Base URL & timeout Dio dari environment config (`--dart-define`), jangan hardcode.

### 5.5 Localization

- BacaYu mendukung Bahasa Indonesia & English (PRD Section 2.2). **Semua string yang tampil ke user** (label, button, error message, empty state, dst) **WAJIB** lewat `context.l10n.xxx` (`AppLocalizations` via extension di `core/localization/build_context_extension.dart`) — **TIDAK ADA** string hardcoded di widget manapun mulai Fase 2 dan seterusnya.
- Sumber string: `lib/l10n/app_en.arb` (template) & `lib/l10n/app_id.arb`. Key generik lintas fitur (`retry`, `cancel`, `save`, dst) sudah ada dari setup awal; key spesifik 1 fitur ditambahkan **saat fitur itu dibangun**, bukan diisi di muka.
- Error dari backend (`Failure`) di-localize lewat `core/error/failure_localizer.dart` — mapping `ServerFailure.code` ke key `l10n` yang sesuai. Kalau code belum ada mapping-nya (backend nambah error code baru duluan), **fallback ke `Failure.message` asli dari backend**, jangan sampai hilang/crash.
- Locale aktif dikelola `core/localization/locale_cubit.dart`, persist ke `shared_preferences` (bukan data sensitif, beda dari auth token yang di `flutter_secure_storage`). Default ikut locale device kalau user belum pernah pilih manual.

---

## 6. Offline-First Session — Kontrak Penting dengan Backend

Ini bagian paling kritikal karena **langsung terhubung ke desain backend** (`client_id` untuk idempotency, lihat CLAUDE.md backend Section 6.4).

- Setiap sesi yang di-submit **selalu generate `client_id` (UUID) di sisi mobile**, sebelum tahu apakah akan sukses terkirim atau tidak.
- Sesi disimpan ke tabel Drift lokal (`pending_sessions`) **SEBELUM** mencoba kirim ke server — Cubit langsung emit state "submitted" ke UI berdasarkan penyimpanan lokal ini, TIDAK menunggu response server (supaya UI terasa instan, sesuai filosofi "offline-first" di PRD Section 5.3).
- Sync worker (jalan di background — pakai `WorkManager`/`workmanager` package atau cukup listener `connectivity_plus` + retry saat app resume) mengirim ulang semua row `pending_sessions` yang belum `synced`, pakai `client_id` yang sama setiap retry — backend sudah didesain idempotent terhadap `client_id` ini, jadi **aman dikirim berkali-kali** kalau sebelumnya gagal di tengah jalan (mis. sukses di server tapi response timeout di mobile).
- Setelah sync sukses, hapus/tandai row lokal sebagai `synced`, JANGAN dihapus langsung kalau khawatir butuh untuk debugging — cukup flag, bukan delete.
- Kalau ada `badges_unlocked` di response submit (lihat fast-path badge di CLAUDE.md backend Section 8.4), UI cuma bisa nampilin badge unlock modal itu **kalau sync-nya terjadi saat app masih dibuka** — kalau sync terjadi di background setelah user sudah menutup app, badge unlock notification-nya baru muncul lewat push notification (`bacayu.badge.unlocked` → FCM), bukan modal in-app. Jangan asumsikan modal in-app selalu jadi satu-satunya cara user tahu dapat badge baru.

---

## 7. Dependency Injection

- `get_it` + `injectable` (code generation via `build_runner`) — hindari `context.read`/`context.watch` untuk ambil repository/usecase langsung dari widget tree; itu hanya untuk Bloc/Cubit instance, bukan dependency layer domain/data.
- Registrasi per fitur di file terpisah (`injection_sessions.dart`, dst) yang di-agregasi ke 1 `configureDependencies()` di `core/di/injection.dart` — jangan 1 file raksasa berisi semua registrasi semua fitur.

## 8. Routing

- `go_router`, route path & nama sebagai konstanta di `core/router/app_router.dart` — jangan hardcode string path di tempat lain yang manggil `context.go(...)`.
- Route yang butuh auth (semua kecuali `auth`/`onboarding`) dilindungi lewat `redirect` di `go_router`, bukan dicek manual di tiap halaman.

## 9. Theming

- Semua warna/font/radius **wajib** dari `core/theme/`, hasil terjemahan langsung dari [Style Guide](./docs/BacaYu_Style_Guide.md) — jangan hardcode `Color(0xFF...)` atau `fontSize: 20` langsung di widget manapun.
- Widget custom yang dipakai berulang (medal badge, streak flame chip, pill button) masuk `core/widgets/` (shared widget lintas fitur) — bukan didefinisikan ulang di tiap fitur yang kebetulan butuh tampilan serupa.

## 9.1 Localization (i18n)

- Semua string yang tampil ke user (label, tombol, error message, empty state) **WAJIB** lewat `context.l10n.xxx` (extension di `core/localization/`) — **tidak ada** string hardcoded di widget manapun. Ini berlaku sejak fitur pertama dibangun, bukan retrofit belakangan.
- File sumber: `lib/l10n/app_en.arb` & `app_id.arb` — setiap fitur baru menambah key-nya sendiri di kedua file ini bersamaan (jangan cuma isi 1 bahasa lalu lupa yang lain).
- **Pesan error dari backend TIDAK diterjemahkan di backend.** `Failure` (lihat Section 5.3) membawa `code` (mis. `SESSION_NOT_FOUND`) yang di-mapping ke string lokal lewat `failure_localizer.dart` — `message` mentah dari backend hanya dipakai sebagai **fallback** kalau `code`-nya belum ada mapping-nya di mobile (backward-compatible terhadap error code baru dari backend yang belum sempat diterjemahkan).
- **Data dinamis dari backend TIDAK dilokalisasi mobile** — nama/deskripsi badge, judul buku, deskripsi buku dari Google Books, dsb tetap apa adanya dari server (bahasa aslinya). Kalau suatu saat butuh badge multi-bahasa, itu perubahan skema di backend (kolom per-locale/tabel terjemahan), bukan tanggung jawab mobile.
- Locale aktif user disimpan & di-restore lewat `LocaleCubit` (persist ke `shared_preferences`, bukan `flutter_secure_storage` — ini bukan data sensitif).

## 10. Testing

- **Usecase**: unit test dengan mock repository (`mocktail`), tidak boleh hit Dio/Drift asli.
- **Cubit/Bloc**: pakai `bloc_test`, assert urutan state yang di-emit, bukan cuma state akhir.
- **Widget**: `flutter_test` untuk interaksi dasar; golden test untuk komponen visual kunci (medal badge, timer display) supaya regresi visual ketahuan dari diff gambar, bukan manual QA setiap kali.
- Repository (`data/repositories/`) — integration test terpisah pakai Drift in-memory database + mock Dio (`http_mock_adapter`/`dio_test`), tidak wajib di setiap PR tapi wajib untuk `sessions` (paling kritikal karena offline-first).

## 11. Checklist: Menambah Fitur Baru

1. Buat folder `lib/features/<nama_fitur>/` dengan 3 subfolder (`domain`, `data`, `presentation`).
2. Definisikan entity & repository interface di `domain/` dulu.
3. Tulis usecase yang bergantung ke interface.
4. Implementasikan model + datasource (remote/local) + repository di `data/`.
5. Tulis Cubit/Bloc + page + widget di `presentation/`.
6. Registrasi DI untuk fitur ini (`injection_<fitur>.dart`), tambahkan ke agregator.
7. Tambahkan route di `app_router.dart` kalau ada halaman baru.
8. Tambahkan string baru ke `lib/l10n/app_en.arb` DAN `app_id.arb` — jangan cuma 1 bahasa.
9. Tulis unit test untuk usecase & Cubit minimal.

## 12. Golden Rules (Ringkasan)

- ✅ Feature-first di root, Clean Architecture (domain/data/presentation) di dalam tiap fitur.
- ✅ `domain` tidak boleh tahu apa-apa soal Flutter widget, Dio, atau Drift.
- ✅ Semua repository return `Either<Failure, T>` (dartz), bukan throw exception ke presentation layer.
- ✅ Cubit sebagai default, Bloc cuma kalau kompleksitasnya jelas butuh event-driven.
- ✅ `client_id` di-generate di mobile SEBELUM submit, disimpan lokal dulu (offline-first), idempotent terhadap retry.
- ✅ Semua styling dari `core/theme/`, sesuai Style Guide — no hardcoded hex/font size di widget.
- ❌ Jangan panggil Dio/Drift langsung dari widget atau Cubit — selalu lewat repository.
- ❌ Jangan asumsikan badge unlock modal in-app selalu muncul — sync bisa terjadi di background, fallback ke push notification.
- ❌ Jangan hardcode string apa pun yang tampil ke user — selalu `context.l10n.xxx`, tambahkan key ke `app_en.arb` DAN `app_id.arb` sekaligus.

---

_Dokumen ini hidup — update setiap ada keputusan arsitektur baru yang disepakati tim._
