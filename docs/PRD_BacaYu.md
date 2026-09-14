# Product Requirements Document (PRD) — BacaYu

**Tagline:** "Strava untuk Pembaca" — Reading Tracker & Social Reading Activity App
**Versi Dokumen:** 1.3 (Draft)
**Tanggal:** 11 September 2026

**Dokumen Terkait:**

- [Style Guide](./BacaYu_Style_Guide.md) — warna, tipografi, komponen
- [UI Generation Prompts](./BacaYu_UI_Generation_Prompts.md)
- [CLAUDE.md](../CLAUDE.md) — convention & arsitektur kode backend
- [Backend Execution Prompts](./BacaYu_Backend_Execution_Prompts.md)
  **Status:** Draft untuk review

---

## 1. Overview

### 1.1 Latar Belakang

Aplikasi pencatat aktivitas olahraga seperti Strava berhasil membuat aktivitas yang tadinya "personal" (lari, sepeda) menjadi lebih terukur, konsisten, dan sosial melalui gamifikasi (streak, badge, leaderboard) dan sharing activity. BacaYu mengadopsi pendekatan yang sama untuk aktivitas membaca buku — sebuah aktivitas yang sulit diukur progresnya dan mudah terhenti karena kurang motivasi/konsistensi.

### 1.2 Problem Statement

- Pembaca kesulitan melacak progres membaca mereka secara konsisten (buku apa, berapa lama, seberapa cepat).
- Tidak ada rasa pencapaian yang terukur seperti pada aktivitas olahraga (streak, milestone, badge).
- Sulit menemukan motivasi sosial (teman yang sama-sama gemar membaca) untuk saling menyemangati.
- Pencatatan manual di aplikasi note/spreadsheet tidak menyenangkan dan tidak ada insight/statistik otomatis.

### 1.3 Vision

BacaYu menjadi platform pencatat aktivitas membaca nomor satu yang membuat membaca terasa terukur, memotivasi, dan (di fase selanjutnya) sosial — sehingga pengguna terdorong membaca lebih konsisten.

### 1.4 Goals & Success Metrics (v1)

| Goal           | Metric                        | Target (contoh, sesuaikan dgn bisnis) |
| -------------- | ----------------------------- | ------------------------------------- |
| Adopsi awal    | Jumlah sign-up                | 10.000 user dalam 3 bulan             |
| Engagement     | Retensi D7 / D30              | D7 ≥ 30%, D30 ≥ 15%                   |
| Aktivitas inti | Sesi membaca / user / minggu  | ≥ 3 sesi                              |
| Habit building | % user dengan streak ≥ 7 hari | ≥ 20% dari MAU                        |
| Gamifikasi     | % user yang unlock ≥ 1 badge  | ≥ 60%                                 |

### 1.5 Non-Goals (v1)

- Fitur sosial penuh (follow, feed, kudos/komentar, leaderboard antar teman) — masuk **Phase 2**.
- Marketplace/pembelian buku (e-commerce) tidak termasuk cakupan v1.
- E-book reader bawaan (baca di dalam app) tidak termasuk cakupan v1 — BacaYu adalah _tracker_, bukan _reader_.

---

## 2. Requirements

### 2.1 Functional Requirements (ringkas, detail per fitur di Section 3)

1. User dapat mendaftar/login dan melalui proses onboarding.
2. User dapat mencari buku (via Google Books API) atau menambah buku secara manual.
3. User dapat scan ISBN (barcode) untuk menambahkan buku dengan cepat.
4. User dapat mengatur status buku di dalam "shelf" (Want to Read / Reading / Finished / DNF).
5. User dapat mencatat sesi membaca baik menggunakan **timer real-time** maupun **input manual** (durasi, halaman awal-akhir).
6. Sistem menghitung **speed (pages per minute)**, **duration**, **streak harian**, dan agregat **statistik**.
7. User dapat melihat **heatmap** aktivitas membaca (mirip GitHub contribution graph).
8. Sistem otomatis mengevaluasi dan memberikan **badge** berdasarkan trigger tertentu.
9. User dapat melihat detail statistik pribadi (total halaman, total buku, rata-rata speed, dsb).
10. (Phase 2) User dapat share aktivitas & terhubung dengan teman.

### 2.2 Non-Functional Requirements

- **Performance:** Pencarian buku (Google Books) < 1.5s p95; submit sesi < 500ms p95.
- **Offline-first (partial):** Timer sesi & pencatatan pause harus tetap berjalan meski koneksi terputus; payload dikirim saat online kembali.
- **Scalability:** Badge evaluation & stats aggregation harus scalable (async/queue), tidak boleh blocking request utama.
- **Reliability:** Data sesi membaca tidak boleh hilang (local persistence sebelum sync ke server).
- **Data Privacy:** Data aktivitas bersifat privat by default sampai fitur social (Phase 2) aktif; user consent diperlukan sebelum sharing.
- **Extensibility:** Skema badge & trigger harus fleksibel agar mudah menambah badge baru tanpa perubahan besar pada kode (rule-driven, bukan hardcoded).
- **Localization:** Mendukung Bahasa Indonesia & English.
- **Rate limit handling:** Google Books API punya quota; perlu caching di backend untuk hasil pencarian & metadata buku.

### 2.3 Assumptions & Constraints

- Sumber data buku utama: **Google Books API**. Fallback: input manual oleh user (buku indie, tidak terdaftar di Google Books, dsb).
- Perhitungan pause saat sesi timer **dilakukan di frontend** (start/pause/resume/stop), backend hanya menerima **payload final** (total durasi aktif, jumlah pause, opsional detail interval) — backend tidak perlu real-time tracking state.
- Scan ISBN memerlukan akses kamera device (mobile only untuk fitur ini di v1).

---

## 3. Core Features

### 3.1 Onboarding

**Tujuan:** User baru cepat memahami value proposition dan langsung punya data awal (buku di shelf) agar tidak "kosong" (empty state problem).

Alur:

1. Splash/Welcome screen (value prop: "Track your reading like Strava tracks your run").
2. Sign up / Login (email, Google, Apple).
3. Pertanyaan singkat (personalization, opsional untuk rekomendasi & rasio genre):
   - Genre favorit
   - Target membaca (buku/tahun atau menit/hari) → dipakai untuk **reading goal**
4. Tambahkan minimal 1 buku pertama (search Google Books / scan ISBN / manual) → masuk shelf "Reading" atau "Want to Read".
5. Tutorial singkat cara mulai sesi membaca (highlight tombol "Start Session").
6. Selesai → masuk Home.

### 3.2 Day Streak

- Streak bertambah jika user menyelesaikan minimal 1 sesi membaca (dengan durasi minimum, misal ≥ 1 menit atau dikonfigurasi) dalam 1 hari kalender (berdasarkan timezone user).
- Streak reset ke 0 jika terlewat 1 hari penuh tanpa sesi.
- **Streak freeze / grace period** (opsional, seperti Duolingo): user dapat "membekukan" streak 1x menggunakan reward tertentu (nice-to-have, bisa Phase 1.5).
- Tampilkan current streak & longest streak di profil/home.
- Notifikasi reminder H-beberapa jam sebelum tengah malam jika user belum membaca hari itu (push notification).

### 3.3 Heatmap

- Visualisasi kalender ala GitHub contribution graph: intensitas warna berdasarkan jumlah menit membaca atau jumlah halaman per hari.
- Filter per tahun.
- Tap pada 1 cell → tampilkan detail sesi hari itu (buku apa saja, total durasi, total halaman).

### 3.4 Shelf

Status buku dalam shelf pengguna:

- **Want to Read**
- **Reading** (bisa lebih dari 1 buku aktif — multi-book reading)
- **Finished**
- **DNF (Did Not Finish)** — opsional status tambahan
- User dapat drag/pindah status secara manual, atau otomatis pindah ke "Finished" saat current page = total page (dari sesi terakhir) dan dikonfirmasi user.
- Sorting & filter: berdasarkan judul, tanggal ditambahkan, progres, genre.
- Setiap buku di shelf menyimpan **progress** (current page / total page) yang otomatis ter-update dari sesi terakhir.

### 3.5 Search Books

- Search via **Google Books API** (title, author) dengan hasil menampilkan cover, judul, penulis, jumlah halaman, deskripsi singkat — hasil search **belum tersimpan** ke database internal, murni preview.
- **Import**: setelah user pilih 1 hasil search, baru di-fetch ulang & disimpan ke database internal (`books` table) — find-or-create by `google_books_id`, idempotent kalau buku yang sama sudah pernah di-import user lain sebelumnya (jadi record buku terpakai bersama lintas user, bukan duplikat per user).
- **Scan ISBN**: gunakan kamera untuk scan barcode → ambil kode ISBN → cek cache internal dulu, kalau belum ada query Google Books API `isbn:{code}` sekaligus simpan (find-or-create dalam 1 langkah, beda dari search teks bebas yang perlu langkah konfirmasi/import terpisah karena hasilnya banyak & belum tentu yang dipilih user).
- **Tambah manual**: form input (judul, penulis, jumlah halaman, cover opsional upload, genre, bahasa) untuk buku yang tidak ditemukan di Google Books.

### 3.6 Stats

Statistik personal, minimal mencakup:

- Total buku selesai (all-time, per tahun, per bulan).
- Total halaman dibaca.
- Total waktu membaca (jam/menit).
- Rata-rata reading speed (pages per minute).
- Reading pace terhadap goal tahunan ("kamu 20% lebih cepat dari target").
- Distribusi genre yang dibaca (pie/bar chart).
- Distribusi bahasa buku.
- Waktu favorit membaca (jam berapa paling sering baca — dari data sesi).
- Panjang sesi rata-rata & sesi terlama.

### 3.7 Session (Reading Session)

Dua mode pencatatan:

**A. Timer Mode**

- User menekan Start → timer berjalan.
- User bisa Pause/Resume kapan saja (misal berhenti sejenak). **Logic pause/resume dan penghitungan interval sepenuhnya di frontend.**
- User menekan Stop → input halaman awal & akhir (atau hanya halaman akhir jika halaman awal sudah otomatis dari progress terakhir) → submit.
- Payload yang dikirim ke backend (final, sekali kirim):
  ```json
  {
    "book_id": "uuid",
    "start_time": "2026-09-11T20:00:00+07:00",
    "end_time": "2026-09-11T21:05:00+07:00",
    "active_duration_seconds": 3300,
    "pause_count": 2,
    "pause_intervals": [
      {
        "paused_at": "2026-09-11T20:20:00+07:00",
        "resumed_at": "2026-09-11T20:25:00+07:00"
      },
      {
        "paused_at": "2026-09-11T20:50:00+07:00",
        "resumed_at": "2026-09-11T20:55:00+07:00"
      }
    ],
    "start_page": 120,
    "end_page": 145,
    "input_mode": "timer"
  }
  ```
  Field `pause_intervals` disimpan apa adanya sebagai kolom `jsonb` di `reading_sessions` (lihat Section 6.4) — opsional/detail tambahan untuk analytics lanjutan atau badge tertentu (mis. "Perfect Pace"). Yang wajib dipakai untuk kalkulasi utama adalah `active_duration_seconds`, `start_page`, `end_page`.

**B. Manual Mode**

- User input langsung: buku, tanggal, durasi (menit), halaman awal & akhir (atau jumlah halaman dibaca).
- Cocok untuk user yang lupa nyalakan timer atau membaca fisik tanpa app terbuka.

**Server-side calculation dari payload:**

- `pages_read = end_page - start_page`
- `speed_ppm = pages_read / (active_duration_seconds / 60)`
- Update `total_pages_read`, `current_streak`, progress buku, dan trigger **badge evaluation** (async job).

### 3.8 Badge

Menggunakan struktur data pada file `List_Badges` sebagai basis (kategori: milestone, streak, diversity, genre, speed, hidden). Sistem badge bersifat **rule-driven**: setiap badge punya `trigger_type` + `trigger_value`, dievaluasi oleh Badge Engine setiap ada event relevan (sesi baru, buku selesai, dsb).

**Rekomendasi tambahan badge** (silakan direview, karena diminta untuk melengkapi list yang ada):

| Kategori         | Nama Usulan          | Deskripsi                                                           | Trigger Type (usulan)  |
| ---------------- | -------------------- | ------------------------------------------------------------------- | ---------------------- |
| Milestone        | Comeback Kid         | Kembali membaca setelah absen ≥ 14 hari                             | `streak_broken_return` |
| Milestone        | Big Chapter          | Selesaikan sesi dengan >100 halaman sekaligus                       | `session_pages`        |
| Format Diversity | Format Explorer      | Baca dalam ≥2 format (fisik, ebook, audiobook)                      | `diff_formats`         |
| Goal             | Goal Getter          | Capai target buku tahunan yang ditetapkan saat onboarding           | `yearly_goal_met`      |
| Consistency      | Weekday Warrior      | Baca 5 hari kerja berturut-turut (Senin-Jumat)                      | `weekday_streak`       |
| Diversity        | Rereader             | Menandai ulang & menyelesaikan buku yang sama 2x                    | `book_reread`          |
| Hidden           | Bookworm at Midnight | Selesaikan buku tepat pukul 00:00–00:05                             | `finish_time_exact`    |
| Hidden           | Perfect Pace         | Speed rata-rata sangat stabil (varian rendah) dalam 5 sesi berturut | `pace_consistency`     |
| Social (Phase 2) | First Cheer          | Memberi/menerima kudos pertama kali                                 | `social_kudos`         |
| Social (Phase 2) | Buddy Reader         | Membaca buku yang sama dengan teman di periode sama                 | `social_shared_book`   |

> Catatan: badge Social bersifat placeholder untuk Phase 2, dan `book_reread`, `session_pages`, dll perlu kolom/tabel tambahan (lihat Section 6) yang tidak ada di skema minimal saat ini.

### 3.9 Home Feed (Activity Log)

**Tujuan:** Menampilkan riwayat aktivitas milik user sendiri secara kronologis di Home — cikal-bakal social feed di Phase 2, tapi di v1 hanya menampilkan activity milik diri sendiri (belum ada follow/following).

- Sumber data: tabel `activities` (Section 6.8), berisi campuran tipe activity (`reading_session`, `badge_unlocked`, dst) diurutkan berdasarkan `occurred_at` terbaru.
- Tiap item feed tampil sebagai "card" ringkas sesuai `activity_type`:
  - **Reading session**: cover buku, judul, durasi, halaman dibaca, speed (ppm).
  - **Badge unlocked**: icon badge, nama badge, deskripsi singkat — dengan tampilan lebih "celebratory" (mis. warna aksen berbeda) dibanding activity biasa.
- Data feed **tidak langsung ditulis oleh Core API** saat request submit sesi/unlock badge — melainkan oleh **Feed Service** yang men-_consume_ event dari RabbitMQ secara async (lihat Section 5.2/5.3), supaya submit sesi tetap cepat direspons ke user meski proses "menulis ke feed" berjalan di belakang layar (biasanya selesai dalam hitungan detik).
- Di v1, `visibility` pada setiap row `activities` default `'private'` — feed hanya terlihat oleh pemiliknya. Field ini sudah disiapkan sejak awal supaya saat Phase 2 (Social) aktif, tidak perlu migrasi skema, cukup ubah logic query feed untuk menyertakan activity dari user yang di-follow dengan `visibility != 'private'`.

### 3.10 Social (Phase 2 — sedang dikerjakan)

- Follow/unfollow user lain.
- Social feed: menampilkan `activities` dari user yang di-follow (query `activities` + join `follows`, filter `visibility`), bukan tabel/skema baru — lihat Section 6.8.
- Kudos/like & komentar pada activity — nempel ke `activities.id` (lihat `activity_likes`/`activity_comments` di Section 6.9).
- Privacy setting per user (default) & per activity (override, lewat kolom `visibility` di tiap row `activities`).
- Leaderboard (mingguan/bulanan) antar teman berdasarkan halaman/menit.
- Share activity card ke Instagram/WhatsApp Story (image generation) — di-generate dari data 1 row `activities`.

---

## 4. User Flow

### 4.1 High-Level Flow Diagram (deskripsi tekstual)

```
[Splash] → [Sign Up/Login] → [Onboarding Questions] → [Add First Book]
   → [Home/Dashboard]
        ├── [Search/Scan/Add Book] → [Book Detail] → [Add to Shelf]
        ├── [Start Session] → (Timer / Manual) → [Submit Session]
        │        → [Update Stats + Streak] → [Badge Evaluation] → [Badge Unlocked Modal?]
        ├── [Shelf] → [Book Detail] → [Session History] / [Edit Status]
        ├── [Heatmap] → [Day Detail]
        └── [Stats] → [Detail breakdown]
```

### 4.2 Flow: Tambah Buku via Scan ISBN

1. User tap "Add Book" → pilih "Scan ISBN".
2. Kamera aktif → arahkan ke barcode buku.
3. App decode barcode → dapat kode ISBN-13.
4. Call API internal `GET /books/lookup?isbn=xxxx` → backend cek cache lokal dulu, jika tidak ada → hit Google Books API.
5. Jika ditemukan → tampilkan preview (cover, judul, penulis, jumlah halaman) → user confirm → tersimpan ke `books` (jika belum ada) & `user_books` (shelf).
6. Jika tidak ditemukan → fallback ke form tambah manual (prefill ISBN).

### 4.3 Flow: Sesi Membaca (Timer Mode)

1. User pilih buku dari shelf "Reading" → tap "Start Session".
2. Timer mulai berjalan (state lokal di frontend: `RUNNING`).
3. User bisa Pause (Bloc state → `PAUSED`, catat `paused_at` di memory/local state) → Resume (Bloc state → `RUNNING`, catat `resumed_at`, hitung durasi pause tsb, append ke array pause lokal).
4. User tap "Stop" → app tampilkan ringkasan (total durasi aktif otomatis, prefill start_page dari progress terakhir) → user isi/edit `end_page`.
5. User tap "Save/Submit" → seluruh array pause dikirim sebagai satu field `pause_intervals` (jsonb) dalam payload `POST /sessions` (lihat contoh payload di Section 3.7 & kolom di Section 6.4) — tidak ada request terpisah per interval.
6. Backend proses: hitung `pages_read`, `speed_ppm`, update `user_books.current_page`, update streak, enqueue badge evaluation job.
7. Response ke frontend: ringkasan sesi + (jika ada) badge baru yang di-unlock → tampilkan celebratory modal.

### 4.4 Flow: Onboarding → First Session (Empty State Handling)

1. Setelah onboarding, jika user belum punya sesi, tampilkan CTA besar "Mulai sesi membaca pertamamu" di Home.
2. Jika user skip, tampilkan reminder push notification dalam 24 jam.

---

## 5. Architecture

### 5.1 High-Level Architecture Diagram (deskripsi)

```
┌───────────────────────┐        ┌─────────────────────────────────────┐
│    Mobile App          │        │           Backend (Go)                │
│    (Flutter + Bloc)    │        │                                       │
│                        │  HTTPS │  ┌─────────────┐   ┌───────────────┐  │
│  - Dio (HTTP client)   │◄──────►│  │ API Gateway  │──►│  Auth Module  │  │
│  - Timer logic (Bloc)  │        │  │ (Gin router) │   └───────────────┘  │
│  - Local persistence   │        │  └──────┬──────┘                      │
│    (sqflite/drift/     │        │         │                             │
│     Hive) for offline  │        │  ┌──────▼───────┐   ┌───────────────┐ │
│  - Barcode scanner     │        │  │  Core API     │──►│  Books Module │ │
│    (mobile_scanner)    │        │  │ (Gin + GORM)  │   │ (Google Books │─┼──► Google Books API
│  - Push notif client   │        │  │ Sessions,     │   │  cache lookup)│ │
└───────────────────────┘        │  │ Shelf, Stats  │   └───────────────┘ │
                                   │  └──────┬───────┘                     │
                                   │         │ enqueue (event: session.created) │
                                   │  ┌──────▼───────┐                     │
                                   │  │  Job Queue    │                     │
                                   │  │  (RabbitMQ, AMQP)      │            │
                                   │  │  - Badge Engine        │            │
                                   │  │  - Streak/Stats Calc   │            │
                                   │  │  - Notifications       │            │
                                   │  └──────┬───────┘                     │
                                   │         │                             │
                                   │  ┌──────▼───────┐   ┌───────────────┐ │
                                   │  │ PostgreSQL    │   │  Redis        │ │
                                   │  │ (primary DB,  │   │  (cache saja  │ │
                                   │  │  incl. jsonb  │   │   — search    │ │
                                   │  │  pause_intervals)  │   Google Books)│ │
                                   │  └──────────────┘   └───────────────┘ │
                                   │  ┌──────────────┐   ┌───────────────┐ │
                                   │  │ Object Storage│   │  OpenTelemetry │ │
                                   │  │ (S3 / MinIO — │   │  (traces,      │ │
                                   │  │  TBD)         │   │   metrics, log)│ │
                                   │  └──────────────┘   └───────────────┘ │
                                   └─────────────────────────────────────┘
```

### 5.2 Komponen Utama

| Komponen                                                  | Tanggung Jawab                                                                                                                                                                                                                      |
| --------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **API Gateway / Router**                                  | Gin router: routing, middleware (rate limiting, auth token validation, request logging)                                                                                                                                             |
| **Auth Module**                                           | Sign up/login (email, OAuth Google/Apple), JWT session token                                                                                                                                                                        |
| **Core API (modular monolith di Go, package per domain)** | Modul: Users, Books, Shelf, Sessions, Stats, Badges — masing-masing punya handler/service/repository layer (GORM)                                                                                                                   |
| **Books Module**                                          | Integrasi Google Books API, caching metadata buku di Postgres, lookup by ISBN                                                                                                                                                       |
| **Badge Engine**                                          | Consumer/worker yang subscribe ke event dari RabbitMQ (mis. `session.created`, `book.finished`) dan mengevaluasi rule badge secara async, tidak blocking response API                                                               |
| **Streak/Stats Aggregator**                               | Consumer/worker RabbitMQ + job terjadwal (cron) untuk hitung ulang streak & agregat statistik (`daily_reading_stats`)                                                                                                               |
| **Notification Service**                                  | Consumer/worker RabbitMQ (event: `badge.unlocked`, `streak.reminder`) yang mengirim push notification via FCM/APNs                                                                                                                  |
| **Feed Service**                                          | Consumer/worker RabbitMQ yang subscribe ke event `session.created`, `badge.unlocked` (dan tipe activity baru ke depan) → tulis row denormalized ke `activities` (Section 6.8) sebagai sumber home feed (v1) & social feed (Phase 2) |
| **Object Storage**                                        | Cover buku custom (manual add), avatar user — **S3 atau MinIO (masih dipertimbangkan, lihat catatan di 5.4)**                                                                                                                       |
| **PostgreSQL**                                            | Primary datastore (relasional; `jsonb` dipakai untuk field semi-terstruktur seperti `pause_intervals`, `favorite_genres`)                                                                                                           |
| **Redis**                                                 | Cache hasil search Google Books (murni caching)                                                                                                                                                                                     |
| **RabbitMQ**                                              | Message broker untuk seluruh async processing: Core API publish event, di-consume terpisah oleh Badge Engine, Streak/Stats Aggregator, dan Notification Service                                                                     |
| **OpenTelemetry (OTel)**                                  | Instrumentasi tracing & metrics lintas Core API, Books Module, publisher/consumer RabbitMQ — diekspor ke backend observability pilihan (mis. Grafana Tempo/Loki/Prometheus atau vendor APM)                                         |

### 5.3 Pertimbangan Desain Kunci

- **Async Badge Evaluation**: submit sesi harus cepat direspons ke user; Core API cukup publish event `session.created` ke RabbitMQ lalu langsung return response — evaluasi badge & update stats berat dilakukan oleh consumer terpisah agar tidak menambah latency submit.
- **Offline-first Session**: sesi (timer & manual) disimpan dulu di local storage mobile (Flutter, mis. `drift`/`sqflite`/`Hive`); retry mechanism untuk sync ke server saat koneksi tersedia kembali (idempotent submit menggunakan client-generated UUID/`client_id` untuk mencegah duplikasi — lihat 6.4).
- **Caching Google Books**: karena ada quota/rate-limit dari Google, hasil search & lookup ISBN disimpan di tabel `books` sebagai cache internal + shared antar user (1 buku yang sama tidak perlu query ulang ke Google Books oleh user lain).
- **Extensible Badge Rule Engine**: `trigger_type` & `trigger_value` disimpan sebagai data, bukan hardcoded logic, sehingga menambah badge baru tidak perlu deploy kode baru (idealnya) — cukup insert row baru + mapping evaluator function per `trigger_type` yang sudah generic (Go: map `trigger_type` string → evaluator function/interface). Consumer Badge Engine cukup subscribe ke event yang relevan dari RabbitMQ.
- **Observability by design**: karena OTel masuk stack sejak awal, setiap request (HTTP handler Gin), publish event, dan consumer RabbitMQ sebaiknya di-instrument trace-nya dari awal (propagate trace context lewat message headers) — memudahkan debug latency submit session → badge evaluation end-to-end di production.
- **Topologi RabbitMQ (usulan awal)**: 1 exchange utama bertipe `topic` (mis. `bacayu.events`), routing key per event (`session.created`, `book.finished`, `badge.unlocked`, dst), masing-masing consumer (Badge Engine, Stats Aggregator, Notification Service, **Feed Service**) bind queue sendiri ke routing key yang relevan. Tambahkan **dead-letter queue (DLQ)** per queue untuk menampung message yang gagal diproses berulang kali, agar mudah di-inspect/retry manual.
- **Feed dibangun dari event, bukan query gabungan**: home feed (v1) & social feed (Phase 2) dibaca murni dari tabel `activities` yang sudah denormalized — bukan hasil `UNION` runtime antara `reading_sessions` dan `user_badges`. Ini membuat sorting by waktu jadi murah (single table, single index) dan menambah tipe activity baru (mis. `kudos_received` di Phase 2) tidak mengubah query feed sama sekali.

### 5.4 Job Queue: RabbitMQ

Backend memakai **RabbitMQ** sebagai message broker untuk seluruh proses async (Badge Engine, Streak/Stats Aggregator, Notification Service). Beberapa catatan implementasi untuk tim Engineering:

- **Client library (Go):** `amqp091-go` (fork resmi pengganti `streadway/amqp` yang sudah tidak dimaintain) atau wrapper seperti `wagslane/go-rabbitmq` untuk kemudahan reconnect/retry otomatis.
- **Reliability:** aktifkan **publisher confirms** (memastikan message benar-benar diterima broker sebelum Core API anggap event terkirim) dan **consumer manual ack** (ack hanya setelah job selesai diproses, agar message tidak hilang kalau consumer crash di tengah proses).
- **Retry & DLQ:** gunakan `x-dead-letter-exchange` per queue untuk menangani message yang gagal diproses (mis. badge evaluation error) — message masuk DLQ setelah N kali retry, lalu bisa di-monitor/replay manual via management UI RabbitMQ.
- **Idempotency di consumer:** karena AMQP bisa mengirim message lebih dari sekali (at-least-once delivery), consumer (mis. Badge Engine) harus idempotent — misal cek `unique(user_id, badge_id)` di `user_badges` sebelum insert, supaya aman meski event `session.created` yang sama ter-consume dua kali.
- **Operasional:** RabbitMQ berjalan sebagai service terpisah (bisa via managed service seperti CloudAMQP, atau self-hosted dengan Docker + plugin `rabbitmq_management` untuk UI monitoring queue/DLQ).
- **Redis tetap dipertahankan** di stack, tapi perannya jadi murni caching (hasil search Google Books, dsb) — tidak lagi merangkap sebagai job queue backend.

> Detail implementasi kode (lokasi producer/consumer per fitur, contoh kode, aturan idempotency di level codebase) ada di [CLAUDE.md](../CLAUDE.md) Section 8 "Komunikasi Antar-Fitur: Event, Bukan Panggilan Langsung".

---

## 6. Database Schema

> Skema di bawah memperluas tabel `badges` yang sudah ada (dari file referensi) dan menambahkan tabel-tabel pendukung untuk fitur v1 (onboarding, shelf, search, session, stats, badge). Tipe kolom bersifat indikatif (PostgreSQL).

### 6.1 `users`

| Kolom                   | Tipe                                 | Keterangan                                                                                                                |
| ----------------------- | ------------------------------------ | ------------------------------------------------------------------------------------------------------------------------- |
| id                      | uuid (PK)                            |                                                                                                                           |
| email                   | varchar, unique                      |                                                                                                                           |
| password_hash           | varchar                              | nullable jika OAuth only                                                                                                  |
| name                    | varchar                              |                                                                                                                           |
| avatar_url              | varchar                              | nullable                                                                                                                  |
| timezone                | varchar                              | untuk kalkulasi streak/heatmap harian yang akurat                                                                         |
| favorite_genres         | text[] / jsonb                       | dari onboarding                                                                                                           |
| yearly_goal_books       | int                                  | nullable, target buku/tahun                                                                                               |
| daily_goal_minutes      | int                                  | nullable                                                                                                                  |
| current_streak          | int                                  | default 0, denormalized untuk performa                                                                                    |
| longest_streak          | int                                  | default 0                                                                                                                 |
| last_read_date          | date                                 | untuk kalkulasi streak                                                                                                    |
| privacy_default         | enum('private','followers','public') | dipersiapkan utk Phase 2                                                                                                  |
| onboarding_completed_at | timestamptz                          | nullable, NULL = belum selesai onboarding — ditambahkan saat implementasi mobile onboarding, dipakai untuk redirect login |
| created_at / updated_at | timestamptz                          |                                                                                                                           |

### 6.2 `books` (cache/master data buku, gabungan dari Google Books & manual)

| Kolom                   | Tipe                          | Keterangan                                             |
| ----------------------- | ----------------------------- | ------------------------------------------------------ |
| id                      | uuid (PK)                     |                                                        |
| source                  | enum('google_books','manual') |                                                        |
| google_books_id         | varchar                       | nullable, unique bila source=google_books              |
| isbn_10                 | varchar                       | nullable                                               |
| isbn_13                 | varchar                       | nullable, indexed                                      |
| title                   | varchar                       |                                                        |
| authors                 | text[]                        |                                                        |
| description             | text                          | nullable                                               |
| cover_url               | varchar                       | nullable                                               |
| total_pages             | int                           | nullable (bisa diisi/dikoreksi user saat manual)       |
| language                | varchar                       | ISO code, untuk badge diversity                        |
| genres                  | text[]                        | mapping dari Google Books categories atau input manual |
| published_date          | varchar                       |                                                        |
| created_by_user_id      | uuid (FK users)               | nullable, terisi jika source=manual                    |
| created_at / updated_at | timestamptz                   |                                                        |

### 6.3 `user_books` (Shelf)

| Kolom                   | Tipe                                            | Keterangan                                                                             |
| ----------------------- | ----------------------------------------------- | -------------------------------------------------------------------------------------- |
| id                      | uuid (PK)                                       |                                                                                        |
| user_id                 | uuid (FK users)                                 |                                                                                        |
| book_id                 | uuid (FK books)                                 |                                                                                        |
| status                  | enum('want_to_read','reading','finished','dnf') |                                                                                        |
| format                  | enum('physical','ebook','audiobook')            | nullable, dipakai utk badge format                                                     |
| current_page            | int                                             | default 0                                                                              |
| started_at              | timestamptz                                     | nullable                                                                               |
| finished_at             | timestamptz                                     | nullable                                                                               |
| rating                  | int                                             | nullable (1-5), opsional                                                               |
| is_reread               | boolean                                         | default false                                                                          |
| created_at / updated_at | timestamptz                                     |                                                                                        |
|                         |                                                 | unique(user_id, book_id) — atau izinkan multiple entries jika reread dihitung terpisah |

### 6.4 `reading_sessions`

| Kolom                   | Tipe                   | Keterangan                                                                                                                                                                                                                                                                |
| ----------------------- | ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| id                      | uuid (PK)              |                                                                                                                                                                                                                                                                           |
| client_id               | uuid                   | client-generated, untuk idempotency saat sync offline                                                                                                                                                                                                                     |
| user_id                 | uuid (FK users)        |                                                                                                                                                                                                                                                                           |
| user_book_id            | uuid (FK user_books)   |                                                                                                                                                                                                                                                                           |
| input_mode              | enum('timer','manual') |                                                                                                                                                                                                                                                                           |
| start_time              | timestamptz            |                                                                                                                                                                                                                                                                           |
| end_time                | timestamptz            |                                                                                                                                                                                                                                                                           |
| active_duration_seconds | int                    | durasi aktif (exclude pause), dihitung frontend, divalidasi kasar di backend                                                                                                                                                                                              |
| pause_count             | int                    | default 0, denormalized dari `jsonb_array_length(pause_intervals)` agar mudah di-query/index tanpa parse jsonb                                                                                                                                                            |
| pause_intervals         | **jsonb**              | array of `{paused_at, resumed_at}`, dikirim langsung dari frontend sebagai bagian payload final. Contoh: `[{"paused_at":"...","resumed_at":"..."}]`. Opsional/nullable — hanya untuk detail/analytics & badge lanjutan (mis. "Perfect Pace"), bukan untuk kalkulasi utama |
| start_page              | int                    |                                                                                                                                                                                                                                                                           |
| end_page                | int                    |                                                                                                                                                                                                                                                                           |
| pages_read              | int                    | generated/computed: end_page - start_page                                                                                                                                                                                                                                 |
| speed_ppm               | numeric(6,2)           | computed: pages_read / (active_duration_seconds/60)                                                                                                                                                                                                                       |
| session_date            | date                   | tanggal kalender (timezone user) dipakai untuk streak/heatmap                                                                                                                                                                                                             |
| created_at              | timestamptz            |                                                                                                                                                                                                                                                                           |
|                         |                        | unique(user_id, client_id) untuk idempotent submit                                                                                                                                                                                                                        |

> **Update:** interval pause tidak lagi disimpan sebagai tabel terpisah, melainkan sebagai kolom `jsonb` (`pause_intervals`) langsung di `reading_sessions` — lihat kolom terakhir tabel 6.4. Ini menyederhanakan schema karena data pause bersifat _write-once_ (dikirim sekali saat submit, tidak pernah di-query/update per-row secara individual) sehingga tidak perlu tabel & join relasional terpisah.

### 6.5 `badges` _(sudah ada, dari file referensi — dipertahankan strukturnya)_

| Kolom                   | Tipe                                                                     | Keterangan                                               |
| ----------------------- | ------------------------------------------------------------------------ | -------------------------------------------------------- |
| id                      | serial/uuid (PK)                                                         |                                                          |
| name                    | varchar                                                                  |                                                          |
| slug                    | varchar, unique                                                          |                                                          |
| description             | text                                                                     |                                                          |
| icon                    | varchar                                                                  | emoji/icon key                                           |
| image_url               | varchar                                                                  | nullable                                                 |
| category                | enum('milestone','streak','diversity','genre','speed','hidden','social') | _usulan tambah 'social' utk Phase 2_                     |
| trigger_type            | varchar                                                                  | key yang dipetakan ke evaluator function di Badge Engine |
| trigger_value           | numeric                                                                  | ambang batas                                             |
| is_hidden               | boolean                                                                  |                                                          |
| created_at / updated_at | timestamptz                                                              |                                                          |

### 6.6 `user_badges` (badge yang sudah di-unlock user)

| Kolom              | Tipe                       | Keterangan                                                        |
| ------------------ | -------------------------- | ----------------------------------------------------------------- |
| id                 | uuid (PK)                  |                                                                   |
| user_id            | uuid (FK users)            |                                                                   |
| badge_id           | uuid/int (FK badges)       |                                                                   |
| unlocked_at        | timestamptz                |                                                                   |
| trigger_session_id | uuid (FK reading_sessions) | nullable, sesi yang men-trigger unlock (untuk konteks/notifikasi) |
|                    |                            | unique(user_id, badge_id)                                         |

### 6.7 `daily_reading_stats` (denormalized, untuk heatmap performant)

| Kolom         | Tipe            | Keterangan                                                              |
| ------------- | --------------- | ----------------------------------------------------------------------- |
| id            | uuid (PK)       |                                                                         |
| user_id       | uuid (FK users) |                                                                         |
| date          | date            |                                                                         |
| total_minutes | int             |                                                                         |
| total_pages   | int             |                                                                         |
| session_count | int             |                                                                         |
|               |                 | unique(user_id, date) — di-upsert setiap ada sesi baru pada tanggal tsb |

### 6.8 `activities` (Home Feed & Social Feed — source utama)

Tabel ini adalah **single source untuk feed** (home feed personal di v1, jadi fondasi social feed di Phase 2). Diisi bukan langsung oleh Core API saat request masuk, melainkan oleh **Feed Service** yang men-_consume_ event relevan dari RabbitMQ (`session.created`, `badge.unlocked`, dst) — lihat Section 5.2/5.3. Dengan begini, feed tidak perlu query gabungan (`UNION`) antar `reading_sessions` dan `user_badges` saat runtime, dan mudah diperluas ke tipe activity baru tanpa mengubah query feed.

| Kolom         | Tipe                                                          | Keterangan                                                                                                                                                                                                                                                                                                                            |
| ------------- | ------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| id            | uuid (PK)                                                     |                                                                                                                                                                                                                                                                                                                                       |
| user_id       | uuid (FK users)                                               | pemilik activity                                                                                                                                                                                                                                                                                                                      |
| activity_type | enum('reading_session','badge_unlocked','book_finished', ...) | extensible — tambah value baru untuk tipe activity baru (mis. `kudos_received` di Phase 2) tanpa migrasi besar                                                                                                                                                                                                                        |
| reference_id  | uuid                                                          | FK longgar (polymorphic) ke `reading_sessions.id` atau `user_badges.id` tergantung `activity_type` — dipakai untuk deep-link/detail, bukan untuk render feed                                                                                                                                                                          |
| payload       | **jsonb**                                                     | **snapshot data denormalized** untuk render feed tanpa join — mis. utk `reading_session`: `{book_title, book_cover_url, pages_read, speed_ppm, active_duration_seconds}`; utk `badge_unlocked`: `{badge_name, badge_icon, badge_description}`. Snapshot ini tetap valid meski data sumber (mis. judul buku manual) berubah belakangan |
| occurred_at   | timestamptz                                                   | waktu activity terjadi (mis. `end_time` sesi, atau `unlocked_at` badge) — dipakai untuk sorting feed                                                                                                                                                                                                                                  |
| visibility    | enum('private','followers','public')                          | default `'private'` di v1 (fitur social belum aktif); dipakai Phase 2 untuk filter social feed                                                                                                                                                                                                                                        |
| created_at    | timestamptz                                                   | waktu row dibuat oleh Feed Service (bisa beda dgn `occurred_at` kalau ada delay proses async)                                                                                                                                                                                                                                         |

**Index penting:** `(user_id, occurred_at DESC)` untuk home feed personal (v1) dan nanti `(visibility, occurred_at DESC)` dikombinasikan dengan tabel `follows` untuk social feed (Phase 2).

> Catatan: `activity_likes` & `activity_comments` (Phase 2, lihat 6.9) mereferensikan `activities.id`, bukan langsung ke `reading_sessions`/`user_badges` — karena `activities` adalah satu-satunya "permukaan" yang muncul di feed, jadi like/comment cukup nempel di satu tempat generic.

### 6.9 Tabel pendukung lain

- `genres` (master list genre, jika ingin normalisasi alih-alih text[]).
- `notifications` (log notifikasi yang dikirim, untuk debugging & preferensi).
- `device_tokens`, `notification_logs` — ditambahkan saat implementasi fitur `notifications` (lihat CLAUDE.md/Execution Prompts).
- **(Phase 2 — status: sedang dikerjakan)** `follows` (follower_id, following_id, unique constraint kedua kolom, index kedua arah), `activity_likes` (activity_id FK `activities.id`, user_id, unique activity_id+user_id), `activity_comments` (activity_id FK `activities.id`, user_id, body, created_at). ~~`activity_privacy_overrides`~~ — **dihapus dari rencana**, override privacy per-activity cukup lewat update langsung kolom `visibility` yang sudah ada di tabel `activities` (Section 6.8), tidak perlu tabel terpisah.

### 6.10 Entity Relationship (ringkas)

```
users 1───* user_books *───1 books
users 1───* reading_sessions *───1 user_books   (pause_intervals disimpan inline sbg jsonb, bukan tabel terpisah)
users 1───* user_badges *───1 badges
users 1───* daily_reading_stats
users 1───* activities  (reference_id → reading_sessions.id ATAU user_badges.id, tergantung activity_type)
```

---

## 7. Tech Stack (Usulan)

#### Mobile

| Layer                        | Pilihan                                                                                                         | Keterangan                                                                                                                                         |
| ---------------------------- | --------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| Framework                    | **Flutter**                                                                                                     | Cross-platform, satu codebase iOS/Android                                                                                                          |
| State Management             | **Bloc** (`flutter_bloc`)                                                                                       | State management untuk timer/session lokal (event-driven, cocok utk state machine `RUNNING/PAUSED/STOPPED`), juga untuk state search, shelf, stats |
| HTTP Client                  | **Dio**                                                                                                         | Interceptor untuk auth token refresh, retry, logging request/response                                                                              |
| Local Persistence (offline)  | `drift` atau `sqflite`/`Hive` _(TBD, disarankan `drift` karena type-safe & reactive, cocok dipadukan dgn Bloc)_ | Simpan sesi (termasuk `pause_intervals`) sebelum sync ke backend saat offline                                                                      |
| Barcode Scanning             | `mobile_scanner` (ML Kit based)                                                                                 | Scan ISBN (EAN-13)                                                                                                                                 |
| Dependency Injection         | `get_it` + `injectable`                                                                                         | Umum dipakai berdampingan dengan Bloc                                                                                                              |
| Push Notification Client     | `firebase_messaging`                                                                                            | Terima push dari FCM                                                                                                                               |
| Local Charts (Stats/Heatmap) | `fl_chart`                                                                                                      | Bar/pie chart untuk stats, custom widget untuk heatmap kalender                                                                                    |

#### Backend

| Layer                      | Pilihan                                                                                                                 | Keterangan                                                                                                                                                 |
| -------------------------- | ----------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Bahasa                     | **Go (Golang)**                                                                                                         | Performant, concurrency native cocok untuk async job & high-throughput API                                                                                 |
| Web Framework              | **Gin**                                                                                                                 | Router + middleware (auth, rate limit, request logging, CORS)                                                                                              |
| ORM                        | **GORM**                                                                                                                | Model mapping ke PostgreSQL, termasuk dukungan `jsonb` (mis. `pause_intervals`, `favorite_genres`) via custom type/`datatypes.JSON`                        |
| Database                   | **PostgreSQL**                                                                                                          | Relasional kuat, `jsonb` & array type cocok untuk kebutuhan skema Section 6                                                                                |
| Cache                      | **Redis**                                                                                                               | Cache untuk hasil search Google Books (murni caching layer)                                                                                                |
| Job Queue / Message Broker | **RabbitMQ**                                                                                                            | Async processing untuk Badge Engine, Streak/Stats Aggregator, Notification Service — lihat detail topologi & rekomendasi implementasi di Section 5.4       |
| Observability              | **OpenTelemetry (OTel)**                                                                                                | Tracing & metrics untuk HTTP handler (Gin middleware) & publisher/consumer RabbitMQ; diekspor ke backend pilihan (mis. Grafana stack / vendor APM)         |
| Object Storage             | **S3 atau MinIO** _(masih dipertimbangkan — lihat catatan di bawah)_                                                    | Cover buku manual, avatar user                                                                                                                             |
| External Book Data         | **Google Books API**                                                                                                    | Sesuai requirement; fallback: input manual bila tidak ditemukan                                                                                            |
| Auth                       | JWT custom (Go) + OAuth2 (Google/Apple Sign-In)                                                                         | Konsisten dgn stack Go, hindari vendor lock-in Firebase Auth di sisi backend                                                                               |
| Push Notification          | **Firebase Cloud Messaging (FCM)**                                                                                      | Server-side kirim via Firebase Admin SDK (Go)                                                                                                              |
| Hosting/Infra              | Docker + container orchestration (mis. ECS/Fargate, Cloud Run, atau self-managed k8s — TBD sesuai preferensi infra tim) |                                                                                                                                                            |
| CI/CD                      | GitHub Actions                                                                                                          | Build, test, lint (Go: `golangci-lint`), deploy                                                                                                            |
| Analytics                  | Mixpanel / PostHog _(opsional, untuk funnel onboarding & engagement)_                                                   |                                                                                                                                                            |
| Dev Experience             | **Air** (hot reload untuk Go)                                                                                           | Auto-rebuild & restart saat development — lihat [CLAUDE.md](../CLAUDE.md) Section 13 untuk setup detail (2 config terpisah untuk `cmd/api` & `cmd/worker`) |

**Catatan — S3 vs MinIO (masih perlu keputusan):**
| Kriteria | S3 | MinIO |
|---|---|---|
| Operasional | Fully-managed, tidak perlu maintain infra | Self-hosted, perlu maintain server/cluster sendiri |
| Biaya | Pay-as-you-go, bisa lebih mahal di skala kecil-menengah kalau egress tinggi | Lebih murah jika sudah punya infra sendiri (VPS/bare-metal), tapi ada biaya operasional (SRE time) |
| Kompatibilitas | API S3 native | API S3-compatible — mudah migrasi antara keduanya (kode tidak perlu banyak berubah krn kompatibel) |
| Cocok untuk | Tim yang mau minim ops & scale cepat | Tim yang sudah punya infra sendiri / mau kontrol penuh data residency |

> Karena API-nya S3-compatible, keputusan ini **tidak blocking** untuk mulai development — bisa pakai interface storage generic di kode Go (mis. wrap dengan `minio-go` SDK yang juga bisa connect ke AWS S3) sehingga tinggal ganti config endpoint saat keputusan final diambil.

> Untuk detail lengkap struktur folder, convention penamaan, dan cara kode diorganisir (Clean Architecture + feature-first), lihat [CLAUDE.md](../CLAUDE.md) — tabel di atas adalah pilihan teknologinya, CLAUDE.md adalah "cara pakainya".

---

## 8. Open Questions / Untuk Didiskusikan

1. Apakah butuh **web app** di v1, atau mobile-only dulu?
2. Bagaimana kebijakan jika Google Books tidak punya `page_count` untuk buku tertentu (mempengaruhi speed_ppm)? Perlu fallback estimasi atau wajib manual input?
3. Apakah streak dihitung berdasarkan timezone device atau timezone yang di-set user secara eksplisit (menghindari abuse ganti timezone)?
4. Threshold minimum durasi sesi untuk dianggap valid (menghindari sesi "1 detik" untuk curi streak)?
5. Apakah butuh sistem anti-cheat sederhana untuk speed_ppm ekstrem (misal >20 ppm dianggap suspicious, perlu review)?
6. Prioritas badge tambahan di Section 3.8 — mana yang masuk v1 vs backlog?

---

_Dokumen ini adalah draft awal (v1.0) dan terbuka untuk revisi bersama tim Engineering & Design sebelum masuk fase technical design & sprint planning._
