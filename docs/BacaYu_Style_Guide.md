# BacaYu — Design Style Guide

**Versi:** 1.0 (Draft)
**Tanggal:** 11 September 2026
**Brand personality:** Clean, playful, energetic, gen-Z — "membaca itu seru, bukan tugas sekolah."

**Dokumen Terkait:**
- [PRD BacaYu](./PRD_BacaYu.md) — spesifikasi produk & fitur
- [UI Generation Prompts](./BacaYu_UI_Generation_Prompts.md) — prompt siap pakai yang mengacu ke style guide ini
- [Style Preview (HTML)](./bacayu-style-preview.html) — pratinjau visual warna & tipografi

---

## 1. Brand Principles

BacaYu terasa seperti teman gym yang menyemangati, bukan aplikasi pelacak yang menghakimi. Tiga kata kunci yang memandu setiap keputusan visual:

| Prinsip | Artinya di UI |
|---|---|
| **Clean** | Banyak whitespace, 1 fokus per layar, tidak ada elemen dekoratif yang tidak fungsional. |
| **Playful** | Bentuk membulat (rounded), warna jenuh/vivid (bukan pastel pucat), micro-interaction yang terasa "hidup" saat ada pencapaian. |
| **Gen-Z** | Bahasa santai & to-the-point, komponen berbentuk pill/chip, badge terasa seperti sticker koleksi, bukan sertifikat formal. |

**Hindari:** nuansa "aplikasi kantoran" (biru korporat, serif formal, banyak border tipis abu-abu), dan hindari juga estetika "AI generic" seperti warna terracotta pudar di atas background krem dengan font serif besar — itu bukan arah BacaYu. Orange di BacaYu harus terasa **vivid & energik**, bukan muted/earthy.

---

## 2. Color System

### 2.1 Palet Inti (Named Colors)

| Nama | Hex | Peran |
|---|---|---|
| 🟠 **Tangerine** (Primary) | `#FF6A3D` | Warna utama brand: CTA utama, FAB "Start Session", elemen aktif/selected |
| 🍑 **Cloud Peach** (Base/Background) | `#FFF8F2` | Background utama app — krem hangat tapi jelas beda dari cliché `#F4F1EA` |
| ⚫ **Ink** (Text) | `#2B2117` | Warna teks utama — coklat sangat gelap, bukan hitam pekat, tetap hangat |
| 🌊 **Lagoon** (Secondary/Positive) | `#14B8A6` | Progress positif, "finished" status, elemen sekunder yang menyeimbangkan orange |
| ☀️ **Sunshine** (Accent/Celebration) | `#FFC93C` | Badge unlock, streak flame, elemen "pencapaian"/perayaan |
| 🍓 **Berry** (Alert/Danger) | `#FF4D6D` | Error, hapus data, warning kritis (streak akan putus, dsb) |

### 2.2 Ramp per Warna (untuk tint/shade — dipakai di background, hover, disabled state)

| Step | Tangerine (Primary) | Lagoon (Secondary) | Sunshine (Accent) | Slate (Cool neutral) |
|---|---|---|---|---|
| 50 (tint tipis, bg) | `#FFF1EB` | `#E6FBF8` | `#FFF8E1` | `#F8FAFC` |
| 100 (bg chip/badge) | `#FFE0D1` | `#B8F0E8` | `#FFEDB3` | `#F1F5F9` |
| 300 (border/icon muted) | `#FFA477` | `#5FD9CB` | `#FFDD7A` | `#CBD5E1` |
| 500 (base) | `#FF6A3D` | `#14B8A6` | `#FFC93C` | `#64748B` |
| 700 (hover/pressed, teks di atas tint) | `#D94A22` | `#0E8577` | `#D9A420` | `#334155` |
| 900 (teks di atas background terang, kontras tinggi) | `#8C2E12` | `#0A5A50` | `#8C6A0E` | `#0F172A` |

**Slate** adalah satu-satunya netral *dingin* di palet. Dipakai kalau sebuah permukaan memang harus terbaca sebagai "bukan hangat": divider di atas foto yang ramai, chrome sekunder, atau apa pun yang jadi keruh kalau pakai tint hangat. Untuk teks dan permukaan biasa tetap pakai Neutral (2.3) — jangan campur keduanya dalam satu blok. Slate punya step lengkap 50–900 (termasuk 200/400/600/800) karena dipakai sebagai netral fungsional, bukan cuma tint brand.

**Border kartu, border input, dan divider pakai `slate200`, bukan `line`.** Di atas permukaan putih, hairline hangat (`line`) terbaca keruh/kotor; `slate200` memberi garis yang bersih tanpa jadi biru. Ini berlaku untuk border kartu (`BorderedCard`), border input (`inputDecorationTheme` + `AuthTextField`), dan divider di dalam kartu. Kartu bertint boleh (dan sebaiknya) memakai border dari ramp warnanya sendiri — mis. kartu badge kuning pakai `sunshine300` — karena border abu di atas permukaan berwarna justru terbaca salah. `line` tetap dipakai sebagai **warna latar** chip/pill dan sel heatmap yang kosong, serta untuk chrome navigasi (border atas bottom nav).

**Tangga penuh (50–900).** Enam step di tabel di atas adalah jangkar yang dipakai sehari-hari. Tangerine, Lagoon, dan Sunshine semuanya punya tangga penuh: step antara duduk di tengah dua jangkarnya — hue & saturasi mengikuti jangkar, dan hasilnya selalu lebih gelap dari step di atasnya. Jarak antar-step mengikuti jangkar aslinya, jadi tidak seragam: **jangan "rapikan" nilai jangkarnya.**

| Step | Tangerine | Lagoon | Sunshine |
|---|---|---|---|
| 200 | `#FFC2A3` | `#8BE5D9` | `#FFE596` |
| 400 | `#FF895A` | `#38CAB8` | `#FCD25E` |
| 600 | `#EE592E` | `#327E75` | `#EAB630` |
| 800 | `#9C4830` | `#2E4E4A` | `#9A7C2F` |

Dipakai kalau butuh tingkat tint/shade yang lebih halus daripada enam jangkar (misal border yang harus lebih terang dari 300 tapi lebih tegas dari 100), atau saat dua step berdekatan perlu dibedakan.

### 2.3 Neutral / Grayscale (warm-tinted, bukan abu-abu netral)

| Nama | Hex | Peran |
|---|---|---|
| Ink | `#2B2117` | Teks utama (headline, body penting) |
| Ink Soft | `#6B5D50` | Teks sekunder/caption |
| Ink Faint | `#A79C8F` | Placeholder, disabled text |
| Line | `#EFE4D8` | Border/divider halus |
| Surface | `#FFFFFF` | Card di atas background Cloud Peach |
| Background | `#FFF8F2` | Page background |

### 2.4 Aturan Pemakaian
- **Satu warna aksen dominan per layar.** Tangerine untuk aksi utama (1 tombol primary per screen). Jangan taruh Tangerine, Lagoon, dan Sunshine bersamaan di elemen yang bersaing — pilih 1 sebagai fokus, sisanya jadi indikator status kecil (chip, icon).
- **Sunshine khusus untuk momen "achievement"** (badge unlock, confetti, streak milestone) — supaya psikologisnya tetap terasa spesial, jangan dipakai untuk elemen UI biasa (misal warna icon nav).
- **Lagoon untuk progres positif** yang bukan CTA utama — progress bar buku, status "Finished" di shelf, checkmark.
- **Kontras teks:** teks kecil (<18px) di atas warna solid Tangerine/Lagoon/Sunshine sebaiknya pakai `Ink` (#2B2117) atau putih dengan bobot semibold+ agar tetap terbaca — untuk teks body reguler ukuran kecil, gunakan warna solid ini hanya sebagai *background chip* dengan teks dari ramp step 700/900 warna yang sama (bukan putih), memastikan kontras aman.
- **Dark mode (opsional v1.x):** background gelap gunakan `#241A12` (bukan hitam pekat), surface card `#332619`, Tangerine tetap sama karena sudah cukup vivid untuk terlihat di background gelap.

### 2.5 Peran Semantik & Palet Tambahan

**Peran semantik** — pakai ini kalau yang dimaksud adalah *state*, bukan warna brand tertentu, supaya artinya sama di seluruh app:

| Peran | Token | Warna |
|---|---|---|
| Success | `AppColors.success` | Lagoon 500 `#14B8A6` — warna positif brand, sama dengan progress bar |
| Danger | `AppColors.danger` | Berry `#FF4D6D` — error & aksi merusak |
| Warning | `AppColors.warning` | Amber 500 `#F59E0B` — **sengaja bukan Sunshine**, karena Sunshine dikhususkan untuk momen achievement (2.4) |
| Info | `AppColors.info` | Blue 500 `#3B82F6` — satu-satunya biru di palet |

Untuk banner/alert, pasangkan base-nya dengan step 50 (latar) dan 700 (teks) dari keluarga yang sama — jangan taruh teks putih di atas step 500 yang terang.

**Palet tambahan (Tailwind v3).** Untuk hue yang tidak dimiliki brand: deret chart, aksen sekali pakai, state khusus. Setiap keluarga lengkap 50–900 dengan bentuk yang sama seperti ramp brand — `red`, `amber`, `green`, `blue`, `indigo`, `violet`, `purple`, `pink`, `cyan`. Nilainya diambil apa adanya dari Tailwind v3, jadi **jangan diubah**; kalau butuh hue lain (lime, emerald, sky, rose, dst.) tambahkan dengan pola yang sama. Ini palet pinjaman, bukan keputusan brand: chrome app tetap memakai palet brand di atas, dan aturan "satu aksen dominan per layar" (2.4) tetap berlaku.

---

## 3. Typography

### 3.1 Typeface
**Nunito** (Google Fonts) — satu keluarga font untuk seluruh app, dibedakan lewat weight & ukuran, bukan ganti-ganti font. Karakter rounded pada huruf `a`, `o`, `g` cocok dengan brand yang playful & approachable, dan Nunito sudah mendukung banyak weight (300–900) sehingga fleksibel untuk hierarki.

- **Display/Headline:** Nunito **ExtraBold (800)** — dipakai di angka besar (streak count, total halaman), judul halaman.
- **Subheading/Emphasis:** Nunito **Bold (700)**.
- **Body/UI text:** Nunito **SemiBold (600)** untuk label tombol/nav, **Regular (400)** untuk paragraf/deskripsi.
- **Caption/meta:** Nunito **Medium (500)**, ukuran kecil, warna Ink Soft.

> Alternatif jika butuh sedikit variasi untuk angka statistik besar (opsional): **Nunito Sans** tetap satu keluarga (varian yang sedikit lebih netral) khusus untuk angka besar di dashboard stats, supaya angka tetap mudah dibaca dalam ukuran besar tanpa terlalu "membulat".

### 3.2 Type Scale

| Token | Ukuran | Weight | Line-height | Contoh Pemakaian |
|---|---|---|---|---|
| `display-lg` | 40px | ExtraBold (800) | 1.15 | Angka streak besar di Home |
| `display-sm` | 28px | ExtraBold (800) | 1.2 | Judul halaman utama |
| `heading` | 20px | Bold (700) | 1.3 | Judul section/card |
| `subheading` | 16px | Bold (700) | 1.4 | Judul buku, nama badge |
| `body` | 15px | Regular (400) | 1.6 | Paragraf deskripsi |
| `body-strong` | 15px | SemiBold (600) | 1.5 | Label penting, harga, angka statistik kecil |
| `caption` | 13px | Medium (500) | 1.4 | Metadata, timestamp, helper text |
| `button` | 15px | SemiBold (600) | 1 | Label tombol & nav |

### 3.3 Aturan
- Sentence case di semua tempat — tidak ada ALL CAPS untuk label (termasuk untuk eyebrow/kategori kecil sekalipun; gunakan warna/berat huruf untuk hierarki, bukan kapital semua).
- Panjang baris body text idealnya < 60 karakter (mobile-first, layar sempit).
- Angka statistik (streak, halaman, speed) selalu pakai **tabular figures** Nunito supaya angka tidak "goyang" saat berubah (animasi counter).

---

## 4. Spacing, Radius & Elevation

### 4.1 Spacing Scale (berbasis 4px)
`4 · 8 · 12 · 16 · 20 · 24 · 32 · 40 · 48` px — gunakan kelipatan ini untuk padding/margin, jangan angka bebas.

### 4.2 Corner Radius — playful berarti *rounded*, bukan sedikit rounded
| Token | Radius | Pemakaian |
|---|---|---|
| `radius-sm` | 8px | Input field, chip kecil |
| `radius-md` | 16px | Card standar (buku, stats card) |
| `radius-lg` | 24px | Modal, bottom sheet, card besar |
| `radius-pill` | 999px | Tombol utama, badge/chip status, nav item aktif |

Filosofi: elemen yang bisa "ditekan" (button, chip, nav item) → pill/sangat rounded. Elemen yang menampung konten (card, sheet) → rounded medium-large tapi tidak pill.

### 4.3 Elevation
Hindari shadow abu-abu generik (`rgba(0,0,0,.1)` di semua card). Gunakan:
- **Flat card default:** tanpa shadow, cukup `Surface` putih di atas `Background` krem + border tipis `Line` (#EFE4D8).
- **Elevated (FAB, modal, badge unlock celebration):** shadow lembut namun **bertinta warna** — mis. FAB Tangerine pakai shadow `rgba(255,106,61,0.35)` (bukan abu-abu netral), supaya shadow terasa jadi bagian dari warna elemen itu sendiri, bukan tempelan generik.

---

## 5. Iconography

- Gaya ikon: **rounded/filled dengan sudut membulat** (bukan sharp outline tipis ala dashboard admin) — cocok dipadukan set ikon seperti **Phosphor Icons (weight: "fill" atau "duotone")** atau **Solar Icons (Bold/Broken)**.
- Ukuran dasar: 20px (inline/nav), 24px (tombol/card header), 32px+ (ilustrasi kosong/empty state).
- Ikon di dalam elemen berwarna (chip, badge) selalu pakai warna dari ramp step 700/900 warna latar yang sama (bukan hitam polos).
- Ikon kustom untuk fitur signature: **flame** (streak), **medal/sticker die-cut** (badge), **stopwatch bulat** (session timer) — bentuk dasar lingkaran/blob supaya konsisten dengan filosofi rounded.

---

## 6. Component Guidelines

### 6.1 Button
- **Primary:** pill shape, background Tangerine 500, teks Ink/putih semibold, radius-pill, ada sedikit "bounce" scale-down (0.96) saat ditekan.
- **Secondary:** pill shape, border 1.5px Tangerine 500, teks Tangerine 700, background transparan/putih.
- **Ghost/Tertiary:** tanpa border, teks Ink Soft, dipakai untuk aksi minor ("Lewati", "Batal").
- Satu tombol primary per layar — jangan ada 2 tombol Tangerine solid berdampingan.

### 6.2 FAB "Start Session"
- Bentuk lingkaran penuh, diameter ±60px, background Tangerine 500, ikon play/stopwatch putih 26px.
- Sedikit "mengambang" (elevated) di tengah bottom navigation, dengan shadow bertinta oranye (lihat 4.3).
- State aktif (sesi sedang berjalan): ganti warna FAB jadi Berry/merah muda sebagai indikator "recording", ikon berubah jadi stop/pause, dan tambahkan animasi pulse halus (bukan shadow statis) supaya user sadar sesi masih berjalan.

### 6.3 Card (Buku / Shelf)
- radius-md (16px), Surface putih, border tipis Line.
- Cover buku di kiri (rounded 8px, bukan kotak tajam), progress bar Lagoon tipis (4px, pill) di bawah judul untuk buku status "Reading".

### 6.4 Badge / Achievement
- Bentuk medali/sticker: lingkaran dengan sedikit "notch" di bawah (seperti pita medali) atau bentuk hexagon rounded — bukan kotak biasa.
- Badge terkunci: grayscale + opacity rendah, badge terbuka: warna penuh + subtle shine/shimmer saat pertama kali muncul.
- Modal unlock badge pakai Sunshine sebagai warna dominan + micro-animation "pop in" (scale dari 0.8 → 1 dengan sedikit overshoot/bounce).

### 6.5 Chip / Status Tag
- Pill shape penuh (radius-pill), padding horizontal lega (12–16px).
- Warna latar dari ramp step 100 warna terkait, teks dari ramp step 700 warna yang sama (mis. status "Reading" = Lagoon 100 bg + Lagoon 700 teks).

### 6.6 Bottom Navigation
- 4 tab + FAB tengah (lihat brainstorming navigasi sebelumnya): Home, Shelf, [FAB], Stats, Profile.
- Tab aktif: ikon filled + label Tangerine 700, tab inactive: ikon outline + label Ink Soft — hindari indikator garis bawah kaku ala web admin.

### 6.7 Heatmap
- Sel heatmap rounded (radius 4–6px, bukan kotak tajam ala GitHub asli), intensitas warna pakai ramp Tangerine (50→700) bukan hijau (supaya konsisten brand, beda dari kesan "commit code").

---

## 7. Motion & Micro-interactions

Ambil satu momen orkestrasi yang benar-benar terasa "seru", jangan taburkan animasi di semua tempat:
- **Badge unlock** = momen paling "boleh ramai": pop-in bounce + confetti ringan + haptic feedback (mobile) — ini titik utama untuk merasakan brand playful.
- **Streak bertambah:** ikon flame kecil "berkedip" sekali (scale pulse), bukan animasi looping terus-menerus.
- **Selebihnya (transisi antar tab, submit form):** transisi cepat & halus (150–200ms ease-out), tanpa bounce — supaya navigasi harian tetap terasa cepat, bukan lambat karena kebanyakan animasi.
- Hormati `reduced motion` (accessibility setting device) — matikan bounce/confetti, ganti dengan fade sederhana.

---

## 8. Voice & Tone (Copywriting)

Bahasa Indonesia santai, seperti teman ngobrol — bukan bahasa formal aplikasi korporat, tapi tetap jelas dan tidak berlebihan pakai bahasa gaul/singkatan yang bisa membingungkan.

| Situasi | Nada | Contoh |
|---|---|---|
| Empty state | Ajakan, bukan permintaan maaf | "Belum ada buku di sini. Yuk tambah bacaan pertamamu." (bukan "Belum ada data") |
| Sukses/konfirmasi | Singkat, tanpa "berhasil" berlebihan | "Sesi tersimpan." (bukan "Sesi berhasil disimpan dengan sukses!") |
| Error | Jelas apa yang salah + solusinya, tanpa nyalahin user | "Koneksi terputus. Sesi kamu aman kok, nanti otomatis ke-sync." |
| Badge unlock | Merayakan, personal | "Badge baru! Kamu resmi jadi Bookworm 📚" |
| Reminder streak | Menyemangati, tidak menghakimi/guilt-trip | "Streak kamu masih bisa diselamatkan hari ini." (bukan "Kamu belum baca hari ini!") |
| CTA tombol | Kata kerja aktif, 1–3 kata | "Mulai sesi", "Tambah buku" — bukan "Klik di sini" atau "Submit" |

**Hindari:** huruf kapital semua untuk penekanan ("BACA SEKARANG!!"), terlalu banyak emoji bertumpuk, nada yang terkesan menyalahkan/guilt-trip soal streak putus.

---

## 9. Accessibility Checklist

- Kontras teks minimal AA (4.5:1 untuk teks biasa, 3:1 untuk teks besar/bold ≥18px atau komponen UI) — untuk kombinasi warna vivid di atas, selalu pakai teks dari ramp step 700–900 di atas background step 50–100 warna yang sama, bukan warna acak.
- Target sentuh minimal 44×44px untuk semua elemen interaktif (tombol, nav item, chip yang bisa ditekan).
- Semua ikon fungsional (bukan dekoratif) punya label aksesibilitas (`contentDescription`/`semanticLabel` di Flutter).
- Jangan gunakan warna sebagai satu-satunya penanda status (mis. status buku) — selalu sertakan label teks/ikon, bukan cuma warna chip.

---

## 10. Referensi Implementasi Cepat (Flutter/Design Tokens)

```dart
// contoh token warna (Flutter ThemeExtension / const)
class BacaYuColors {
  static const tangerine500 = Color(0xFFFF6A3D);
  static const tangerine700 = Color(0xFFD94A22);
  static const lagoon500    = Color(0xFF14B8A6);
  static const sunshine500  = Color(0xFFFFC93C);
  static const berry500     = Color(0xFFFF4D6D);
  static const ink          = Color(0xFF2B2117);
  static const inkSoft      = Color(0xFF6B5D50);
  static const background   = Color(0xFFFFF8F2);
  static const surface      = Color(0xFFFFFFFF);
  static const line         = Color(0xFFEFE4D8);
}

// font family: 'Nunito' (Google Fonts package: google_fonts / pubspec local asset)
```

---

*Dokumen ini adalah draft awal (v1.0), terbuka untuk revisi bersama tim Design sebelum dituangkan ke Figma design system & Flutter theme.*
