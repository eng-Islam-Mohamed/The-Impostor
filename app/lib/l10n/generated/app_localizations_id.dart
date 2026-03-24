// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Di Luar Cerita';

  @override
  String get settings => 'Pengaturan';

  @override
  String get darkMode => 'Mode Gelap';

  @override
  String get darkModeSubtitle => 'Pengalaman lebih tenang untuk sesi malam';

  @override
  String get haptics => 'Getaran';

  @override
  String get hapticsSubtitle => 'Umpan balik sentuhan saat mengungkap peran';

  @override
  String get sound => 'Suara';

  @override
  String get soundSubtitle => 'Efek suara dan musik';

  @override
  String get reducedMotion => 'Kurangi Animasi';

  @override
  String get reducedMotionSubtitle =>
      'Transisi lebih ringan untuk perangkat lambat';

  @override
  String get language => 'Bahasa';

  @override
  String get languageSubtitle => 'Pilih bahasa aplikasi';

  @override
  String get followMe => 'Ikuti Saya';

  @override
  String get openLinkError => 'Tidak dapat membuka tautan';

  @override
  String get builtBy => 'Dibuat oleh Benaboud Mohamed Islam';

  @override
  String get copyright => '© Di Luar Cerita';

  @override
  String get home => 'Beranda';

  @override
  String get store => 'Toko';

  @override
  String get statistics => 'Statistik';

  @override
  String get appTagline =>
      'Sesi lebih cepat, pengungkapan lebih cerdas, dengan sentuhan Arab.';

  @override
  String get startYourNight => 'Mulai Malammu';

  @override
  String lastSavedSetup(String mode, int playerCount) {
    return 'Pengaturan terakhir: $mode • $playerCount pemain';
  }

  @override
  String get startNewGame => 'Main Game Baru';

  @override
  String get quickRound => 'Ronde Cepat';

  @override
  String get manageStories => 'Kelola Cerita';

  @override
  String get readyModes => 'Mode Siap untuk Malam Ini';

  @override
  String get viewAll => 'Lihat Semua';

  @override
  String get comingSoon => 'Segera Hadir';

  @override
  String get featuredCategories => 'Kategori Unggulan';

  @override
  String get packOfTheDay => 'Paket Hari Ini';

  @override
  String get tonightChallenge => 'Tantangan Malam Ini';

  @override
  String get tonightChallengeDesc =>
      'Main dua ronde berturut-turut tanpa mengeliminasi pemain.';

  @override
  String get premium => 'Premium';

  @override
  String get story => 'Cerita';

  @override
  String get stories => 'Cerita';

  @override
  String storyCount(int count) {
    return '$count cerita';
  }

  @override
  String get addStory => 'Tambah Cerita';

  @override
  String get enterStory => 'Masukkan cerita';

  @override
  String get outsider => 'Orang Luar';

  @override
  String get youAreOutsider => 'Kamu Orang Luar';

  @override
  String get oneOfYouIsOutsider => 'Salah satu dari kalian adalah Orang Luar';

  @override
  String get chooseOutsider => 'Pilih siapa yang menurutmu Orang Luar';

  @override
  String get outsiderIs => 'Orang Luar adalah';

  @override
  String get outsidersAre => 'Orang-orang Luar adalah';

  @override
  String get players => 'Pemain';

  @override
  String get player => 'Pemain';

  @override
  String playerCount(int count) {
    return '$count pemain';
  }

  @override
  String get addPlayer => 'Tambah Pemain';

  @override
  String get enterPlayerName => 'Masukkan nama pemain';

  @override
  String minPlayersRequired(int min) {
    return 'Minimal $min pemain diperlukan';
  }

  @override
  String get classic => 'Klasik';

  @override
  String get classicSubtitle => 'Mode asli tanpa perubahan';

  @override
  String get quick => 'Cepat';

  @override
  String get quickSubtitle => 'Ronde lebih pendek untuk permainan ringan';

  @override
  String get teams => 'Tim';

  @override
  String get teamsSubtitle => 'Kompetisi antara dua tim';

  @override
  String get family => 'Keluarga';

  @override
  String get familySubtitle => 'Cerita aman untuk semua';

  @override
  String get chaos => 'Kekacauan';

  @override
  String get chaosSubtitle => 'Aturan terbalik dan kejutan';

  @override
  String get round => 'Ronde';

  @override
  String roundNumber(int number) {
    return 'Ronde $number';
  }

  @override
  String get revealPhase => 'Fase Pengungkapan';

  @override
  String get cluePhase => 'Fase Petunjuk';

  @override
  String get discussionPhase => 'Fase Diskusi';

  @override
  String get votingPhase => 'Fase Voting';

  @override
  String get guessPhase => 'Fase Tebakan';

  @override
  String get yourRole => 'Peranmu';

  @override
  String get yourTopic => 'Cerita';

  @override
  String get tapToReveal => 'Ketuk untuk Mengungkap';

  @override
  String get hideRole => 'Sembunyikan Peran';

  @override
  String get nextPlayer => 'Pemain Berikutnya';

  @override
  String get startRound => 'Mulai Ronde';

  @override
  String get endRound => 'Akhiri Ronde';

  @override
  String get vote => 'Vote';

  @override
  String get votes => 'Vote';

  @override
  String voteCount(int count) {
    return '$count vote';
  }

  @override
  String get confirmVote => 'Konfirmasi Vote';

  @override
  String get changeVote => 'Ubah Vote';

  @override
  String get guess => 'Tebak';

  @override
  String get guessTheTopic => 'Tebak Ceritanya';

  @override
  String get correctGuess => 'Benar!';

  @override
  String get wrongGuess => 'Salah!';

  @override
  String get results => 'Hasil';

  @override
  String get winner => 'Pemenang';

  @override
  String get winners => 'Pemenang';

  @override
  String get insidersWin => 'Yang Tahu menang!';

  @override
  String get outsiderWins => 'Orang Luar menang!';

  @override
  String get playAgain => 'Main Lagi';

  @override
  String get backToHome => 'Kembali ke Beranda';

  @override
  String get points => 'Poin';

  @override
  String pointsCount(int count) {
    return '$count poin';
  }

  @override
  String get totalPoints => 'Total Poin';

  @override
  String get timer => 'Timer';

  @override
  String get seconds => 'detik';

  @override
  String get timeUp => 'Waktu habis!';

  @override
  String get continue_ => 'Lanjutkan';

  @override
  String get cancel => 'Batal';

  @override
  String get confirm => 'Konfirmasi';

  @override
  String get skip => 'Lewati';

  @override
  String get done => 'Selesai';

  @override
  String get save => 'Simpan';

  @override
  String get delete => 'Hapus';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Tambah';

  @override
  String get close => 'Tutup';

  @override
  String get back => 'Kembali';

  @override
  String get next => 'Berikutnya';

  @override
  String get yes => 'Ya';

  @override
  String get no => 'Tidak';

  @override
  String get selectCategories => 'Pilih Kategori';

  @override
  String get categories => 'Kategori';

  @override
  String get category => 'Kategori';

  @override
  String get allCategories => 'Semua Kategori';

  @override
  String get setup => 'Pengaturan';

  @override
  String get gameSetup => 'Pengaturan Game';

  @override
  String get selectMode => 'Pilih Mode';

  @override
  String get selectPlayers => 'Pilih Pemain';

  @override
  String get onboardingTitle1 => 'Selamat Datang di Di Luar Cerita';

  @override
  String get onboardingDesc1 =>
      'Permainan grup yang menyenangkan untuk menemukan siapa yang tidak tahu topik';

  @override
  String get onboardingTitle2 => 'Cara Bermain';

  @override
  String get onboardingDesc2 =>
      'Satu orang tidak tahu ceritanya, yang lain mencoba menemukannya';

  @override
  String get onboardingTitle3 => 'Mulai Sekarang';

  @override
  String get onboardingDesc3 => 'Kumpulkan temanmu dan mulai keseruan';

  @override
  String get getStarted => 'Mulai';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => '中文';

  @override
  String get languageHindi => 'हिन्दी';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageBengali => 'বাংলা';

  @override
  String get languagePortuguese => 'Português';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageIndonesian => 'Bahasa Indonesia';

  @override
  String get selectLanguage => 'Pilih Bahasa';

  @override
  String get languageChanged => 'Bahasa diubah';
}
