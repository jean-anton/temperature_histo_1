//import 'package:aptabase_flutter/aptabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:aeroclim/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'features/weather/presentation/screens/home_screen.dart';
import 'features/weather/presentation/providers/weather_provider.dart';
import 'features/weather/data/weather_repository.dart';
import 'features/settings/presentation/providers/settings_provider.dart';
import 'features/locations/presentation/providers/location_provider.dart';
import 'features/locations/data/location_repository.dart';
import 'core/services/geolocation_service.dart';
import 'features/weather/presentation/widgets/utils/weather_tooltip.dart';
import 'core/config/app_config.dart';

const VERSION = "3.1.0";
String mainFileName = "/Users/jg/devel/projects/flutter/aeroclim";

// This custom scroll behavior enables touch-based scrolling on web platforms,
// which provides a more natural, app-like experience for mobile web users.
class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Catch unhandled background errors (like Aptabase background sync being blocked)
  // to prevent the debugger from pausing on them if possible, and to avoid crashes.
  PlatformDispatcher.instance.onError = (error, stack) {
    final errorStr = error.toString();
    if (errorStr.contains('aptabase') ||
        errorStr.contains('universal_io') ||
        errorStr.contains('XMLHttpRequest')) {
      debugPrint('CJG: Caught background network/analytics error: $error');
      return true; // handled
    }
    return false; // let other errors through
  };

  // try {
  //   // Wrap initialization in another layer of safety
  //   await Aptabase.init(AppConfig.aptabaseKey).timeout(
  //     const Duration(seconds: 5),
  //     onTimeout: () {
  //       debugPrint("Aptabase init timed out");
  //     },
  //   );
  //   print("###### CJG Aptabase init ${AppConfig.aptabaseKey}");

  //   // Explicitly handle errors for the unawaited tracking event
  //   Aptabase.instance.trackEvent("app_launched").catchError((e) {
  //     debugPrint(
  //       "Aptabase trackEvent failed (likely blocked by extension): $e",
  //     );
  //   });
  //   print("###### CJG Aptabase trackEvent called");
  // } catch (e) {
  //   debugPrint("Aptabase init failed: $e");
  // }
  // Initialize date formatting for supported locales
  await Future.wait([
    initializeDateFormatting('en', null),
    initializeDateFormatting('fr', null),
    initializeDateFormatting('de', null),
    initializeDateFormatting('es', null),
  ]);
  const isRunningWithWasm = bool.fromEnvironment('dart.tool.dart2wasm');
  print('###### CJG Running with Wasm: $isRunningWithWasm');

  runApp(
    MultiProvider(
      providers: [
        // Repositories
        Provider(create: (_) => WeatherRepository()),
        Provider(
          create: (_) => LocationRepository(
            FallbackGeolocationService([
              OpenMeteoGeolocationService(),
              PhotonGeolocationService(),
            ]),
          ),
        ),
        // Providers
        ChangeNotifierProvider(
          create: (context) =>
              WeatherProvider(context.read<WeatherRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider()..loadSettings(),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              LocationProvider(context.read<LocationRepository>())
                ..initialize(),
        ),
      ],
      child: const ClimaDeviationApp(),
    ),
  );
}

class ClimaDeviationApp extends StatelessWidget {
  const ClimaDeviationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
        Locale('de'),
        Locale('es'),
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A237E), // Deep Indigo
          primary: const Color(0xFF1A237E),
          surface: Colors.white,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.outfitTextTheme(
          const TextTheme(
            headlineMedium: TextStyle(
              fontWeight: FontWeight.w800,
              letterSpacing: -1.0,
            ),
            titleLarge: TextStyle(fontWeight: FontWeight.w700),
            bodyLarge: TextStyle(letterSpacing: 0.2),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
          ),
          clipBehavior: Clip.antiAlias,
          color: Colors.white.withValues(alpha: 0.9),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
            color: Color(0xFF1A237E),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        segmentedButtonTheme: SegmentedButtonThemeData(
          style: SegmentedButton.styleFrom(
            backgroundColor: Colors.grey.shade50,
            selectedBackgroundColor: const Color(0xFF1A237E),
            selectedForegroundColor: Colors.white,
            side: BorderSide(
              color: const Color(0xFF1A237E).withValues(alpha: 0.1),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
      builder: (context, child) {
        return Listener(
          onPointerDown: (event) {
            if (WeatherTooltip.isOpen) {
              final RenderBox? box =
                  WeatherTooltip.tooltipKey.currentContext?.findRenderObject()
                      as RenderBox?;
              if (box != null) {
                final pos = box.localToGlobal(Offset.zero);
                final rect = pos & box.size;
                if (!rect.contains(event.position)) {
                  WeatherTooltip.removeTooltip();
                }
              }
            }
          },
          child: child!,
        );
      },
      home: const HomeScreen(),
    );
  }
}
