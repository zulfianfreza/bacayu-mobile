# Panduan Prompt — Mascot Widget Streak BacaYu

16 pose mascot (transparan), 1 per bundle sesuai `widget-streak-state-bundle-spec.md`. Background (gradient/solid) dibuat langsung native XML — lihat spec doc, bukan bagian dari generate ini.

**Cara pakai:**
1. Upload maskot BacaYu yang sudah ada sebagai **image reference** ke tool generator.
2. Salin prompt per bundle di bawah — hasilnya PNG transparan, mascot diposisikan bawah-tengah dengan ruang kosong di atas & samping.
3. Simpan dengan nama file sesuai kolom "File", pasang di atas background drawable via `ImageView` overlay.

**Satu aset, dua rasio widget:** PNG yang sama dipakai untuk kedua layout tanpa generate ulang:
- **Layout 1:1** — `ImageView` mengisi kotak penuh, mascot muncul bawah-tengah sesuai desain aslinya.
- **Layout 2:1** — `ImageView` di-anchor ke bawah-kanan (`layout_gravity="bottom|end"`), aspect ratio dipertahankan (tidak di-stretch). Karena frame 2:1 lebih pendek dari kotak aslinya, bagian atas mascot boleh kepotong — itu diterima, yang penting bagian bawah-tengah tetap utuh dan nggak janggal.

---

## 1. Master Style

```
The exact same mascot character as in the reference image — chunky, plump, soft inflated 3D-render look, glossy highlights, soft volumetric shading, same colors (orange body, cream belly, teal glasses, yellow beak/feet), same proportions and design — redrawn only in a new pose/expression as described below. Do not redesign the character or flatten it into 2D vector art; match the reference's 3D toy-like rendering exactly. Composition: position the character bottom-center of the frame, horizontally centered, occupying roughly the bottom half of the canvas; leave the entire top area and generous side margins completely empty/transparent (no part of the character, hands, ears, or props there) — this space is reserved for a UI overlay added later. The character may extend slightly past the bottom edge only, never the top, left, or right. No scene, no background elements, no gradient, no ground, no shadow. Isolated on a fully transparent background. No text, no numbers, no UI elements. Square 1:1, 1024x1024.
```

**Negative prompt**

```
background, gradient, scenery, sky, ground, shadow, text, numbers, UI icons, watermark, flat 2D vector, flat illustration, different character design than reference, different color palette than reference, multiple characters
```

---

## 2. Daftar Prompt per Bundle

### State: Calm

**Calm-A** — `mascot_calm_a.png`
```
[Master style]. Pose: mascot sits comfortably holding a book, relaxed smile, calm and unhurried expression.
```

**Calm-B** — `mascot_calm_b.png`
```
[Master style]. Pose: mascot in an energetic morning-exercise stance, one arm raised, holding a book in the other hand, cheerful and lively expression.
```

**Calm-C** — `mascot_calm_c.png`
```
[Master style]. Pose: mascot looking sleepy, eyes half-closed, mid-yawn, holding a book loosely.
```

### State: Reminder

**Reminder-A** — `mascot_reminder_a.png`
```
[Master style]. Pose: mascot glancing sideways with a slightly concerned expression, holding a book, subtly aware time is passing.
```

**Reminder-B** — `mascot_reminder_b.png`
```
[Master style]. Pose: mascot sitting slightly restless, one hand pointing at a book beside it, mild insistent expression.
```

**Reminder-C** — `mascot_reminder_c.png`
```
[Master style]. Pose: mascot tapping the cover of a closed book with one finger, waiting expression, looking at the viewer.
```

### State: Urgent

**Urgent-A** — `mascot_urgent_a.png`
```
[Master style]. Pose: mascot clutching a book tightly against its chest, worried wide-eyed expression, clearly tense.
```

**Urgent-B** — `mascot_urgent_b.png`
```
[Master style]. Pose: mascot glancing upward anxiously, a small cold-sweat drop on its head, gripping a book.
```

### State: Critical

**Critical-A** — `mascot_critical_a.png`
```
[Master style]. Pose: mascot with a panicked expression, both hands reaching forward toward the viewer as if pleading, book dropped slightly.
```

**Critical-B** — `mascot_critical_b.png`
```
[Master style]. Pose: mascot with wide, alarmed eyes and a tense open-mouthed expression, gripping a book with both hands.
```

### State: Repair

**Repair-A** — `mascot_repair_a.png`
```
[Master style]. Pose: mascot sitting with slumped shoulders next to a closed book, sad and deflated expression.
```

**Repair-B** — `mascot_repair_b.png`
```
[Master style]. Pose: mascot looking down sadly but with a small hopeful glint in its eyes, one hand resting on a closed book.
```

### State: Done

**Done-A** — `mascot_done_a.png`
```
[Master style]. Pose: mascot hugging a book against its chest, proud warm smile.
```

**Done-B** — `mascot_done_b.png`
```
[Master style]. Pose: mascot giving a thumbs-up with a wide, cheerful smile, book resting beside it.
```

**Done-C** — `mascot_done_c.png`
```
[Master style]. Pose: mascot mid-jump, joyful expression, small motion lines, arms slightly raised in celebration.
```

### State: Frozen Safe *(opsional)*

**Frozen-A** — `mascot_frozen_a.png`
```
[Master style]. Pose: mascot sitting calmly, book held loosely, relaxed unbothered expression, a thin friendly ice-crystal outline traced only around the mascot's own silhouette (not a background element).
```

---

## 3. Tips Produksi

- **Konsistensi maskot:** selalu sertakan reference image yang sama di tiap generate — jangan biarkan tool re-imagine desain karakter.
- **Satu ekspresi per pose** — hindari gestur kompleks yang detailnya hilang di ukuran widget kecil (~180×110dp).
- **Transparansi asli:** cek alpha channel benar-benar transparan (bukan putih polos) sebelum dipasang di atas background.
- **Urutan generate:** kerjakan 1 bundle dulu (disarankan Calm-A) buat cek konsistensi gaya & transparansi sebelum lanjut ke 15 bundle lainnya.

## Checklist

| # | Bundle | File |Selesai |
|---|---|---|---|
| 1 | Calm-A | `mascot_calm_a.png` | [ ] |
| 2 | Calm-B | `mascot_calm_b.png` | [ ] |
| 3 | Calm-C | `mascot_calm_c.png` | [ ] |
| 4 | Reminder-A | `mascot_reminder_a.png` | [ ] |
| 5 | Reminder-B | `mascot_reminder_b.png` | [ ] |
| 6 | Reminder-C | `mascot_reminder_c.png` | [ ] |
| 7 | Urgent-A | `mascot_urgent_a.png` | [ ] |
| 8 | Urgent-B | `mascot_urgent_b.png` | [ ] |
| 9 | Critical-A | `mascot_critical_a.png` | [ ] |
| 10 | Critical-B | `mascot_critical_b.png` | [ ] |
| 11 | Repair-A | `mascot_repair_a.png` | [ ] |
| 12 | Repair-B | `mascot_repair_b.png` | [ ] |
| 13 | Done-A | `mascot_done_a.png` | [ ] |
| 14 | Done-B | `mascot_done_b.png` | [ ] |
| 15 | Done-C | `mascot_done_c.png` | [ ] |
| 16 | Frozen-A (opsional) | `mascot_frozen_a.png` | [ ] |
