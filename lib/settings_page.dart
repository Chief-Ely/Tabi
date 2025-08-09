import 'package:tabi/core/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:tabi/main.dart';
import 'package:tabi/services/auth_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme(value);
              if (context.mounted) {
                Provider.of<ThemeProvider>(context, listen: false);
              }
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Sign Out'),
            leading: const Icon(Icons.logout),
            onTap: () => _showSignOutConfirmationDialog(context),
          ),
          const Divider(),
        ],
      ),
    );
  }

  Future<void> _showSignOutConfirmationDialog(BuildContext context) async {
    final shouldSignOut =
        await showConfirmationDialog(
          context: context,
          title: 'Are you sure you want to sign out?',
        ) ??
        false;

    if (shouldSignOut) {
      await _performSignOut(context);
    }
  }

  Future<void> _performSignOut(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await AuthService.logout();

      try {
        if (await GoogleSignIn().isSignedIn()) {
          await AuthService.signOutFromGoogle();
        }
      } catch (e) {
        debugPrint('Google sign-out error: $e');
      }

      if (!context.mounted) return;

      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sign out failed: ${e.toString()}'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
