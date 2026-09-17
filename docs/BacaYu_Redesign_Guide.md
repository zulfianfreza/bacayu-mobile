# BacaYu — Style Guide

BacaYu ("Baca" + "Ayu" — dibaca dengan senang) adalah pelacak kebiasaan membaca bergaya "Strava untuk pembaca": gamified, sosial, dan ditujukan untuk audiens gen-Z Indonesia.

Arah visual saat ini: pergeseran dari nuansa hangat (cream) ke gaya **playful & bersih** yang terinspirasi Duolingo — latar putih bersih, outline tebal, dan tombol dengan efek "3D" — supaya interaksi terasa solid dan menyenangkan untuk ditekan, bukan sekadar dilihat.

## Prinsip visual

1. **Putih sebagai kanvas, warna sebagai kejutan.** Latar belakang selalu putih (`surface-100`). Warna brand (`primary`, `secondary`, `accent`) hanya muncul di elemen yang ingin ditonjolkan — tombol, progress, ikon pencapaian — bukan sebagai wash di background.
2. **Outline, bukan shadow blur.** Kartu dibatasi garis tebal (`surface-200` untuk kartu netral, warna brand untuk kartu yang ingin ditonjolkan), bukan soft drop-shadow.
3. **Tombol terasa bisa ditekan.** CTA utama pakai warna solid dengan shadow offset tebal di bawah, bukan blur, supaya terlihat seperti tombol fisik.
4. **Ikon = outline SVG tebal, bukan emoji.** Konsisten, scalable, tetap playful tanpa terasa generic.
5. **Tipografi bulat dan tegas.** Nunito tetap satu-satunya typeface — bentuknya sudah rounded, selaras dengan arah playful tanpa perlu ganti font.

## Warna

| Token                 | Hex       | Kegunaan                                                   |
| --------------------- | --------- | ---------------------------------------------------------- |
| `primary` (Tangerine) | `#FF6A3D` | Tombol CTA utama, ikon nav aktif, api streak               |
| `primary-pressed`     | `#C7501F` | Shadow offset bawah tombol primary (efek 3D)               |
| `primary-tint`        | `#FFF1EC` | Latar di belakang chip ikon/badge warna primary            |
| `secondary` (Lagoon)  | `#14B8A6` | Progress fill, sampul buku placeholder, highlight sekunder |
| `secondary-tint`      | `#ECFDF9` | Latar di belakang chip ikon/badge warna secondary          |
| `accent` (Sunshine)   | `#FFC93C` | Pencapaian, badge, elemen perayaan                         |
| `accent-tint`         | `#FFFCEB` | Latar di belakang chip ikon/badge warna accent             |
| `ink`                 | `#1F2937` | Teks utama, outline tebal pada avatar/ikon/progress bar    |
| `ink-muted`           | `#9CA3AF` | Teks sekunder, caption, ikon nav non-aktif                 |
| `ink-faint`           | `#D1D5DB` | Badge terkunci, ikon nav non-aktif                         |
| `surface-100`         | `#FFFFFF` | Latar halaman                                              |
| `surface-200`         | `#F2F2F2` | Border kartu netral, divider                               |

## Tipografi

Font: **Nunito** (Google Fonts). Semua teks UI mulai dari weight 700 ke atas — tidak ada regular/400 di UI utama, supaya kesan tegas dan playful konsisten.

| Style        | Size / Line-height | Weight                                       |
| ------------ | ------------------ | -------------------------------------------- |
| `display`    | 28px / 34px        | 900                                          |
| `display-sm` | 24px / 30px        | 900                                          |
| `h1`         | 22px / 28px        | 900                                          |
| `h2`         | 17px / 22px        | 800                                          |
| `body`       | 15px / 20px        | 700                                          |
| `body-sm`    | 13px / 18px        | 700                                          |
| `caption`    | 12px / 16px        | 800 (huruf kapital, letter-spacing renggang) |

## Spacing (skala 4px)

`space-1` 4px · `space-2` 8px · `space-3` 12px · `space-4` 16px · `space-5` 20px · `space-6` 24px (padding standar tepi layar)

## Radius

`radius-sm` 10px (chip kecil, thumbnail sampul buku) · `radius-md` 16px (tombol, tile badge) · `radius-lg` 20px (kartu, sheet) · `radius-pill` 999px (avatar, tab pill, FAB, track progress bar)

## Shadow (efek tombol 3D)

- `shadow-press-sm`: `0 4px 0 #C7501F` — tombol kecil
- `shadow-press-md`: `0 5px 0 #C7501F` — CTA lebar penuh

## Yang berubah dari versi sebelumnya

Versi sebelumnya memakai latar cream hangat (`#FFF8F2`) dan kartu bersandar pada soft shadow. Versi ini memindahkan seluruh permukaan ke putih, mengganti shadow lembut dengan outline tebal, dan menambahkan efek tombol 3D — sambil mempertahankan tiga warna brand inti (Tangerine, Lagoon, Sunshine) dan Nunito.

## Referensi mockup

Empat contoh layar (Home versi lama, Home baru, Rak Buku, Lencana) tersedia sebagai canvas mockup terpisah di: https://claude.ai/artifact/7fZKebdtJ18VCjxmtvL82b
