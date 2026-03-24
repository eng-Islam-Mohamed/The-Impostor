// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Вне Темы';

  @override
  String get settings => 'Настройки';

  @override
  String get darkMode => 'Тёмная Тема';

  @override
  String get darkModeSubtitle => 'Более спокойный опыт для ночных сессий';

  @override
  String get haptics => 'Вибрация';

  @override
  String get hapticsSubtitle => 'Тактильный отклик при раскрытии ролей';

  @override
  String get sound => 'Звук';

  @override
  String get soundSubtitle => 'Звуковые эффекты и музыка';

  @override
  String get reducedMotion => 'Уменьшить Анимации';

  @override
  String get reducedMotionSubtitle =>
      'Более лёгкие переходы для медленных устройств';

  @override
  String get language => 'Язык';

  @override
  String get languageSubtitle => 'Выберите язык приложения';

  @override
  String get followMe => 'Подписывайтесь';

  @override
  String get openLinkError => 'Не удалось открыть ссылку';

  @override
  String get builtBy => 'Создано Benaboud Mohamed Islam';

  @override
  String get copyright => '© Вне Темы';

  @override
  String get home => 'Главная';

  @override
  String get store => 'Магазин';

  @override
  String get statistics => 'Статистика';

  @override
  String get appTagline =>
      'Быстрые сессии, умные раскрытия, с арабским колоритом.';

  @override
  String get startYourNight => 'Начните Свой Вечер';

  @override
  String lastSavedSetup(String mode, int playerCount) {
    return 'Последняя настройка: $mode • $playerCount игроков';
  }

  @override
  String get startNewGame => 'Новая Игра';

  @override
  String get quickRound => 'Быстрый Раунд';

  @override
  String get manageStories => 'Управление Историями';

  @override
  String get readyModes => 'Режимы для Сегодняшнего Вечера';

  @override
  String get viewAll => 'Смотреть Все';

  @override
  String get comingSoon => 'Скоро';

  @override
  String get featuredCategories => 'Избранные Категории';

  @override
  String get packOfTheDay => 'Пак Дня';

  @override
  String get tonightChallenge => 'Сегодняшний Вызов';

  @override
  String get tonightChallengeDesc =>
      'Сыграйте два раунда подряд без выбывания игроков.';

  @override
  String get premium => 'Премиум';

  @override
  String get story => 'История';

  @override
  String get stories => 'Истории';

  @override
  String storyCount(int count) {
    return '$count историй';
  }

  @override
  String get addStory => 'Добавить Историю';

  @override
  String get enterStory => 'Введите историю';

  @override
  String get outsider => 'Чужак';

  @override
  String get youAreOutsider => 'Вы Чужак';

  @override
  String get oneOfYouIsOutsider => 'Один из вас — Чужак';

  @override
  String get chooseOutsider => 'Выберите, кто, по-вашему, Чужак';

  @override
  String get outsiderIs => 'Чужак — это';

  @override
  String get outsidersAre => 'Чужаки — это';

  @override
  String get players => 'Игроки';

  @override
  String get player => 'Игрок';

  @override
  String playerCount(int count) {
    return '$count игроков';
  }

  @override
  String get addPlayer => 'Добавить Игрока';

  @override
  String get enterPlayerName => 'Введите имя игрока';

  @override
  String minPlayersRequired(int min) {
    return 'Требуется минимум $min игроков';
  }

  @override
  String get classic => 'Классический';

  @override
  String get classicSubtitle => 'Оригинальный режим без изменений';

  @override
  String get quick => 'Быстрый';

  @override
  String get quickSubtitle => 'Короткие раунды для лёгкой игры';

  @override
  String get teams => 'Команды';

  @override
  String get teamsSubtitle => 'Соревнование двух команд';

  @override
  String get family => 'Семейный';

  @override
  String get familySubtitle => 'Безопасные истории для всех';

  @override
  String get chaos => 'Хаос';

  @override
  String get chaosSubtitle => 'Перевёрнутые правила и сюрпризы';

  @override
  String get round => 'Раунд';

  @override
  String roundNumber(int number) {
    return 'Раунд $number';
  }

  @override
  String get revealPhase => 'Фаза Раскрытия';

  @override
  String get cluePhase => 'Фаза Подсказок';

  @override
  String get discussionPhase => 'Фаза Обсуждения';

  @override
  String get votingPhase => 'Фаза Голосования';

  @override
  String get guessPhase => 'Фаза Угадывания';

  @override
  String get yourRole => 'Ваша Роль';

  @override
  String get yourTopic => 'История';

  @override
  String get tapToReveal => 'Нажмите для Раскрытия';

  @override
  String get hideRole => 'Скрыть Роль';

  @override
  String get nextPlayer => 'Следующий Игрок';

  @override
  String get startRound => 'Начать Раунд';

  @override
  String get endRound => 'Завершить Раунд';

  @override
  String get vote => 'Голосовать';

  @override
  String get votes => 'Голоса';

  @override
  String voteCount(int count) {
    return '$count голосов';
  }

  @override
  String get confirmVote => 'Подтвердить Голос';

  @override
  String get changeVote => 'Изменить Голос';

  @override
  String get guess => 'Угадать';

  @override
  String get guessTheTopic => 'Угадайте Историю';

  @override
  String get correctGuess => 'Правильно!';

  @override
  String get wrongGuess => 'Неправильно!';

  @override
  String get results => 'Результаты';

  @override
  String get winner => 'Победитель';

  @override
  String get winners => 'Победители';

  @override
  String get insidersWin => 'Посвящённые победили!';

  @override
  String get outsiderWins => 'Чужак победил!';

  @override
  String get playAgain => 'Играть Снова';

  @override
  String get backToHome => 'На Главную';

  @override
  String get points => 'Очки';

  @override
  String pointsCount(int count) {
    return '$count очков';
  }

  @override
  String get totalPoints => 'Всего Очков';

  @override
  String get timer => 'Таймер';

  @override
  String get seconds => 'секунд';

  @override
  String get timeUp => 'Время вышло!';

  @override
  String get continue_ => 'Продолжить';

  @override
  String get cancel => 'Отмена';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get skip => 'Пропустить';

  @override
  String get done => 'Готово';

  @override
  String get save => 'Сохранить';

  @override
  String get delete => 'Удалить';

  @override
  String get edit => 'Редактировать';

  @override
  String get add => 'Добавить';

  @override
  String get close => 'Закрыть';

  @override
  String get back => 'Назад';

  @override
  String get next => 'Далее';

  @override
  String get yes => 'Да';

  @override
  String get no => 'Нет';

  @override
  String get selectCategories => 'Выберите Категории';

  @override
  String get categories => 'Категории';

  @override
  String get category => 'Категория';

  @override
  String get allCategories => 'Все Категории';

  @override
  String get setup => 'Настройка';

  @override
  String get gameSetup => 'Настройка Игры';

  @override
  String get selectMode => 'Выберите Режим';

  @override
  String get selectPlayers => 'Выберите Игроков';

  @override
  String get onboardingTitle1 => 'Добро пожаловать в Вне Темы';

  @override
  String get onboardingDesc1 =>
      'Весёлая групповая игра, чтобы найти того, кто не знает тему';

  @override
  String get onboardingTitle2 => 'Как Играть';

  @override
  String get onboardingDesc2 =>
      'Один человек не знает историю, остальные пытаются его найти';

  @override
  String get onboardingTitle3 => 'Начните Сейчас';

  @override
  String get onboardingDesc3 => 'Соберите друзей и начните веселье';

  @override
  String get getStarted => 'Начать';

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
  String get selectLanguage => 'Выберите Язык';

  @override
  String get languageChanged => 'Язык изменён';
}
