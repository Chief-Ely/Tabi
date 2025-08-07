import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'camera_page.dart';
import 'dictionary_page.dart';
import 'register_page.dart';
import 'saved_page.dart';
import 'stt.dart';
import 'settings_page.dart';
import 'history_page.dart';
import 'services/auth_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      initialRoute: '/register',
      onGenerateRoute: (settings) {
        Widget page;
        switch (settings.name) {
          case '/':
            page = const SplashScreen();
            break;
          case '/register':
            page = StreamBuilder<User?>(
              stream: AuthService.userStream,
              builder: (context, snapshot) {
                return snapshot.hasData
                    ? const HomePage()
                    : const RegisterPage();
              },
            );
            break;
          case '/dashboard':
            page = const DashboardScreen();
            break;
          case '/settings':
            page = const SettingsPage();
            break;
          case '/history':
            page = const HistoryPage();
            break;
          case '/saved':
            page = const SavedPage();
            break;
          case '/voice':
            page = const VoiceInputPage();
            break;
          case '/dictionary':
            page = const DictionaryPage();
            break;
          case '/camera':
            page = const CameraPage();
            break;
          default:
            page = const RegisterPage();
        }
        return MaterialPageRoute(builder: (_) => page);
      },
    );
  }
}

// Splash screen with animation and image logo
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _colorAnimation = ColorTween(
      begin: Colors.blueAccent,
      end: Colors.tealAccent,
    ).animate(_controller);

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/register');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: _colorAnimation.value,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Image.asset(
                    'assets/logo_1.png',
                    width: 150,
                    height: 150,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'TABI',
                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 30),
                CircularProgressIndicator(
                  color: Colors.white.withOpacity(0.8),
                  strokeWidth: 3,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class NavigationDrawer extends StatelessWidget {
  const NavigationDrawer({super.key});

  @override
  Widget build(BuildContext context) => Drawer(
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[buildHeader(context), buildMenuItems(context)],
      ),
    ),
  );

  Widget buildHeader(BuildContext context) => Container(
    color: Colors.blue.shade700,
    padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
    child: Column(
      children: const [
        SizedBox(height: 10),
        CircleAvatar(
          radius: 52,
          backgroundImage: AssetImage("assets/profile.jpg"),
        ),
        SizedBox(height: 12),
        Text('John Doe', style: TextStyle()),
        Text('John Doe@example.com', style: TextStyle()),
        SizedBox(height: 10),
      ],
    ),
  );

  Widget buildMenuItems(BuildContext context) => Column(
    children: [
      SizedBox(height: 8),
      ListTile(
        leading: const ImageIcon(AssetImage("assets/logo_2.png")),
        title: const Text('Translate'),
        onTap: () {
          Navigator.pushReplacementNamed(context, '/dashboard');
        },
      ),
      const Divider(),
      ListTile(
        leading: const Icon(Icons.settings),
        title: const Text('Settings'),
        onTap: () {
          Navigator.pushReplacementNamed(context, '/settings');
        },
      ),
    ],
  );
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _textController = TextEditingController();
  String _translatedText = '';
  bool _isTranslating = false;
  String _fromLanguage = 'Bisaya';
  String _toLanguage = 'Tagalog';

  void _translateText() {
    if (_textController.text.isEmpty) return;

    setState(() {
      _isTranslating = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _translatedText =
            "This is a simulated translation of: ${_textController.text}";
        _isTranslating = false;
      });
    });
  }

  void _swapLanguages() {
    setState(() {
      final temp = _fromLanguage;
      _fromLanguage = _toLanguage;
      _toLanguage = temp;
      _translatedText = '';
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('TABI Translator'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        iconTheme: Theme.of(context).appBarTheme.iconTheme,
        titleTextStyle: Theme.of(context).appBarTheme.titleTextStyle,
      ),
      drawer: const NavigationDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: screenSize.width * 0.04,
            vertical: isPortrait ? screenSize.height * 0.001 : 0,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  screenSize.height -
                  (viewInsets > 0 ? viewInsets : 0) -
                  kToolbarHeight -
                  MediaQuery.of(context).padding.top -
                  (isPortrait ? 65 : 60),
            ),
            child: Column(
              children: [
                SizedBox(height: isPortrait ? screenSize.height * 0.02 : 0),
                _buildInputCard(context, screenSize),
                if (_translatedText.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(
                      top: isPortrait ? screenSize.height * 0.03 : 10,
                    ),
                    child: _buildTranslationCard(context, screenSize),
                  ),
                SizedBox(
                  height: isPortrait
                      ? screenSize.height * 0.03
                      : screenSize.height * 0.01,
                ),
                _buildLanguageSelector(context),
                SizedBox(height: isPortrait ? screenSize.height * 0.1 : 10),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomAppBar(context, isPortrait),
      floatingActionButton: SizedBox(
        width: 80,
        height: 80,
        child: FittedBox(
          child: FloatingActionButton.large(
            backgroundColor: theme.colorScheme.primary,
            shape: const CircleBorder(),
            onPressed: () {
              Navigator.pushNamed(context, '/voice');
            },
            child: Icon(Icons.mic, color: theme.colorScheme.onPrimary),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildInputCard(BuildContext context, Size screenSize) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(screenSize.width * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenSize.height * 0.001),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Type or paste text here',
                      hintStyle: TextStyle(color: theme.hintColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: screenSize.width * 0.05,
                        vertical: screenSize.height * 0.02,
                      ),
                    ),
                    style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                    maxLines: 3,
                    minLines: 1,
                  ),
                ),
                SizedBox(width: screenSize.width * 0.03),
                FloatingActionButton(
                  backgroundColor: theme.colorScheme.secondary,
                  onPressed: _translateText,
                  child: _isTranslating
                      ? CircularProgressIndicator(
                          color: theme.colorScheme.onSecondary,
                        )
                      : Icon(
                          Icons.arrow_forward,
                          color: theme.colorScheme.onSecondary,
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTranslationCard(BuildContext context, Size screenSize) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(screenSize.width * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Translation',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            SizedBox(height: screenSize.height * 0.02),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.width * 0.05,
                vertical: screenSize.height * 0.02,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _translatedText,
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
              ),
            ),
            SizedBox(height: screenSize.height * 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.copy, color: theme.iconTheme.color),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Copied to clipboard',
                          style: TextStyle(
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        backgroundColor: theme.colorScheme.tertiary,
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.volume_up, color: theme.iconTheme.color),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Playing translation',
                          style: TextStyle(
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        backgroundColor: theme.colorScheme.tertiary,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _LanguageButton(
                language: _fromLanguage,
                flag: _fromLanguage == 'Bisaya' ? '🇬🇧' : '🇪🇸',
                width: constraints.maxWidth * 0.35,
                onPressed: () {
                  _showLanguagePicker(true);
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.compare_arrows,
                  color: theme.textTheme.bodyLarge?.color,
                ),
                onPressed: _swapLanguages,
              ),
              _LanguageButton(
                language: _toLanguage,
                flag: _toLanguage == 'Bisaya' ? '🇬🇧' : '🇪🇸',
                width: constraints.maxWidth * 0.35,
                onPressed: () {
                  _showLanguagePicker(false);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLanguagePicker(bool isFromLanguage) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Text('🇬🇧', style: TextStyle(fontSize: 24)),
                title: Text('Bisaya', style: theme.textTheme.bodyLarge),
                onTap: () {
                  setState(() {
                    if (isFromLanguage) {
                      _fromLanguage = 'Bisaya';
                    } else {
                      _toLanguage = 'Bisaya';
                    }
                  });
                  Navigator.pop(context);
                },
              ),
              Divider(color: theme.dividerTheme.color),
              ListTile(
                leading: const Text('🇪🇸', style: TextStyle(fontSize: 24)),
                title: Text('Tagalog', style: theme.textTheme.bodyLarge),
                onTap: () {
                  setState(() {
                    if (isFromLanguage) {
                      _fromLanguage = 'Tagalog';
                    } else {
                      _toLanguage = 'Tagalog';
                    }
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // In the _buildBottomAppBar widget, replace the onPressed handlers as follows:

  Widget _buildBottomAppBar(BuildContext context, bool isPortrait) {
    final theme = Theme.of(context);
    return BottomAppBar(
      color: theme.cardColor,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: Container(
        height: isPortrait ? 70 : 60,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: isPortrait
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _BottomAction(
                    icon: Icons.history,
                    label: 'History',
                    iconColor: theme.iconTheme.color,
                    textColor: theme.textTheme.bodyLarge?.color,
                    onPressed: () {
                      Navigator.pushNamed(context, '/history');
                    },
                  ),
                  _BottomAction(
                    icon: Icons.bookmark,
                    label: 'Saved',
                    iconColor: theme.iconTheme.color,
                    textColor: theme.textTheme.bodyLarge?.color,
                    onPressed: () {
                      Navigator.pushNamed(context, '/saved');
                    },
                  ),
                  const SizedBox(width: 48),
                  _BottomAction(
                    icon: Icons.forum,
                    label: 'Dictionary',
                    iconColor: theme.iconTheme.color,
                    textColor: theme.textTheme.bodyLarge?.color,
                    onPressed: () {
                      Navigator.pushNamed(context, '/dictionary');
                    },
                  ),
                  _BottomAction(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    iconColor: theme.iconTheme.color,
                    textColor: theme.textTheme.bodyLarge?.color,
                    onPressed: () {
                      Navigator.pushNamed(context, '/camera');
                    },
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _BottomAction(
                    icon: Icons.history,
                    label: 'History',
                    iconColor: theme.iconTheme.color,
                    textColor: theme.textTheme.bodyLarge?.color,
                    onPressed: () {
                      Navigator.pushNamed(context, '/history');
                    },
                  ),
                  _BottomAction(
                    icon: Icons.bookmark,
                    label: 'Saved',
                    iconColor: theme.iconTheme.color,
                    textColor: theme.textTheme.bodyLarge?.color,
                    onPressed: () {
                      Navigator.pushNamed(context, '/saved');
                    },
                  ),
                  _BottomAction(
                    icon: Icons.forum,
                    label: 'Dictionary',
                    iconColor: theme.iconTheme.color,
                    textColor: theme.textTheme.bodyLarge?.color,
                    onPressed: () {
                      Navigator.pushNamed(context, '/dictionary');
                    },
                  ),
                  _BottomAction(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    iconColor: theme.iconTheme.color,
                    textColor: theme.textTheme.bodyLarge?.color,
                    onPressed: () {
                      Navigator.pushNamed(context, '/camera');
                    },
                  ),
                ],
              ),
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String language;
  final String flag;
  final double width;
  final VoidCallback? onPressed;

  const _LanguageButton({
    required this.language,
    required this.flag,
    required this.width,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              flag,
              style: TextStyle(
                fontSize: 24,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              language,
              style: TextStyle(
                color: theme.textTheme.bodyLarge?.color,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? iconColor;
  final Color? textColor;
  final VoidCallback? onPressed;

  const _BottomAction({
    required this.icon,
    required this.label,
    this.iconColor,
    this.textColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: textColor, fontSize: 12)),
        ],
      ),
    );
  }
}
