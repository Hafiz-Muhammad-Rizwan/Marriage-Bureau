import 'package:flutter/material.dart';
import 'package:marriage_bereau_app/RegistrationScreen/genderScreen.dart';
import 'package:marriage_bereau_app/Screens/signUpScreen.dart';
import 'package:marriage_bereau_app/Screens/homeScreen.dart';
import 'package:provider/provider.dart';
import '../Essentials/colors.dart';
import '../Essentials/fontSizes.dart';
import '../Essentials/customTextField.dart';
import '../Backend Logic/Sign Up Logic.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _termsAccepted = false;
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  void _showTermsAndConditions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Terms & Conditions", style: TextStyle(color: pinkColor)),
          content: SingleChildScrollView(
            child: Text(
              "By logging in, you agree to our privacy policy and terms of service. This includes data usage for personalized content, communication via email/SMS, and adherence to community guidelines. Please read full terms on our website.",
              style: TextStyle(fontSize: subHeadingSize),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Close", style: TextStyle(color: pinkColor)),
            ),
          ],
        );
      },
    );
  }

  void _showEmailVerificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Email Verification Required", style: TextStyle(color: pinkColor)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.mark_email_unread, size: 70, color: pinkColor),
              SizedBox(height: 16),
              Text(
                "Your email is not verified yet. Please check your inbox and click the verification link.",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              Text(
                "Didn't receive an email?",
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                final signUp = Provider.of<SignUp>(context, listen: false);
                await signUp.sendEmailVerification();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Verification email sent!", style: TextStyle(color: whiteColor)),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Text("Resend Email", style: TextStyle(color: Colors.blue)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: pinkColor,
                foregroundColor: Colors.white,
              ),
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      if (!_termsAccepted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Please accept the terms & conditions.",
                style: TextStyle(color: whiteColor)),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final signUp = Provider.of<SignUp>(context, listen: false);

        // Regular user login with email and password
        final result = await signUp.signInWithEmailAndPassword(
          _emailController.text.trim(),
          _passController.text,
        );

        if (result.errorMessage != null) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.errorMessage!, style: TextStyle(color: whiteColor)),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          // Check if email is verified
          bool isEmailVerified = await signUp.isEmailVerified();

          if (!isEmailVerified) {
            setState(() {
              _isLoading = false;
            });
            _showEmailVerificationDialog();
            return;
          }

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Login successful!", style: TextStyle(color: whiteColor)),
              backgroundColor: pinkColor,
              behavior: SnackBarBehavior.floating,
            ),
          );

          // Navigate based on profile completion status
          if (result.isProfileComplete) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;
                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);
                  return SlideTransition(position: offsetAnimation, child: child);
                },
                transitionDuration: Duration(milliseconds: 500),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => GenderScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;
                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);
                  return SlideTransition(position: offsetAnimation, child: child);
                },
                transitionDuration: Duration(milliseconds: 500),
              ),
            );
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("An error occurred: ${e.toString()}",
                style: TextStyle(color: whiteColor)),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: width,
          height: height,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/Images/coupleImage.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: width,
                height: height * (height > 700 ? 0.65 : 0.75),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 15,
                      spreadRadius: 5,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Welcome Back",
                        style: TextStyle(
                          color: blackColor,
                          fontSize: headingSize * 1.2,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Login to your account to continue",
                        style: TextStyle(
                          color: blackColor.withOpacity(0.6),
                          fontSize: subHeadingSize,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 35),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            CustomTextField(
                              label: "Email address",
                              hint: "example@email.com",
                              controller: _emailController,
                              prefixIcon: Icons.email,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              focusedBorderColor: pinkColor,
                              fillColor: Colors.grey[100]!,
                              borderRadius: 12,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                  return 'Please enter a valid email address';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20),
                            CustomTextField(
                              label: "Password",
                              hint: "Enter your password",
                              controller: _passController,
                              prefixIcon: Icons.lock,
                              obscureText: !_isPasswordVisible,
                              keyboardType: TextInputType.visiblePassword,
                              textInputAction: TextInputAction.done,
                              focusedBorderColor: pinkColor,
                              fillColor: Colors.grey[100]!,
                              borderRadius: 12,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters long';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20),
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Forgot Password tapped!", style: TextStyle(color: whiteColor)),
                                      backgroundColor: pinkColor,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                child: Text(
                                  "Forgot Password?",
                                  style: TextStyle(
                                    color: pinkColor,
                                    fontSize: subHeadingSize * 0.9,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Checkbox(
                                  value: _termsAccepted,
                                  checkColor: whiteColor,
                                  activeColor: pinkColor,
                                  onChanged: (value) {
                                    setState(() {
                                      _termsAccepted = value!;
                                    });
                                  },
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  side: BorderSide(color: Colors.grey.shade400, width: 1.5),
                                ),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                          text: "I agree with the ",
                                          style: TextStyle(
                                              color: blackColor,
                                              fontSize: subHeadingSize * 0.95)),
                                      WidgetSpan(
                                        child: GestureDetector(
                                          onTap: _showTermsAndConditions,
                                          child: Text(
                                            "terms",
                                            style: TextStyle(
                                              color: pinkColor,
                                              fontSize: subHeadingSize * 0.95,
                                              fontWeight: FontWeight.bold,
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                      ),
                                      TextSpan(
                                          text: " & ",
                                          style: TextStyle(
                                              color: blackColor,
                                              fontSize: subHeadingSize * 0.95)),
                                      WidgetSpan(
                                        child: GestureDetector(
                                          onTap: _showTermsAndConditions,
                                          child: Text(
                                            "conditions",
                                            style: TextStyle(
                                              color: pinkColor,
                                              fontSize: subHeadingSize * 0.95,
                                              fontWeight: FontWeight.bold,
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 25),
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: pinkColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 8,
                                  shadowColor: pinkColor.withOpacity(0.5),
                                ),
                                onPressed: _isLoading ? null : _signIn,
                                child: _isLoading
                                    ? CircularProgressIndicator(color: whiteColor)
                                    : Text(
                                        "Login",
                                        style: TextStyle(
                                          color: whiteColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: headingSize * 0.9,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don't have an account?",
                              style: TextStyle(color: blackColor)),
                          const SizedBox(width: 5),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) => SignUpScreen(),
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                    const begin = Offset(1.0, 0.0); // Start from the right
                                    const end = Offset.zero; // End at the center
                                    const curve = Curves.easeInOut;
                                    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                    var offsetAnimation = animation.drive(tween);
                                    return SlideTransition(
                                      position: offsetAnimation,
                                      child: child,
                                    );
                                  },
                                  transitionDuration: Duration(milliseconds: 500), // 0.5 seconds
                                ),
                              );
                            },
                            child: Text(
                              "Register Now",
                              style: TextStyle(
                                color: pinkColor,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                fontSize: subHeadingSize,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
