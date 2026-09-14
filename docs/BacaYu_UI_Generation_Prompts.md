# BacaYu — UI Generation Prompts

Untuk dipakai di AI UI/code generator seperti **v0.dev, Galileo AI, Uizard, atau Figma AI (First Draft)**.

**Dokumen Terkait:**
- [Style Guide](./BacaYu_Style_Guide.md) — sumber semua token warna/tipografi yang dipakai di prompt ini
- [PRD BacaYu](./PRD_BacaYu.md) — referensi fitur & user flow per layar

**Cara pakai:**
1. Tempel **Master Design System Prompt** di bagian paling atas/pertama setiap prompt (atau di "project context"/"style" setting kalau toolnya mendukung context terpisah seperti v0 project instructions).
2. Lanjutkan dengan salah satu **prompt per layar** di bawahnya.
3. Prompt ditulis dalam Bahasa Inggris karena kebanyakan tool AI UI generator memberi hasil lebih konsisten dengan input Inggris — tapi silakan diterjemahkan kalau tool-nya mendukung Bahasa Indonesia dengan baik.

---

## 0. Master Design System Prompt (tempel di setiap prompt / project context)

```
You are designing screens for "BacaYu", a mobile reading-tracker app (like Strava, but for readers). Track reading sessions, streaks, and badges. Platform: mobile app (Flutter/Material 3 sensibility), portrait, single column, thumb-reachable layout.

Brand personality: clean, playful, energetic, Gen-Z. Feels like a supportive workout-tracking friend, not a corporate dashboard. Avoid generic SaaS-dashboard look, avoid muted/earthy "AI-generated" aesthetics (no dusty terracotta-on-cream palettes, no serif display fonts).

DESIGN TOKENS — follow exactly:

Colors:
- Primary "Tangerine": #FF6A3D (vivid orange, base), light tint #FFE0D1, dark shade for text-on-tint #D94A22
- Secondary "Lagoon" (positive/progress): #14B8A6, light tint #B8F0E8
- Accent "Sunshine" (celebration/achievement only): #FFC93C, light tint #FFEDB3
- Alert "Berry": #FF4D6D
- Text ink: #2B2117 (warm near-black, not pure black)
- Secondary text: #6B5D50
- Background: #FFF8F2 (warm cream, NOT the cliché #F4F1EA)
- Surface/card: #FFFFFF
- Border/divider: #EFE4D8

Typography:
- Single font family: Nunito (rounded, friendly sans-serif), weights 400/600/700/800
- Big numbers/stats: Nunito ExtraBold 800, large size
- Headings: Nunito Bold 700
- Body: Nunito Regular 400
- Buttons/labels: Nunito SemiBold 600
- Sentence case everywhere, never ALL CAPS, never a serif font

Shape & spacing:
- Buttons, chips, nav items, FAB: fully rounded / pill-shaped (border-radius 999px)
- Cards, sheets, modals: rounded corners 16-24px, NOT sharp corners
- Spacing scale based on 4px/8px grid, generous whitespace
- Shadows are soft and tinted with the element's own color (e.g. orange-tinted shadow under the orange FAB), never plain flat gray shadow

Components vocabulary:
- Primary button: pill shape, solid Tangerine background, white/ink bold label
- Secondary button: pill shape, Tangerine outline, transparent background
- Status chip: pill shape, light tint background + darker text of the same hue (e.g. "Reading" chip = Lagoon tint bg + Lagoon dark text)
- Badge/achievement: circular medal shape (not a plain square icon), Sunshine color when unlocked, grayscale + low opacity when locked
- Bottom navigation: 4 tabs + 1 centered floating circular FAB that overlaps/rises above the bar (like Strava's record button), FAB is solid Tangerine with a white play/stopwatch icon
- Progress bar: thin pill-shaped bar, Lagoon fill color

Do not use: generic blue as primary color, sharp/square corners, gray flat card shadows, serif fonts, ALL CAPS labels, cluttered layouts with more than one strong accent color competing per screen.
```

---

## 1. Onboarding (3 steps + empty-state first book)

```
Design a 3-screen onboarding flow for BacaYu, one screen shown at a time with a progress dot indicator at the top.

Screen 1 — Welcome: Large friendly headline "Track your reading like Strava tracks your run" (or Indonesian equivalent), a simple hero illustration area (rounded blob shapes, book + flame icon motif), primary pill button "Get started" at the bottom, secondary text link "I already have an account".

Screen 2 — Quick preferences: Heading "What do you love reading?", a wrap-grid of selectable pill chips for genres (Fiction, Non-fiction, Fantasy, Romance, Self-help, Comics, etc.) that highlight in Tangerine tint when selected, followed by a numeric stepper or slider for "yearly reading goal" (books per year), primary pill button "Continue" at bottom, fixed regardless of scroll.

Screen 3 — Add your first book: Heading "Add your first book to your shelf", a prominent search bar with a placeholder like "Search title or author", below it two quick-action pill buttons side by side: "Scan ISBN" (with a barcode icon) and "Add manually" (with a plus icon), and a skip link "I'll do this later" underneath.
```

---

## 2. Home / Dashboard

```
Design the Home dashboard screen for BacaYu.

Top: greeting header "Hi, {name}" with a small circular avatar top-right, no back button (this is a root tab).

Below greeting, a hero streak card: large Nunito ExtraBold number showing current streak in days, a small flame icon beside it, subtitle "day streak", card background is a soft Tangerine tint, rounded 20px corners.

Next, a compact 7-day heatmap strip (small rounded squares, one per day, color intensity from light Tangerine tint to solid Tangerine based on minutes read that day) with a "View full heatmap" text link.

Below that, a "Continue reading" section: a horizontal scrollable row of book cards (rounded cover thumbnail, title, thin Lagoon progress bar underneath) for books currently in "Reading" status.

Bottom: a section titled "Recent activity" showing 2-3 feed items in card form — one item type shows a completed reading session (book cover thumbnail, pages read, duration, speed in pages/min), another item type shows a badge unlocked (circular medal icon, badge name, celebratory Sunshine-tinted background).

Bottom navigation bar: 4 tabs (Home active, Shelf, Stats, Profile) with a centered floating circular orange FAB with a play icon rising above the bar, per the design system.
```

---

## 3. Shelf

```
Design the Shelf screen for BacaYu — the user's personal book collection.

Top app bar: title "My shelf", a search icon and a "+" add icon on the right (add icon opens search/scan/manual add options).

Below the app bar, a horizontal row of filter pill tabs: "All", "Want to read", "Reading", "Finished", "DNF" — active tab filled Tangerine, inactive tabs outlined/muted.

Main content: a vertical list of book cards. Each card: rounded book cover thumbnail on the left, title and author in the middle, a status pill chip (color-coded per status: Lagoon tint for Reading, Sunshine tint for Finished, neutral gray tint for Want to read), and for "Reading" status books, a thin progress bar showing current page / total pages underneath the title.

Include an empty state variant: friendly illustration, headline "Your shelf is empty", body text "Add your first book to start tracking", primary pill button "Add a book".
```

---

## 4. Search & Scan ISBN

```
Design a book search screen for BacaYu, reachable from the "+" button on Shelf.

Top: a large search input field with a magnifying glass icon and placeholder "Search title, author, or ISBN", autofocus state.

Below the search field, two equally-sized pill buttons side by side: "Scan barcode" (camera icon) and "Add manually" (pencil/plus icon).

Search results area: a vertical list of result cards, each showing book cover thumbnail, title, author, page count as a small caption, and a compact "+" pill button on the right to add directly to shelf.

Also design a second screen: the barcode scanner view — full-screen camera viewfinder with a horizontal scan-line guide box in the center (rounded corners on the guide frame), a caption below the frame "Point your camera at the barcode", and a bottom sheet that slides up once a book is found, showing the matched book's cover, title, author, and a primary pill button "Add to shelf".
```

---

## 5. Reading Session (Timer Mode)

```
Design the active reading session screen for BacaYu, opened from the center FAB.

Step 1 — Book picker (bottom sheet): rounded-top sheet sliding up from bottom, heading "What are you reading?", a short list of the user's "Reading" status books as tappable rows (cover thumbnail + title), each row selectable.

Step 2 — Timer running screen: full screen, centered large circular timer display (Nunito ExtraBold digits, MM:SS), the book's cover and title shown above the timer, below the timer two large circular icon buttons side by side: a Berry/red-tinted "Pause" button and outlined "Stop" button. A small caption below shows "X pauses so far" if the session has been paused before. Background uses a soft Tangerine tint to signal an active session, with a subtle pulsing ring animation implied around the timer circle.

Step 3 — Session summary (after Stop): a rounded card summary showing total duration, pages read (with two number steppers for start page and end page — start page prefilled), computed reading speed in pages/minute, and a primary pill button "Save session" at the bottom. If a badge was unlocked as a result, show a celebratory banner above the save button with the badge medal icon and name.
```

---

## 6. Stats

```
Design the Stats screen for BacaYu.

Top: title "Your stats" with a segmented control for time range ("This week", "This month", "This year", "All time") styled as a pill-shaped toggle group.

Below, a 2-column grid of metric cards (rounded, soft tinted backgrounds, each a different accent hue): "Books finished", "Pages read", "Time reading", "Avg. speed (ppm)" — each showing a large Nunito ExtraBold number and a small label underneath.

Below the grid, a full annual heatmap calendar (rounded small squares, Tangerine intensity scale) with month labels.

Below the heatmap, a horizontal bar chart showing genre distribution (bars colored using the Lagoon/Sunshine/Tangerine palette rotated per bar, rounded bar ends).

Bottom section: a horizontal scrollable row of badge medal icons (both unlocked in full color and locked in grayscale) under a heading "Your badges", with a "See all" text link.
```

---

## 7. Badge Unlocked (Celebration Modal)

```
Design a celebratory modal/bottom sheet for BacaYu shown when a user unlocks a new badge.

Full-width bottom sheet or centered modal with rounded 24px top corners, background a soft Sunshine tint. Center content: a large circular medal icon (Sunshine solid color, subtle shine/sparkle decoration around it), headline "New badge unlocked!" in Nunito ExtraBold, the badge name in Nunito Bold below it, and a one-line description in regular body text. Below that, a primary pill button "Nice!" or "Awesome" to dismiss. Include small decorative confetti-like shapes (soft rounded dots/triangles in Tangerine, Lagoon, and Sunshine) scattered around the medal for a playful celebratory feel.
```

---

## 8. Profile

```
Design the Profile screen for BacaYu.

Top: large circular avatar centered, user's name in Nunito Bold below it, a short stats summary row underneath (three items separated by thin dividers: "Books", "Streak", "Badges" each with a bold number and small label).

Below, a list of settings rows in a rounded card group: "Reading goals", "Notifications", "Appearance", "Privacy" (Phase 2 placeholder), "Help and support", "Log out" — each row with a leading icon, label, and trailing chevron, using generous padding and a subtle divider line between rows (not individual boxed cards).

Keep the overall tone quieter/less colorful than Home — Profile is a utility screen, so use mostly ink/neutral tones with Tangerine reserved only for the avatar ring accent and any active toggle switches.
```

---

## Tips Tambahan

- Kalau tool-nya (mis. v0 atau Figma AI) mendukung upload reference image, lampirkan juga `bacayu-style-preview.html` (screenshot-nya) sebagai referensi visual tambahan di samping prompt teks ini — kombinasi teks + referensi visual biasanya menghasilkan output lebih presisi ke warna/font yang dimaksud.
- Kalau hasil generate meleset di warna (banyak tool masih bias ke biru/ungu default), coba tegaskan ulang di akhir prompt: `"Reminder: primary color must be the vivid orange #FF6A3D, not blue or purple."`
- Untuk Uizard/Galileo yang kadang butuh prompt lebih singkat, potong Master Prompt jadi 4-5 baris inti (warna, font, shape, mood) saja per generate agar tidak terpotong oleh limit karakter tool tersebut.
