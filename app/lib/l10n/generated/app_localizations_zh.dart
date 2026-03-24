// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '局外人';

  @override
  String get settings => '设置';

  @override
  String get darkMode => '深色模式';

  @override
  String get darkModeSubtitle => '夜间更舒适的体验';

  @override
  String get haptics => '触觉反馈';

  @override
  String get hapticsSubtitle => '揭示角色时的触觉反馈';

  @override
  String get sound => '声音';

  @override
  String get soundSubtitle => '音效和音乐';

  @override
  String get reducedMotion => '减少动效';

  @override
  String get reducedMotionSubtitle => '更轻的过渡动画';

  @override
  String get language => '语言';

  @override
  String get languageSubtitle => '选择应用语言';

  @override
  String get followMe => '关注我';

  @override
  String get openLinkError => '无法打开链接';

  @override
  String get builtBy => '由 Benaboud Mohamed Islam 开发';

  @override
  String get copyright => '© 局外人';

  @override
  String get home => '主页';

  @override
  String get store => '商店';

  @override
  String get statistics => '统计';

  @override
  String get appTagline => '更快的回合，更聪明的揭示，带有阿拉伯风情。';

  @override
  String get startYourNight => '开始你的夜晚';

  @override
  String lastSavedSetup(String mode, int playerCount) {
    return '上次设置：$mode • $playerCount 名玩家';
  }

  @override
  String get startNewGame => '开始新游戏';

  @override
  String get quickRound => '快速回合';

  @override
  String get manageStories => '管理故事';

  @override
  String get readyModes => '今晚可用模式';

  @override
  String get viewAll => '查看全部';

  @override
  String get comingSoon => '即将推出';

  @override
  String get featuredCategories => '精选类别';

  @override
  String get packOfTheDay => '今日精选';

  @override
  String get tonightChallenge => '今晚挑战';

  @override
  String get tonightChallengeDesc => '连续玩两轮，不淘汰任何玩家。';

  @override
  String get premium => '高级版';

  @override
  String get story => '故事';

  @override
  String get stories => '故事';

  @override
  String storyCount(int count) {
    return '$count 个故事';
  }

  @override
  String get addStory => '添加故事';

  @override
  String get enterStory => '输入故事';

  @override
  String get outsider => '局外人';

  @override
  String get youAreOutsider => '你是局外人';

  @override
  String get oneOfYouIsOutsider => '你们中有一个是局外人';

  @override
  String get chooseOutsider => '选择你认为的局外人';

  @override
  String get outsiderIs => '局外人是';

  @override
  String get outsidersAre => '局外人们是';

  @override
  String get players => '玩家';

  @override
  String get player => '玩家';

  @override
  String playerCount(int count) {
    return '$count 名玩家';
  }

  @override
  String get addPlayer => '添加玩家';

  @override
  String get enterPlayerName => '输入玩家姓名';

  @override
  String minPlayersRequired(int min) {
    return '至少需要 $min 名玩家';
  }

  @override
  String get classic => '经典';

  @override
  String get classicSubtitle => '原始模式';

  @override
  String get quick => '快速';

  @override
  String get quickSubtitle => '更短的回合';

  @override
  String get teams => '团队';

  @override
  String get teamsSubtitle => '两队竞争';

  @override
  String get family => '家庭';

  @override
  String get familySubtitle => '适合所有人的故事';

  @override
  String get chaos => '混乱';

  @override
  String get chaosSubtitle => '颠覆规则和惊喜';

  @override
  String get round => '回合';

  @override
  String roundNumber(int number) {
    return '第 $number 回合';
  }

  @override
  String get revealPhase => '揭示阶段';

  @override
  String get cluePhase => '线索阶段';

  @override
  String get discussionPhase => '讨论阶段';

  @override
  String get votingPhase => '投票阶段';

  @override
  String get guessPhase => '猜测阶段';

  @override
  String get yourRole => '你的角色';

  @override
  String get yourTopic => '故事';

  @override
  String get tapToReveal => '点击揭示';

  @override
  String get hideRole => '隐藏角色';

  @override
  String get nextPlayer => '下一位玩家';

  @override
  String get startRound => '开始回合';

  @override
  String get endRound => '结束回合';

  @override
  String get vote => '投票';

  @override
  String get votes => '票数';

  @override
  String voteCount(int count) {
    return '$count 票';
  }

  @override
  String get confirmVote => '确认投票';

  @override
  String get changeVote => '更改投票';

  @override
  String get guess => '猜测';

  @override
  String get guessTheTopic => '猜测故事';

  @override
  String get correctGuess => '正确！';

  @override
  String get wrongGuess => '错误！';

  @override
  String get results => '结果';

  @override
  String get winner => '获胜者';

  @override
  String get winners => '获胜者们';

  @override
  String get insidersWin => '知情者获胜！';

  @override
  String get outsiderWins => '局外人获胜！';

  @override
  String get playAgain => '再玩一次';

  @override
  String get backToHome => '返回主页';

  @override
  String get points => '积分';

  @override
  String pointsCount(int count) {
    return '$count 分';
  }

  @override
  String get totalPoints => '总积分';

  @override
  String get timer => '计时器';

  @override
  String get seconds => '秒';

  @override
  String get timeUp => '时间到！';

  @override
  String get continue_ => '继续';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '确认';

  @override
  String get skip => '跳过';

  @override
  String get done => '完成';

  @override
  String get save => '保存';

  @override
  String get delete => '删除';

  @override
  String get edit => '编辑';

  @override
  String get add => '添加';

  @override
  String get close => '关闭';

  @override
  String get back => '返回';

  @override
  String get next => '下一步';

  @override
  String get yes => '是';

  @override
  String get no => '否';

  @override
  String get selectCategories => '选择类别';

  @override
  String get categories => '类别';

  @override
  String get category => '类别';

  @override
  String get allCategories => '所有类别';

  @override
  String get setup => '设置';

  @override
  String get gameSetup => '游戏设置';

  @override
  String get selectMode => '选择模式';

  @override
  String get selectPlayers => '选择玩家';

  @override
  String get onboardingTitle1 => '欢迎来到局外人';

  @override
  String get onboardingDesc1 => '一个有趣的团体游戏，找出谁不知道话题';

  @override
  String get onboardingTitle2 => '如何玩';

  @override
  String get onboardingDesc2 => '一个人不知道故事，其他人试图找出他';

  @override
  String get onboardingTitle3 => '开始';

  @override
  String get onboardingDesc3 => '召集你的朋友，开始乐趣';

  @override
  String get getStarted => '开始';

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
  String get selectLanguage => '选择语言';

  @override
  String get languageChanged => '语言已更改';
}
