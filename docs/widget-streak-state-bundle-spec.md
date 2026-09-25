# Spec — Widget Streak: State & Bundle

Dokumen ini mendefinisikan struktur data untuk widget streak BacaYu (home-screen), berdasarkan observasi pola Duolingo (3 screenshot, jam 08.01/09.48/10.10 — state sama, tampilan beda-beda).

## 1. Konsep

Satu **state** (kondisi logic: `read_today` + waktu + `current_streak`) punya beberapa **bundle**. Satu bundle = **1 background (gradient atau solid) + 1 mascot pose**, dipilih sebagai pasangan tetap (bukan independen) karena warna dan pose sama-sama membawa mood — pose "olahraga semangat" nggak cocok ditempel ke background bernuansa sedih.

**Gaya background:** soft, tone-on-tone dalam satu keluarga warna (misal biru tua → biru muda), bukan kombinasi lintas-hue yang kontras (misal oranye → biru). Sebagian bundle boleh pakai **warna solid polos**, nggak wajib gradient semua.

**Teks tidak ikut di-bundle secara ketat** — teks murni data string, biaya buat variasi tinggi (bisa 3-5 pilihan) tanpa nambah beban produksi aset visual. Jadi tiap bundle punya **pool teks sendiri** yang dirotasi random terpisah dari pemilihan bundle.

```
State
 └─ Bundle (background + mascot pose)  ← dipilih random, 1 per refresh state
     └─ Text pool (2–4 pilihan)        ← dipilih random terpisah, independen dari bundle
```

**Kapan re-roll:** bundle & teks dipilih ulang saat state berubah (misal dari `calm` ke `reminder`), bukan setiap siklus refresh widget (~30 menit) — supaya nggak terasa "flicker" berubah-ubah padahal state sama. Seed random disarankan `hash(user_id + date + state)` supaya konsisten sepanjang hari tapi beda tiap hari.

---

## 2. Daftar State & Bundle

### State: Calm
**Kondisi:** `read_today = false`, jam < 10:00
**Jumlah bundle:** 3

| Bundle | Background | Mascot Pose | Text Pool |
|---|---|---|---|
| Calm-A | Gradient biru → biru muda (`#7EC8E3` → `#D6EFFA`) | Duduk santai peluk buku, senyum | "Bacaaa yuk!" · "Ada waktu buat baca?" |
| Calm-B | Solid biru pastel (`#BFE3F5`) | Pose olahraga semangat, buku di tangan | "Mulai lebih awal!" · "Semangat pagi!" |
| Calm-C | Gradient mint → mint muda (`#8FD9C4` → `#E0F7EF`) | Ngantuk, mata setengah tertutup, menguap | "Belajar pagi-pagi?" · "Masih ngantuk ya?" |

### State: Reminder
**Kondisi:** `read_today = false`, jam 10:00–22:00
**Jumlah bundle:** 3

| Bundle | Background | Mascot Pose | Text Pool |
|---|---|---|---|
| Reminder-A | Gradient peach → peach muda (`#FFB88C` → `#FFE3D0`) | Lirik jam sambil pegang buku | "Belum baca hari ini?" · "Waktunya baca, nih!" |
| Reminder-B | Solid krem hangat (`#FFD9B3`) | Duduk gelisah, nunjuk buku | "Jangan lupa baca ya!" · "Sisa waktu makin tipis" |
| Reminder-C | Gradient coral → coral muda (`#FF9F80` → `#FFD9CC`) | Mengetuk-ngetuk buku, menunggu | "Yuk sisihin waktu bentar" · "Streak-mu nunggu nih" |

### State: Urgent
**Kondisi:** `read_today = false`, jam 22:00–23:30
**Jumlah bundle:** 2

| Bundle | Background | Mascot Pose | Text Pool |
|---|---|---|---|
| Urgent-A | Gradient navy → navy muda (`#3A4A7A` → `#6C7BA8`) | Peluk buku erat, khawatir | "Streak-mu mau hilang!" · "Ayo sebelum kemalaman!" |
| Urgent-B | Solid indigo redup (`#4B5A8A`) | Lirik ke atas gelisah, keringat dingin | "Cepetan, waktu hampir habis!" · "Jangan sampai putus!" |

### State: Critical
**Kondisi:** `read_today = false`, jam > 23:30
**Jumlah bundle:** 2

| Bundle | Background | Mascot Pose | Text Pool |
|---|---|---|---|
| Critical-A | Gradient merah tua → merah redup (`#7A2E3A` → `#B5495B`) | Panik, tangan terulur ke depan | "Last chance!" · "Sekarang atau nggak sama sekali!" |
| Critical-B | Solid merah marun redup (`#8C3A47`) | Mata melotot, ekspresi tegang | "Baca sekarang atau hilang!" · "Detik-detik terakhir!" |

### State: Repair
**Kondisi:** `current_streak == 0` (baru reset)
**Jumlah bundle:** 2

| Bundle | Background | Mascot Pose | Text Pool |
|---|---|---|---|
| Repair-A | Gradient abu kebiruan (`#8FA3AD` → `#B7C4C9`) | Lesu, bahu turun, buku tertutup | "Yuk mulai lagi" · "Nggak apa-apa, coba lagi" |
| Repair-B | Solid abu lembut (`#A9B8BD`) | Sedih tapi ada kilau harapan di mata | "Semua orang pernah gagal" · "Ayo bangkit lagi!" |

### State: Done
**Kondisi:** `read_today = true`
**Jumlah bundle:** 3

| Bundle | Background | Mascot Pose | Text Pool |
|---|---|---|---|
| Done-A | Gradient emas → emas muda (`#FFDE9E` → `#FFF3D6`) | Peluk buku, bangga | "Mantap, udah baca!" · "Kerja bagus hari ini!" |
| Done-B | Solid peach lembut (`#FFCBA4`) | Jempol ke atas, senyum lebar | "Keren, streak aman!" · "Terus lanjutkan!" |
| Done-C | Gradient hijau muda → hijau pastel (`#B8E3C9` → `#E8F7EE`) | Loncat kecil senang | "Sampai besok ya!" · "Istirahat, kamu hebat!" |

### State: Frozen Safe *(opsional — kalau fitur streak freeze dibuat)*
**Kondisi:** streak dilindungi item freeze, belum baca hari ini
**Jumlah bundle:** 1

| Bundle | Background | Mascot Pose | Text Pool |
|---|---|---|---|
| Frozen-A | Solid biru pucat (`#D6F0FB`) | Santai dalam bubble es tipis | "Streak-mu aman" · "Dilindungi buat hari ini" |

---

## 3. Ringkasan Kebutuhan Aset

| Kategori | Jumlah |
|---|---|
| State | 6 wajib + 1 opsional (Frozen) |
| Bundle (= mascot pose unik + background unik) | 15 wajib + 1 opsional = **16 mascot PNG**, **16 background XML** (gradient atau solid) |
| Text pool total | ~30 baris string (disimpan sebagai data, bukan aset gambar) |

## 4. Open Questions

1. **Heatmap 7-hari (layout 2:1):** dot polos + checkmark aja (seperti contoh Duolingo), atau perlu diferensiasi warna dot sesuai intensitas menit baca (seperti heatmap kalender di Section 3.3 PRD)?
2. **Jumlah bundle per state** di atas (3/3/2/2/2/3/1) — sudah pas atau ada yang mau ditambah/dikurangi sebelum masuk produksi aset?
3. **Bundle unik per user per hari** — apakah re-roll bundle boleh sama dengan hari sebelumnya (full random), atau perlu dihindari 1-2 hari terakhir biar nggak berturut-turut sama?
