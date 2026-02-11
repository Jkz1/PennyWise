import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:penny_wise/components/backgroundBlob.dart';
import 'package:penny_wise/components/glassTextField.dart';
import 'package:penny_wise/provider/darkModeProv.dart';
import 'package:penny_wise/theme.dart';
import 'package:penny_wise/services/auth.dart';

class RegistrationPage extends ConsumerStatefulWidget {
  const RegistrationPage({super.key});

  @override
  ConsumerState<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends ConsumerState<RegistrationPage> {
  bool _isLoading = false;
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(darkmode);

    void toggleTheme() {
      ref.read(darkmode.notifier).toggle();
    }

    final Color primaryColor = FinTrackTheme.primaryColor;
    final Color textColor = FinTrackTheme.getTextColor(isDarkMode);
    final Color glassColor = FinTrackTheme.getGlassColor(isDarkMode);
    final Color glassBorder = FinTrackTheme.getGlassBorder(isDarkMode);

    AuthService authService = AuthService();

    onRegistration() async {
      String username = usernameController.text;
      String email = emailController.text;
      String password = passwordController.text;
      String confirmPassword = confirmPasswordController.text;
      if (password != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Passwords do not match"),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating, // Makes it look modern
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
        return;
      }
      setState(() {
        _isLoading = true;
      });
      try {
        await authService.register(email, password, username);
        if (mounted) {
          Navigator.of(context).pop("success");
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating, // Makes it look modern
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Icon(
                isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: isDarkMode ? Colors.amber : FinTrackTheme.deepIndigo,
              ),
              onPressed: toggleTheme,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          Backgroundblob(
            top: MediaQuery.of(context).size.height * 0.2,
            left: -150,
            color: primaryColor,
            isDarkMode: isDarkMode,
          ),
          Backgroundblob(
            top: -50,
            right: -80,
            color: FinTrackTheme.deepIndigo,
            isDarkMode: isDarkMode,
          ),
          Backgroundblob(
            bottom: -120,
            right: 50,
            color: primaryColor.withOpacity(0.5),
            isDarkMode: isDarkMode,
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Hero(
                      tag: 'logo',
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDarkMode
                              ? Colors.white.withOpacity(0.05)
                              : Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.person_add_rounded,
                          size: 40,
                          color: primaryColor,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      "Create Account",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        letterSpacing: 1.2,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Join FinTrack and start your journey\ntowards financial freedom.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: textColor.withOpacity(0.6),
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 30),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: glassColor,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: glassBorder),
                          ),
                          child: // ... inside the Glass Card Container ...
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1. Contextual Header inside the card
                              Text(
                                "ACCOUNT DETAILS",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: primaryColor.withOpacity(0.8),
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // 2. Group 1: Identity
                              Glasstextfield(
                                icon: Icons.person_outline_rounded,
                                hint:
                                    "Create a unique username", // More descriptive hint
                                isDarkMode: isDarkMode,
                                textColor: textColor,
                                controller: usernameController,
                              ),
                              const SizedBox(height: 16),
                              Glasstextfield(
                                icon: Icons.email_outlined,
                                hint: "Email Address",
                                isDarkMode: isDarkMode,
                                textColor: textColor,
                                controller: emailController,
                              ),

                              const SizedBox(height: 24),

                              // 3. Subtle Divider/Label for Security
                              Text(
                                "SECURITY",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: primaryColor.withOpacity(0.8),
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // 4. Group 2: Security
                              Glasstextfield(
                                icon: Icons.lock_outline,
                                hint: "Password",
                                isPassword: true,
                                isDarkMode: isDarkMode,
                                textColor: textColor,
                                controller: passwordController,
                              ),
                              const SizedBox(height: 16),
                              Glasstextfield(
                                icon: Icons
                                    .lock_reset_rounded, // Specific icon for confirmation
                                hint: "Confirm Password",
                                isPassword: true,
                                isDarkMode: isDarkMode,
                                textColor: textColor,
                                controller: confirmPasswordController,
                              ),

                              const SizedBox(height: 32),

                              // Register Button
                              _buildRegisterButton(
                                primaryColor,
                                onRegistration,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40), // Extra space for scroll
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterButton(Color primaryColor, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [FinTrackTheme.primaryColor, Color(0xFF00897B)],
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                "CREATE ACCOUNT",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
      ),
    );
  }
}
