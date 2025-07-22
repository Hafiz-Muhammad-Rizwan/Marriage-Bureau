import 'package:flutter/material.dart';
import 'package:marriage_bereau_app/Backend%20Logic/Sign%20Up%20Logic.dart';
import 'package:marriage_bereau_app/RegistrationScreen/genderScreen.dart';
import 'package:marriage_bereau_app/Screens/signInScreen.dart';
import 'package:marriage_bereau_app/Services/email_service.dart';
import 'package:provider/provider.dart';
import '../Essentials/colors.dart';
import '../Essentials/fontSizes.dart';
import '../Essentials/customTextField.dart';
import 'dart:math';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _emailOtpController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _termsAccepted = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _isEmailVerified = false;
  bool _showEmailOtpField = false;
  String? _emailVerificationCode;

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _emailOtpController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
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
              "By signing up, you agree to our privacy policy and terms of service. This includes data usage for personalized content, communication via email/SMS, and adherence to community guidelines. Please read full terms on our website.",
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

  void _showEmailVerificationInfo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Email Verification", style: TextStyle(color: pinkColor)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.mark_email_read, size: 70, color: Colors.green),
              SizedBox(height: 16),
              Text(
                "A verification email has been sent to your email address. Please check your inbox and click the verification link to activate your account.",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: <Widget>[
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

  // Generate OTP for email verification
  String _generateEmailOTP() {
    final int min = 100000; // Minimum 6-digit number
    final int max = 999999; // Maximum 6-digit number
    final random = new Random();
    final int code = min + random.nextInt(max - min);
    return code.toString();
  }

  // Send OTP for email verification
  Future<void> _sendEmailOtp() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please enter your email address",
              style: TextStyle(color: whiteColor)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Validate email format
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(_emailController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please enter a valid email address",
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
      // Generate OTP
      _emailVerificationCode = _generateEmailOTP();

      // Get name for email (if available)
      String name = "User"; // Default name if none provided

      // Send OTP email using EmailService
      bool emailSent = await EmailService.sendOtpEmail(
        email: _emailController.text.trim(),
        otp: _emailVerificationCode!,
        name: name,
      );

      if (emailSent) {
        setState(() {
          _showEmailOtpField = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("OTP sent to your email. Please check your inbox.",
                style: TextStyle(color: whiteColor)),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 5),
          ),
        );
      } else {
        // Fallback to mock or show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to send email OTP. For testing, the OTP is: $_emailVerificationCode",
                style: TextStyle(color: whiteColor)),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 10),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error sending email OTP: ${e.toString()}",
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

  // Verify the entered email OTP
  void _verifyEmailOtp() {
    if (_emailOtpController.text.isEmpty || _emailVerificationCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please enter the OTP sent to your email",
              style: TextStyle(color: whiteColor)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_emailOtpController.text.trim() == _emailVerificationCode) {
      setState(() {
        _isEmailVerified = true;
        _showEmailOtpField = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Email verified successfully!",
              style: TextStyle(color: whiteColor)),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Invalid OTP. Please try again.",
              style: TextStyle(color: whiteColor)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _signUp() async {
    if (!_isEmailVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please verify your email address first.",
              style: TextStyle(color: whiteColor)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

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

      if (_passController.text != _confirmPassController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Passwords don't match.",
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

        // Register the user with email, password and verified phone number
        final errorMessage = await signUp.signUpWithEmailAndPassword(
          _emailController.text.trim(),
          _passController.text,
          _phoneController.text.trim(),
        );

        if (errorMessage != null) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage, style: TextStyle(color: whiteColor)),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          // Show email verification info dialog
          _showEmailVerificationInfo();

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Registration successful! Please check your email for verification.",
                  style: TextStyle(color: whiteColor)),
              backgroundColor: pinkColor,
              behavior: SnackBarBehavior.floating,
            ),
          );

          // Navigate to gender screen to start profile completion
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
                return SlideTransition(
                  position: offsetAnimation,
                  child: child,
                );
              },
              transitionDuration: Duration(milliseconds: 500),
            ),
          );
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
                height: height * (height > 700 ? 0.75 : 0.85),
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
                        "Create Account",
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
                        "Sign up to get started",
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
                            // Email Field with Verification
                            Row(
                              children: [
                                Expanded(
                                  child: CustomTextField(
                                    controller: _emailController,
                                    hint: "Enter your email",
                                    label: "Email Address",
                                    prefixIcon: Icons.email_outlined,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    focusedBorderColor: pinkColor,
                                    fillColor: Colors.grey[100]!,
                                    borderRadius: 12,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your email';
                                      }
                                      // Custom email validation
                                      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                                      if (!emailRegex.hasMatch(value.trim())) {
                                        return 'Please enter a valid email';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: _isLoading || _isEmailVerified ? null : _sendEmailOtp,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _isEmailVerified ? Colors.green : pinkColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                  ),
                                  child: _isEmailVerified
                                      ? Icon(Icons.check, color: whiteColor)
                                      : Text(
                                          "Verify",
                                          style: TextStyle(color: whiteColor),
                                        ),
                                ),
                              ],
                            ),

                            // Email OTP field
                            if (_showEmailOtpField) ...[
                              SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: CustomTextField(
                                      controller: _emailOtpController,
                                      hint: "Enter OTP sent to your email",
                                      label: "Email OTP",
                                      prefixIcon: Icons.mail_lock_outlined,
                                      keyboardType: TextInputType.number,
                                      textInputAction: TextInputAction.next,
                                      focusedBorderColor: pinkColor,
                                      fillColor: Colors.grey[100]!,
                                      borderRadius: 12,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter OTP';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: _isLoading ? null : _verifyEmailOtp,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: pinkColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                    ),
                                    child: Text(
                                      "Confirm",
                                      style: TextStyle(color: whiteColor),
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            // Email verification status
                            if (_isEmailVerified) ...[
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                                  SizedBox(width: 8),
                                  Text(
                                    "Email verified",
                                    style: TextStyle(color: Colors.green, fontSize: 12),
                                  ),
                                ],
                              ),
                            ],

                            SizedBox(height: 16),

                            // Phone Number Field
                            Row(
                              children: [
                                Expanded(
                                  child: CustomTextField(
                                    controller: _phoneController,
                                    hint: "Enter your phone number",
                                    label: "Phone Number",
                                    prefixIcon: Icons.phone_outlined,
                                    keyboardType: TextInputType.phone,
                                    textInputAction: TextInputAction.next,
                                    focusedBorderColor: pinkColor,
                                    fillColor: Colors.grey[100]!,
                                    borderRadius: 12,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your phone number';
                                      }
                                      if (value.length < 10) {
                                        return 'Please enter a valid phone number';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 16),

                            // Password Field
                            CustomTextField(
                              controller: _passController,
                              hint: "Enter your password",
                              label: "Password",
                              prefixIcon: Icons.lock_outline,
                              obscureText: !_isPasswordVisible,
                              keyboardType: TextInputType.visiblePassword,
                              textInputAction: TextInputAction.next,
                              focusedBorderColor: pinkColor,
                              fillColor: Colors.grey[100]!,
                              borderRadius: 12,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
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
                            ),
                            SizedBox(height: 16),

                            // Confirm Password Field
                            CustomTextField(
                              controller: _confirmPassController,
                              hint: "Confirm your password",
                              label: "Confirm Password",
                              prefixIcon: Icons.lock_outline,
                              obscureText: !_isConfirmPasswordVisible,
                              keyboardType: TextInputType.visiblePassword,
                              textInputAction: TextInputAction.done,
                              focusedBorderColor: pinkColor,
                              fillColor: Colors.grey[100]!,
                              borderRadius: 12,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm your password';
                                }
                                if (value != _passController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                  });
                                },
                              ),
                            ),
                            SizedBox(height: 20),

                            // Terms and Conditions
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

                            // Sign Up Button
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
                                onPressed: _isLoading ? null : _signUp,
                                child: _isLoading
                                    ? CircularProgressIndicator(color: whiteColor)
                                    : Text(
                                        "Sign Up",
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
                          Text("Already have an account?",
                              style: TextStyle(color: blackColor)),
                          const SizedBox(width: 5),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) => Loginscreen(),
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                    const begin = Offset(-1.0, 0.0); // Start from the left
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
                              "Sign In",
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

