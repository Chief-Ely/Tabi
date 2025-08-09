import 'package:tabi/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'camera_page.dart';
import 'dictionary_page.dart';
import 'saved_page.dart';
import 'stt.dart';
import 'settings_page.dart';
import 'history_page.dart';
import 'home_page.dart';
import 'register_page.dart';
import 'change_notifier/registration_controller.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => RegistrationController()),
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
      title: 'TABI Translator',
      themeMode: themeProvider.themeMode,
      theme: ThemeProvider.lightTheme,
      darkTheme: ThemeProvider.darkTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/register': (context) => const RegisterPage(),
        '/dashboard': (context) => const DashboardScreen(),
        '/settings': (context) => const SettingsPage(),
        '/history': (context) => const HistoryPage(),
        '/saved': (context) => const SavedPage(),
        '/voice': (context) => const VoiceInputPage(),
        '/dictionary': (context) => const DictionaryPage(),
        '/camera': (context) => const CameraPage(),
      },
      builder: (context, child) {
        ErrorWidget.builder = (errorDetails) {
          return Scaffold(
            body: Center(child: Text('Error: ${errorDetails.exception}')),
          );
        };
        return child!;
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        if (snapshot.hasData && AuthService.isEmailVerified) {
          return const DashboardScreen();
        }

        return const RegisterPage();
      },
    );
  }
}

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme(bool isOn) {
    _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

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
  );

  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: const Color(0xFF121212),
    colorScheme: const ColorScheme.dark(
      primary: Colors.blueAccent,
      secondary: Colors.tealAccent,
      tertiary: Colors.lightBlueAccent,
      surface: Color.fromARGB(255, 0, 0, 0),
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
