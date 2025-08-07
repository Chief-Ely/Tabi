import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:a_project/core/dialogs.dart';
import 'package:a_project/services/auth_service.dart';

const Map<String, String> authExceptionMapper = {
  'email-already-in-use':
      'This email is already taken. Try with a new email or sign in with the provided email!',
  'invalid-email': 'The provided email address is not valid!',
  'weak-password': 'Your password is too weak. Try with a strong password!',
  'user-disabled': 'Account with this email address is disabled!',
  'user-not-found': 'No account with this email address!',
  'wrong-password': 'The provided password is not correct!',
  'INVALID_LOGIN_CREDENTIALS': 'The provided email or password is not correct!',
  'too-many-requests': 'Too many requests. Try again later!',
  'network-request-failed':
      'Couldn\'t move forward. Check your internet connection!',
  'user-mismatch': 'Prvided credentials do not match!',
  'invalid-credential': 'Your provider\'s credentials are not valid!',
};

class RegistrationController extends ChangeNotifier {
  bool _isRegisterMode = true;
  bool _isPasswordHidden = true;

  bool _isLoading = false;

  String _userName = '';
  String _email = '';
  String _password = '';

  bool get isRegisterMode => _isRegisterMode;
  bool get isPasswordHidden => _isPasswordHidden;

  bool get isLoading => _isLoading;

  String get userName => _userName.trim();
  String get email => _email.trim();
  String get password => _password;

  set isRegisterMode(bool value) {
    if (_isRegisterMode != value) {
      _isRegisterMode = value;
      notifyListeners();
    }
  }

  set isPasswordHidden(bool value) {
    if (_isPasswordHidden != value) {
      _isPasswordHidden = value;
      notifyListeners();
    }
  }

  set isLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  set userName(String value) {
    _userName = value;
    notifyListeners();
  }

  set email(String value) {
    _email = value;
    notifyListeners();
  }

  set password(String value) {
    _password = value;
    notifyListeners();
  }

  Future<void> authenticateWithEmailAndPassword({
    required BuildContext context,
  }) async {
    isLoading = true;
    try {
      if (isRegisterMode) {
        await AuthService.register(
          userName: userName,
          email: email,
          password: password,
        );
      } else {}
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      showMessageDialog(
        context: context,
        message: authExceptionMapper[e.code] ?? 'An unknown error occured!',
      );
    } catch (e) {
      showMessageDialog(context: context, message: 'An unknown error occured!');
    } finally {
      isLoading = false;
    }
  }
}
