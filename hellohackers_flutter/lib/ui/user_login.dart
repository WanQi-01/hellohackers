
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hellohackers_flutter/core/colors.dart';
// import 'user_signup.dart';
// import 'pharmacist_login.dart';
// import 'forgot_password.dart';
import 'user_dashboard.dart';

class UserLoginPage extends StatefulWidget {
  const UserLoginPage({super.key});

  @override
  State<UserLoginPage> createState() => _UserLoginPageState();
}

class _UserLoginPageState extends State<UserLoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  //hide the password by default
  bool _obscurePassword = true;
  bool _isLoading = false;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        ///bg
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/login_background.png'),
            fit: BoxFit.cover,
          ),
        ),


        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Logo
              Image.asset(
                'assets/images/mediai_logo_noname.png',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 10),

              // App name
              const Text(
                'MediAI',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 45,
                  fontFamily: 'nextsunday',
                  color: AppColors.white,
                  shadows: [
                    Shadow(
                      color: AppColors.darkTeal,
                      blurRadius: 20,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              /// Email
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    height: 40,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'Email:',
                        style: TextStyle(fontSize: 20, fontFamily: 'winterdraw'),

                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  //Email input
                  Expanded(
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      color: AppColors.white,
                      child: TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(fontSize: 18),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter email',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Password label + input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                  SizedBox(
                  width: 80,
                  height: 40,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'Password:',
                      style: TextStyle(fontSize: 20, fontFamily: 'winterdraw'),
                    ),
                  ),
                ),

            const SizedBox(width: 16),

            Expanded(
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                color: AppColors.white,
                child: TextField(
                  controller: passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      const SizedBox(height: 30),

      // Buttons: Login and Signup
      SizedBox(
        width: 120,
        height: 40,
        child: ElevatedButton(

          //not loading
          onPressed: _isLoading ? null : _handleLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.teal700,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          ),
          child: _isLoading ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
             strokeWidth: 2,
             valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
            ),
          )
          : const Text(
            'Login',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
        ),
      ),

      const SizedBox(height: 12),

      SizedBox(
        width: 120,
        height: 40,
        child: ElevatedButton(
        onPressed: _handleSignup,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.teal700,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        child: const Text(
          'Sign Up',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
      ),
    ),

    const Spacer(flex: 3),

    // Bottom links: left and right
    Padding(
      padding: EdgeInsets.symmetric(horizontal: (screenWidth - 320) / 2 < 0 ? 20 : (screenWidth - 320) / 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
        TextButton(
          onPressed: () => Navigator.pushNamed(
            context,
            '/forgotPassword',
          ),
          child: const Text(
            'Forgot Password',
            style: TextStyle(color: AppColors.loginBlue, fontSize: 15), // login_blue-ish
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pushNamed(
            context,
            '/pharmacistLogin',
          ),
          child: const Text(
            'Login as Pharmacist',
            style: TextStyle(color: AppColors.loginBlue, fontSize: 15),
          ),
        ),
      ],
    ),
  ),

  const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }


  Future<void> _handleLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showErrorDialog('Error', 'Please enter email and password');
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (mounted) {
        // Navigator.pushNamed(context, '/userDashboard');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => UserDashboardPage(
              userEmail: email,
            ),
          ),
);
      }

    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Login failed';
      if (e.code == 'user-not-found') {
        errorMessage = 'Email not found. Please sign up.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password. Try again.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Invalid email address.';
      }
      if (mounted) {
        _showErrorDialog('Login Error', errorMessage);
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Error', 'An error occurred: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleSignup() {
    Navigator.pushNamed(context, '/signUp');
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}