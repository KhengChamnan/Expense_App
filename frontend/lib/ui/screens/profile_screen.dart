import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    _refreshUserProfile();
  }

  void _refreshUserProfile() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      // Only refresh the profile silently without showing loading state
      authProvider.refreshUserProfileSilently();
      _isFirstLoad = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (authProvider.error != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(authProvider.error!),
                  backgroundColor: Colors.red,
                ),
              );
              authProvider.clearError();
            });
          }

          final user = authProvider.user;

          // Return empty container while loading instead of showing spinner
          if (user == null) {
            return const SizedBox.shrink();
          }

          return CustomScrollView(
            slivers: [
              // App Bar with profile header - without back and notification icons
              SliverAppBar(
                expandedHeight: 250,
                backgroundColor: Colors.deepOrange.shade300,
                automaticallyImplyLeading: false, // Remove back button
                title: const Text('Profile'),
                centerTitle: true,
                titleSpacing: 0,
                collapsedHeight: 60,
                pinned: true,
                flexibleSpace: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    // Calculate top padding based on constraints
                    double topPadding = constraints.maxHeight > 150 ? 85 : 0;
                    
                    return FlexibleSpaceBar(
                      background: Container(
                        color: Colors.deepOrange.shade300,
                        padding: EdgeInsets.only(top: topPadding),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Profile picture
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey.shade200,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  user.username.isNotEmpty
                                      ? user.username[0].toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey.shade700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Username and email instead of Edit Profile button
                            Text(
                              user.username,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.email,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            const SizedBox(height: 15),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Content below app bar
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(height: 1),
                      
                      // Account Settings
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Text(
                          'Account Settings',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      
                      // Email setting
                      ListTile(
                        leading: Icon(
                          Icons.email_outlined,
                          color: Colors.blueGrey.shade700,
                        ),
                        title: const Text('Email'),
                        subtitle: Text(user.email),
                        onTap: () {
                          // Not implemented in this version
                        },
                      ),
                      
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      
                      // Username setting
                      ListTile(
                        leading: Icon(
                          Icons.person_outline,
                          color: Colors.blueGrey.shade700,
                        ),
                        title: const Text('Username'),
                        subtitle: Text(user.username),
                        onTap: () {
                          // Not implemented in this version
                        },
                      ),
                      
                      const Divider(height: 1),
                      
                      // Preferences section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Text(
                          'Preferences',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      
                      // Logout
                      ListTile(
                        leading: Icon(
                          Icons.logout,
                          color: Colors.red.shade700,
                        ),
                        title: const Text('Logout'),
                        onTap: () async {
                          // Navigate to login immediately to avoid any flashing
                          Navigator.of(context).pushAndRemoveUntil(
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) => const LoginScreen(),
                              transitionDuration: Duration.zero,
                              barrierDismissible: false,
                            ),
                            (route) => false,
                          );
                          
                          // Then perform logout in the background
                          await authProvider.logout();
                        },
                      ),
                      
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
} 