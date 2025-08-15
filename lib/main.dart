import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_strategy/url_strategy.dart';
import 'camera_page.dart';
import 'dictionary_page.dart';
import 'register_page.dart';
import 'saved_page.dart';
import 'stt.dart';
import 'settings_page.dart';
import 'history_page.dart';
import 'home_page.dart';
import 'change_notifier/registration_controller.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'functions/translator.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //load model
  final translator = Translator();
  await translator.loadAllModels();  // You can store this translator in a provider or singleton if needed


  await Hive.initFlutter(); // ✅ Required for Hive to work
  setPathUrlStrategy();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => RegistrationController()),
         Provider<Translator>.value(value: translator),
      ],
      child: const MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Theme Demo',
      themeMode: themeProvider.themeMode,
      theme: ThemeProvider.lightTheme,
      darkTheme: ThemeProvider.darkTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/register': (context) => const RegisterPage(),
        '/dashboard': (context) => const DashboardScreen(),
        '/settings': (context) => const SettingsPage(),
        '/history': (context) => const HistoryPage(),
        '/saved': (context) => const SavedPage(),
        '/voice': (context) => const VoiceInputPage(),
        '/dictionary': (context) => const DictionaryPage(),
        '/camera': (context) => const CameraPage(),
        '/voice-input': (context) => const VoiceInputPage(),
      },
    );
  }
}

// ThemeProvider manages the app theme state
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme(bool isOn) {
    _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  // Custom light theme
  static final ThemeData lightTheme = ThemeData.light().copyWith(
    scaffoldBackgroundColor: const Color(0xFFFFFFFF),
    colorScheme: const ColorScheme.light(
      primary: Colors.lightBlueAccent,
      secondary: Colors.greenAccent,
      tertiary: Colors.lightGreenAccent,
      surface: Colors.white,
    ),
    cardColor: const Color.fromARGB(255, 196, 196, 196),
    hintColor: Colors.black54,
    dividerTheme: const DividerThemeData(color: Colors.black),
    drawerTheme: const DrawerThemeData(backgroundColor: Colors.white),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      iconTheme: IconThemeData(color: Colors.black),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: Colors.black,
      ),
    ).apply(bodyColor: Colors.black),
    dialogTheme: DialogThemeData(backgroundColor: Colors.white),
  );

  // Custom dark theme
  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: const Color(0xFF121212),
    colorScheme: const ColorScheme.dark(
      primary: Colors.blueAccent,
      secondary: Colors.tealAccent,
      tertiary: Colors.lightBlueAccent,
      surface: Color(0xFF686868),
    ),
    cardColor: Colors.blueGrey,
    hintColor: Colors.white,
    dividerTheme: const DividerThemeData(color: Colors.white),
    drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFF1E1E1E)),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF121212),
      iconTheme: IconThemeData(color: Colors.white),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: Colors.white,
      ),
    ).apply(bodyColor: Colors.white),
  );
}
