// import 'dart:ui_web';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hellohackers_flutter/core/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class UserSignupPage extends StatefulWidget {
  const UserSignupPage({super.key});

  @override
  State<UserSignupPage> createState() => _UserSignupPageState();
}

class _UserSignupPageState extends State<UserSignupPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final dobController = TextEditingController();
  final nameController = TextEditingController();
  final icController = TextEditingController();

  bool _obscurePassword = true;

  int? _age;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;


  //clean up (when change pg)
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    dobController.dispose();
    nameController.dispose();
    icController.dispose();
    super.dispose();
  }


  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1920),
      lastDate: DateTime(2014),
    );
    if (picked != null) {
      setState(() {
        dobController.text = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';

        // calculate age
        final now = DateTime.now();
        int years = now.year - picked.year;
        _age = years;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/login_background.png'),
            fit: BoxFit.cover,
          ),
        ),


        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // Logo
                Image.asset(
                  'assets/images/mediai_logo_noname.png',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),

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

                const SizedBox(height: 30),

                // Email label + input
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 85,
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
                    width: 85,
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

            const SizedBox(height: 20),

            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 85,
                    height: 40,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'Name:',
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
                        controller: nameController,
                        keyboardType: TextInputType.text,
                        style: const TextStyle(fontSize: 18),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter your name',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // IC
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 85,
                    height: 40,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'IC:',
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
                        controller: icController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 18),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter your IC number',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 5),

            Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 85,
                          height: 60,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: const Text(
                              'Date of Birth:',
                              style: TextStyle(fontSize: 18, fontFamily: 'winterdraw', color: AppColors.black),
                            ),
                          ),
                        ),


                        const SizedBox(width: 16),
                        SizedBox(
                          //tried 220 but it overflowed, so stick with 210
                          width: 210,
                          child: GestureDetector(
                            onTap: () => _selectDate(context),
                            child: Container(
                              height: 40,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              color: AppColors.white,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: dobController,
                                      style: const TextStyle(fontSize: 18),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Select date',
                                      ),
                                      focusNode: AlwaysDisabledFocusNode(),
                                    ),
                                  ),
                                  const Icon(Icons.calendar_today),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                // Sign Up Button
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
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Back Button
                SizedBox(
                  width: 120,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.teal700,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    ),
                    child: const Text(
                      'Back',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSignup() async {
    final userEmail = emailController.text.trim();
    final userPassword = passwordController.text.trim();
    final userDob = dobController.text.trim();
    final userName = nameController.text.trim();
    final userIC = icController.text.trim();

    if (userEmail.isEmpty || userPassword.isEmpty || userDob.isEmpty || userName.isEmpty || userIC.isEmpty) {
      _showErrorDialog('Error', 'Please fill in all the fields.');
      return;
    }
    //no need isloading as just pop the dialog

    try {
      // await FirebaseAuth.instance.createUserWithEmailAndPassword(email: userEmail, password: userPassword);
      UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: userEmail,
          password: userPassword,
        );

      String uid = userCredential.user!.uid;

      //create the user in database
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': nameController.text.trim(),
        'age': _age,
        'dob': dobController.text,
        'address': "",
        'email': userEmail,
        "ic": icController.text.trim(),
      });

      if (!context.mounted) return;

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Account Created"),
          content: const Text(
            "Your account has been successfully created. You can now log in.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );

    } on FirebaseAuthException catch (e) {
      print("Firebase error: ${e.code}");
      String errorMessage = 'An error occurred. Please try again.';
      if (e.code == 'email-already-in-use') {
        errorMessage = 'This email is already in use. Please use a different email.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is not valid. Please enter a valid email.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'The password is too weak. Please enter a stronger password.';
      }
      _showErrorDialog('Signup Failed', errorMessage);
    } on PlatformException catch (e) {
      print("PlatformException: ${e.code}");
      _showErrorDialog("Signup Failed", e.message ?? "Platform Error");

    }
    catch (e) {
      _showErrorDialog('Signup Failed', 'An unexpected error occurred. Please try again.');
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
    _showNotice();
    });
  }

  void _showNotice() {
    showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Notice"),
      content: const Text(
        "1. Please ensure your crendentials are correct.\n"
        "2. Please enter a valid email address.\n"
        "3. Password must be at least 6 characters.\n"
        ,
      ),
      actions: [

        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("OK", style: TextStyle(fontSize: 20),
        ),
        ),
      ],
    ),
  );
  }


  void _showErrorDialog(String title, String message) {

    if (!mounted) return;
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
// Custom FocusNode that's always disabled for non-editable TextField
class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}