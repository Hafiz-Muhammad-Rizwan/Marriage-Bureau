import 'package:flutter/material.dart';
import 'package:marriage_bereau_app/Essentials/colors.dart';
import 'package:marriage_bereau_app/RegistrationScreen/name_ageScreen.dart';
import '../Essentials/fontSizes.dart';

class GenderScreen extends StatefulWidget {
  const GenderScreen({super.key});

  @override
  State<GenderScreen> createState() => _GenderScreenState();
}

class _GenderScreenState extends State<GenderScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedGender;

  void _submitForm() {
    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your gender to proceed!', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    print("Selected Gender: $_selectedGender");
    Navigator.push(context, MaterialPageRoute(builder: (context)=>NameAgeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Select Your Gender",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
        backgroundColor: pinkColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.grey[100]!],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Tell us about yourself...",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: headingSize * 1.1,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Are you a man or a woman?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: subHeadingSize,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildGenderSelection(),
                  const SizedBox(height: 50),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: pinkColor,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 8,
                      shadowColor: pinkColor.withOpacity(0.5),
                    ),
                    child: const Text(
                      "Continue",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderSelection() {
    return Column(
      children: [
        _buildGenderOption(
          gender: "Man",
          icon: Icons.male, // Or '👨'
          label: "I am a Man",
        ),
        const SizedBox(height: 20),
        _buildGenderOption(
          gender: "Woman",
          icon: Icons.female,
          label: "I am a Woman",
        ),
      ],
    );
  }

  Widget _buildGenderOption({
    required String gender,
    required IconData icon,
    required String label,
  }) {
    bool isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = gender;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        decoration: BoxDecoration(
          color: isSelected ? pinkColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? pinkColor : Colors.grey.shade300,
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? pinkColor.withOpacity(0.3) : Colors.black12,
              blurRadius: isSelected ? 10 : 5,
              offset: Offset(0, isSelected ? 5 : 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 35,
                  color: isSelected ? pinkColor : Colors.grey[600],
                ),
                const SizedBox(width: 15),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? pinkColor : Colors.black87,
                  ),
                ),
              ],
            ),
            AnimatedOpacity(
              opacity: isSelected ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.check_circle,
                color: pinkColor,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }
}