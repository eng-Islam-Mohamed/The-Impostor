import 'package:bara_alsalfa/features/game_setup/presentation/categories_screen.dart';
import 'package:bara_alsalfa/features/game_setup/presentation/manage_subjects_screen.dart';
import 'package:bara_alsalfa/features/game_setup/presentation/players_screen.dart';
import 'package:bara_alsalfa/features/game_setup/presentation/setup_screen.dart';
import 'package:bara_alsalfa/features/home/presentation/home_screen.dart';
import 'package:bara_alsalfa/features/multiplayer/presentation/multiplayer_create_room_screen.dart';
import 'package:bara_alsalfa/features/multiplayer/presentation/multiplayer_hub_screen.dart';
import 'package:bara_alsalfa/features/multiplayer/presentation/multiplayer_join_room_screen.dart';
import 'package:bara_alsalfa/features/multiplayer/presentation/multiplayer_lobby_screen.dart';
import 'package:bara_alsalfa/features/multiplayer/presentation/multiplayer_room_screen.dart';
import 'package:bara_alsalfa/features/onboarding/presentation/onboarding_screen.dart';
import 'package:bara_alsalfa/features/profile/presentation/profile_screen.dart';
import 'package:bara_alsalfa/features/results/presentation/results_screen.dart';
import 'package:bara_alsalfa/features/round/presentation/round_screen.dart';
import 'package:bara_alsalfa/features/splash/presentation/splash_screen.dart';
import 'package:bara_alsalfa/features/stats/presentation/stats_screen.dart';
import 'package:bara_alsalfa/features/store/presentation/store_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: SplashScreen.routePath,
    routes: [
      GoRoute(
        path: SplashScreen.routePath,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: OnboardingScreen.routePath,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: HomeScreen.routePath,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: MultiplayerHubScreen.routePath,
        builder: (context, state) => const MultiplayerHubScreen(),
      ),
      GoRoute(
        path: MultiplayerCreateRoomScreen.routePath,
        builder: (context, state) => const MultiplayerCreateRoomScreen(),
      ),
      GoRoute(
        path: MultiplayerJoinRoomScreen.routePath,
        builder: (context, state) => const MultiplayerJoinRoomScreen(),
      ),
      GoRoute(
        path: MultiplayerLobbyScreen.routePath,
        builder: (context, state) => const MultiplayerLobbyScreen(),
      ),
      GoRoute(
        path: MultiplayerRoomScreen.routePath,
        builder: (context, state) => const MultiplayerRoomScreen(),
      ),
      GoRoute(
        path: SetupScreen.routePath,
        builder: (context, state) => SetupScreen(
          initialModeSlug: state.uri.queryParameters['mode'],
        ),
      ),
      GoRoute(
        path: PlayersScreen.routePath,
        builder: (context, state) => const PlayersScreen(),
      ),
      GoRoute(
        path: CategoriesScreen.routePath,
        builder: (context, state) => const CategoriesScreen(),
      ),
      GoRoute(
        path: ManageSubjectsScreen.routePath,
        builder: (context, state) => const ManageSubjectsScreen(),
      ),
      GoRoute(
        path: RoundScreen.routePath,
        builder: (context, state) => const RoundScreen(),
      ),
      GoRoute(
        path: ResultsScreen.routePath,
        builder: (context, state) => const ResultsScreen(),
      ),
      GoRoute(
        path: StoreScreen.routePath,
        builder: (context, state) => const StoreScreen(),
      ),
      GoRoute(
        path: StatsScreen.routePath,
        builder: (context, state) => const StatsScreen(),
      ),
      GoRoute(
        path: ProfileScreen.routePath,
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
});
