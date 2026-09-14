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
}
