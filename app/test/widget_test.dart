import 'package:bara_alsalfa/app/app.dart';
import 'package:bara_alsalfa/data/local/local_settings_store.dart';
import 'package:bara_alsalfa/domain/models/app_settings.dart';
import 'package:bara_alsalfa/features/profile/presentation/settings_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows Arabic home screen after splash when onboarding is complete',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsStoreProvider.overrideWithValue(_FakeSettingsStore()),
          initialAppSettingsProvider.overrideWithValue(
            const AppSettings.defaults().copyWith(onboardingSeen: true),
          ),
        ],
        child: const BaraApp(),
      ),
    );

    await tester.pump(const Duration(milliseconds: 1700));
    await tester.pumpAndSettle();

    expect(find.text('برا السالفة'), findsOneWidget);
    expect(find.text('ابدأ لعبة جديدة'), findsOneWidget);
  });
}

class _FakeSettingsStore implements SettingsStore {
  AppSettings _state = const AppSettings.defaults();

  @override
  Future<AppSettings> load() async => _state;

  @override
  Future<void> save(AppSettings settings) async {
    _state = settings;
  }
}
