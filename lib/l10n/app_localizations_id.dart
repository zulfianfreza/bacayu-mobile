// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get retry => 'Coba lagi';

  @override
  String get cancel => 'Batal';

  @override
  String get save => 'Simpan';

  @override
  String get loading => 'Memuat...';

  @override
  String get somethingWentWrong => 'Ada yang salah. Coba lagi ya.';

  @override
  String get noInternetConnection =>
      'Koneksi terputus. Nanti otomatis ke-sync kalau sudah online lagi.';

  @override
  String get fieldRequired => 'Wajib diisi.';

  @override
  String get sessionNotFound => 'Sesi membaca tidak ditemukan.';

  @override
  String get appName => 'BacaYu';

  @override
  String get email => 'Email';

  @override
  String get password => 'Kata sandi';

  @override
  String get name => 'Nama';

  @override
  String get login => 'Masuk';

  @override
  String get register => 'Daftar';

  @override
  String get welcomeBack => 'Selamat datang kembali';

  @override
  String get continueWithGoogle => 'Lanjutkan dengan Google';

  @override
  String get orDivider => 'atau';

  @override
  String get createYourAccount => 'Buat akunmu';

  @override
  String get dontHaveAccount => 'Belum punya akun? Daftar';

  @override
  String get alreadyHaveAccount => 'Sudah punya akun? Masuk';

  @override
  String get emailAlreadyExists => 'Email ini sudah terdaftar.';

  @override
  String get invalidCredentials => 'Email atau kata sandi salah.';

  @override
  String get sessionExpired => 'Sesi berakhir, silakan login lagi.';

  @override
  String get searchBooksHint => 'Cari judul, penulis, atau ISBN';

  @override
  String get scanBarcode => 'Scan barcode';

  @override
  String get scanIsbnGuide => 'Arahkan barcode ke dalam bingkai';

  @override
  String get addToShelf => 'Tambah ke rak';

  @override
  String get bookAddedToShelf => 'Ditambahkan ke rakmu.';

  @override
  String get noSearchResults => 'Buku tidak ditemukan. Coba kata kunci lain.';

  @override
  String pagesCount(int pages) {
    return '$pages halaman';
  }

  @override
  String byAuthor(String authors) {
    return 'oleh $authors';
  }

  @override
  String get bookNotFound => 'Buku tidak ditemukan.';

  @override
  String get alreadyInShelf => 'Buku ini sudah ada di rakmu.';

  @override
  String get shelfTitle => 'Rak bukuku';

  @override
  String get filterAll => 'Semua';

  @override
  String get statusWantToRead => 'Ingin dibaca';

  @override
  String get statusReading => 'Sedang dibaca';

  @override
  String get statusFinished => 'Selesai';

  @override
  String get statusDnf => 'DNF';

  @override
  String get changeStatus => 'Ubah status';

  @override
  String get emptyShelfHeadline => 'Rak kamu masih kosong';

  @override
  String get emptyShelfBody => 'Tambah buku pertamamu buat mulai nge-track';

  @override
  String get addABook => 'Tambah buku';

  @override
  String pageProgress(int current, int total) {
    return 'Halaman $current dari $total';
  }

  @override
  String get onboardingWelcomeHeadline =>
      'Lacak bacaanmu, kayak Strava ngelacak larimu';

  @override
  String get onboardingWelcomeBody =>
      'Pasang target, catat tiap sesi baca, dan jaga streak tetap hidup.';

  @override
  String get getStarted => 'Mulai';

  @override
  String get iAlreadyHaveAnAccount => 'Saya sudah punya akun';

  @override
  String get whatDoYouLoveReading => 'Kamu suka baca apa?';

  @override
  String get yearlyReadingGoal => 'Target baca setahun';

  @override
  String booksPerYear(int count) {
    return '$count buku/tahun';
  }

  @override
  String get continueLabel => 'Lanjut';

  @override
  String get addFirstBookHeadline => 'Tambah buku pertamamu ke rak';

  @override
  String get searchTitleOrAuthorHint => 'Cari judul atau penulis';

  @override
  String get scanIsbn => 'Scan ISBN';

  @override
  String get addManually => 'Tambah manual';

  @override
  String get illDoThisLater => 'Nanti aja';

  @override
  String get bookTitle => 'Judul';

  @override
  String get bookAuthors => 'Penulis';

  @override
  String get bookTotalPages => 'Jumlah halaman';

  @override
  String get genreFiction => 'Fiksi';

  @override
  String get genreNonFiction => 'Non-fiksi';

  @override
  String get genreFantasy => 'Fantasi';

  @override
  String get genreRomance => 'Romansa';

  @override
  String get genreSelfHelp => 'Pengembangan diri';

  @override
  String get genreComics => 'Komik';

  @override
  String get genreMystery => 'Misteri';

  @override
  String get genreBiography => 'Biografi';

  @override
  String get genreSciFi => 'Fiksi ilmiah';

  @override
  String get genrePoetry => 'Puisi';

  @override
  String get whatAreYouReading => 'Lagi baca buku apa?';

  @override
  String get noReadingBooks =>
      'Belum ada buku yang lagi dibaca. Tambah dulu ke rakmu.';

  @override
  String get bookPickerSubtitle =>
      'Pilih buku yang sedang kamu baca untuk memulai sesi.';

  @override
  String get timeJustNow => 'Baru saja';

  @override
  String timeMinutesAgo(int count) {
    return '$count mnt lalu';
  }

  @override
  String timeHoursAgo(int count) {
    return '$count jam lalu';
  }

  @override
  String timeDaysAgo(int count) {
    return '$count hari lalu';
  }

  @override
  String pausesSoFar(int count) {
    return '$count kali jeda';
  }

  @override
  String sessionPauses(int count) {
    return '$count jeda';
  }

  @override
  String pausedTotal(String duration) {
    return 'total $duration';
  }

  @override
  String get sessionBadgesTitle => 'Badge dari sesi ini';

  @override
  String get sessionSummary => 'Ringkasan sesi';

  @override
  String get totalDuration => 'Total durasi';

  @override
  String get startPage => 'Halaman awal';

  @override
  String get endPage => 'Halaman akhir';

  @override
  String get saveSession => 'Simpan sesi';

  @override
  String get sessionSaved => 'Sesi tersimpan';

  @override
  String get sessionModeTitle => 'Catat sesi';

  @override
  String get chooseSessionMode => 'Mau dicatat bagaimana?';

  @override
  String get startTimerOption => 'Mulai timer';

  @override
  String get startTimerOptionBody => 'Lacak langsung sambil kamu baca.';

  @override
  String get addManualOptionBody =>
      'Baca tanpa timer? Isi halaman dan berapa lama bacanya.';

  @override
  String get manualSessionTitle => 'Sesi manual';

  @override
  String get dateLabel => 'Tanggal';

  @override
  String get todayLabel => 'Hari ini';

  @override
  String get durationLabel => 'Durasi';

  @override
  String get minutesShort => 'menit';

  @override
  String get invalidDuration => 'Isi berapa lama kamu membaca.';

  @override
  String get invalidPageRange =>
      'Halaman akhir harus lebih besar dari halaman awal.';

  @override
  String get newBadge => 'Badge baru!';

  @override
  String get tabHome => 'Home';

  @override
  String get tabShelf => 'Rak';

  @override
  String get tabStats => 'Statistik';

  @override
  String get tabProfile => 'Profil';

  @override
  String get comingSoon => 'Segera hadir';

  @override
  String get startSession => 'Mulai sesi';

  @override
  String get yourStats => 'Statistikmu';

  @override
  String get rangeWeek => 'Minggu ini';

  @override
  String get rangeMonth => 'Bulan ini';

  @override
  String get rangeYear => 'Tahun ini';

  @override
  String get rangeAll => 'Sepanjang waktu';

  @override
  String get metricBooksFinished => 'Buku selesai';

  @override
  String get metricPagesRead => 'Halaman dibaca';

  @override
  String get metricTimeReading => 'Waktu membaca';

  @override
  String get metricAvgSpeed => 'Kecepatan rata-rata (ppm)';

  @override
  String get statsHeatmapTitle => 'Aktivitas membaca';

  @override
  String get statsGenresTitle => 'Genre favorit';

  @override
  String get yourBadges => 'Badge kamu';

  @override
  String get seeAll => 'Lihat semua';

  @override
  String get noBadgesYet => 'Belum ada badge — terus baca!';

  @override
  String get badgeGalleryTitle => 'Badge kamu';

  @override
  String badgesCollected(int unlocked, int total) {
    return '$unlocked dari $total terkumpul';
  }

  @override
  String get badgeUnlocked => 'Terbuka';

  @override
  String get badgeLocked => 'Terkunci';

  @override
  String get awesome => 'Keren!';

  @override
  String get activityNotAvailable => 'Aktivitas ini tidak tersedia.';

  @override
  String get bookSynopsis => 'Sinopsis';

  @override
  String speedPpmValue(String speed) {
    return '$speed ppm';
  }

  @override
  String homeGreeting(String name) {
    return 'Hai, $name';
  }

  @override
  String get dayStreak => 'hari beruntun';

  @override
  String longestStreakDays(int count) {
    return 'Terpanjang: $count hari';
  }

  @override
  String get viewFullHeatmap => 'Lihat heatmap lengkap';

  @override
  String get heatmapLess => 'Sedikit';

  @override
  String get heatmapMore => 'Banyak';

  @override
  String get continueReading => 'Lanjut baca';

  @override
  String get recentActivity => 'Aktivitas terbaru';

  @override
  String get findFriendsHeadline => 'Cari teman baca';

  @override
  String get findFriendsBody =>
      'Follow teman biar aktivitas bacanya muncul di sini.';

  @override
  String get findFriends => 'Cari teman';

  @override
  String get userSearchHint => 'Cari nama teman';

  @override
  String get noUserSearchResults => 'Tidak ada yang cocok';

  @override
  String get followersTitle => 'Pengikut';

  @override
  String get followingTitle => 'Mengikuti';

  @override
  String get leaderboardTitle => 'Papan peringkat';

  @override
  String get follow => 'Ikuti';

  @override
  String get followingButton => 'Mengikuti';

  @override
  String get followsYouBack => 'Follow kamu balik';

  @override
  String get noFollowers => 'Belum ada pengikut';

  @override
  String get noFollowing => 'Belum mengikuti siapa pun';

  @override
  String get yourPosition => 'Posisimu';

  @override
  String get addCommentHint => 'Tulis komentar...';

  @override
  String get commentsTitle => 'Komentar';

  @override
  String get postComment => 'Kirim';

  @override
  String get noComments => 'Belum ada komentar';

  @override
  String get changeVisibility => 'Ubah visibility';

  @override
  String get visibilityPrivate => 'Privat';

  @override
  String get visibilityFollowers => 'Pengikut';

  @override
  String get visibilityPublic => 'Publik';

  @override
  String get visibilityUpdated => 'Visibility diperbarui.';

  @override
  String get cannotFollowSelf => 'Kamu gak bisa follow diri sendiri.';

  @override
  String get alreadyLiked => 'Sudah di-like.';

  @override
  String get profileStatsBooks => 'Buku';

  @override
  String get profileStatsStreak => 'Streak';

  @override
  String get profileStatsBadges => 'Lencana';

  @override
  String get profileFollowersLabel => 'Pengikut';

  @override
  String get profileFollowingLabel => 'Mengikuti';

  @override
  String memberSince(String date) {
    return 'Bergabung sejak $date';
  }

  @override
  String get profileActivityTab => 'Aktivitas';

  @override
  String get profileSettingsTab => 'Pengaturan';

  @override
  String get noActivityYet =>
      'Belum ada aktivitas — mulai sesi baca buat lihat di sini.';

  @override
  String get readingGoals => 'Target membaca';

  @override
  String get dailyReadingGoal => 'Target membaca harian';

  @override
  String minutesPerDay(int count) {
    return '$count menit/hari';
  }

  @override
  String get goalsUpdated => 'Target diperbarui.';

  @override
  String get language => 'Bahasa';

  @override
  String get languageEnglish => 'Inggris';

  @override
  String get languageIndonesian => 'Bahasa Indonesia';

  @override
  String get appearance => 'Tampilan';

  @override
  String get appearanceSystem => 'Ikuti sistem';

  @override
  String get appearanceLight => 'Terang';

  @override
  String get appearanceDark => 'Gelap';

  @override
  String get privacy => 'Privasi';

  @override
  String get helpAndSupport => 'Bantuan';

  @override
  String get helpAndSupportBody =>
      'Butuh bantuan? Email kami di support@bacayu.app, kami akan balas secepatnya.';

  @override
  String get logOut => 'Keluar';

  @override
  String get logOutConfirmTitle => 'Keluar?';

  @override
  String get logOutConfirmBody => 'Kamu harus login lagi buat lanjut.';

  @override
  String get share => 'Bagikan';

  @override
  String get download => 'Unduh';

  @override
  String get shareSession => 'Bagikan sesi';

  @override
  String get savedToGallery => 'Tersimpan ke galeri';

  @override
  String get shareFailed => 'Gagal membagikan. Coba lagi ya.';

  @override
  String get saveImageFailed => 'Gagal menyimpan gambar.';

  @override
  String get shareStatTime => 'Waktu';

  @override
  String get shareStatPages => 'Halaman';

  @override
  String get shareStatSpeed => 'Kecepatan';

  @override
  String get shareStickerHint => 'Sticker transparan. Tempel di atas fotomu.';
}
