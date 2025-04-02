import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';

/// Widget that handles authentication state and redirects to the appropriate screen
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAuthState();
  }

  /// Initialize authentication state
  Future<void> _initializeAuthState() async {
    // Initialize auth state after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Provider.of<AuthProvider>(context, listen: false).initAuthState();
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while initializing auth state
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Based on auth state, show HomeScreen or LoginScreen
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return authProvider.isAuthenticated
            ? const HomeScreen()
            : const LoginScreen();
      },
    );
  }
} 