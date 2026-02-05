import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:penny_wise/components/backgroundBlob.dart';
import 'package:penny_wise/components/glassTextField.dart';
import 'package:penny_wise/provider/counterProv.dart';
import 'package:penny_wise/screens/home.dart';
import 'package:penny_wise/screens/registration.dart';
import 'package:penny_wise/services/auth.dart';
import 'package:penny_wise/theme.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback toggleTheme;
  const LoginPage({super.key, required this.toggleTheme});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // 2. State for Password Visibility
  bool isLoading = false;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final Color primaryColor = FinTrackTheme.primaryColor;
    final Color secondaryColor = FinTrackTheme.secondaryColor;
    final Color textColor = FinTrackTheme.getTextColor(isDarkMode);
    final Color glassColor = FinTrackTheme.getGlassColor(isDarkMode);
    final Color glassBorder = FinTrackTheme.getGlassBorder(isDarkMode);

    AuthService authService = AuthService();
    onLogin() async {
      setState(() {
        isLoading = true;
      });
      String email = emailController.text;
      String password = passwordController.text;
      try {
        await authService.login(email, password);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Login Successful!"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating, // Makes it look modern
          ),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => HomePage(toggleTheme: widget.toggleTheme),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("There's  wrong with this damn app"),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating, // Makes it look modern
            action: SnackBarAction(
              label: "Dismiss",
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // 3. Dark Mode Toggle Switch
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Icon(
                isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: isDarkMode ? Colors.amber : const Color(0xFF1A237E),
              ),
              onPressed: widget.toggleTheme,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // --- BACKGROUND BLOBS ---
          Backgroundblob(
            top: -100,
            left: -100,
            color: const Color(0xFF1A237E),
            isDarkMode: isDarkMode,
          ),
          Backgroundblob(
            bottom: -100,
            right: -100,
            color: primaryColor,
            isDarkMode: isDarkMode,
          ),

          // --- MAIN CONTENT ---
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    // --- LOGO ---
                    Hero(
                      tag: 'logo',
                      child: Container(
                        padding: const EdgeInsets.all(20),
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
                          Icons.account_balance_wallet_rounded,
                          size: 50,
                          color: primaryColor,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    // Consumer(builder: (context, ref, _) {
                    //   final count = ref.watch(counterProv);
                    //   return Column(
                    //     children: [
                    //       Text(
                    //         "Login Page Visits: ${count.toString()}",
                    //         style: TextStyle(
                    //           fontSize: 16,
                    //           color: textColor.withOpacity(0.7),
                    //         ),
                    //       ),
                    //       const SizedBox(height: 10),
                    //       ElevatedButton(
                    //         onPressed: () {
                    //           ref.read(counterProv.notifier).increment(3);
                    //         },
                    //         child: const Text("Increment Counter"),
                    //       ),
                    //     ],
                    //   );
                    // }),
                    Text(
                      "FinTrack",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        letterSpacing: 1.5,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Master your finances today",
                      style: TextStyle(
                        fontSize: 16,
                        color: textColor.withOpacity(0.6),
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // --- GLASS CARD ---
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
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Welcome Back",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Please sign in to continue",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: textColor.withOpacity(0.5),
                                ),
                              ),
                              const SizedBox(height: 32),

                              Glasstextfield(
                                icon: Icons.email_outlined,
                                hint: "Email Address",
                                isDarkMode: isDarkMode,
                                textColor: textColor,
                                controller: emailController,
                              ),

                              const SizedBox(height: 20),

                              Glasstextfield(
                                icon: Icons.lock_outline,
                                hint: "Password",
                                isPassword: true,
                                isDarkMode: isDarkMode,
                                textColor: textColor,
                                controller: passwordController,
                              ),

                              const SizedBox(height: 12),

                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {},
                                  child: Text(
                                    "Forgot Password?",
                                    style: TextStyle(
                                      color: isDarkMode
                                          ? secondaryColor
                                          : primaryColor,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Login Button
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: LinearGradient(
                                    colors: [
                                      primaryColor,
                                      const Color(0xFF00897B),
                                    ],
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
                                  onPressed: isLoading ? null : onLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    minimumSize: const Size(
                                      double.infinity,
                                      55,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: isLoading
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : const Text(
                                          "LOGIN",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                            fontSize: 15,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => RegistrationPage(
                                  toggleTheme: widget.toggleTheme,
                                ),
                              ),
                            );
                            print("Navigate to Register");
                          },
                          child: Text(
                            "Register",
                            style: TextStyle(
                              color:
                                  primaryColor, // Using the Teal/Emerald color
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              decoration: TextDecoration
                                  .underline, // Subtle hint it's clickable
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20), // Bottom padding for scroll
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET BUILDERS ---
}
