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
}
