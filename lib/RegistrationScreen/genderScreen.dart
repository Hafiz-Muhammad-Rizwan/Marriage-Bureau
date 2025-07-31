import 'package:flutter/material.dart';
import 'package:marriage_bereau_app/Backend%20Logic/Sign%20Up%20Logic.dart';
import 'package:marriage_bereau_app/Essentials/colors.dart';
import 'package:marriage_bereau_app/RegistrationScreen/name_ageScreen.dart';
import 'package:provider/provider.dart';
import '../Essentials/fontSizes.dart';

class GenderScreen extends StatefulWidget {
  const GenderScreen({super.key});

  @override
  State<GenderScreen> createState() => _GenderScreenState();
}

class _GenderScreenState extends State<GenderScreen> {
  final _formKey = GlobalKey<FormState>();

  void _submitForm() {
    final genderProvider = Provider.of<GenderProvider>(context, listen: false);

    if (genderProvider.selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your gender to proceed!', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    print("Selected Gender: ${genderProvider.selectedGender?.type}");
    Navigator.push(context, MaterialPageRoute(builder: (context)=>NameAgeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GenderProvider>(
      builder: (context, genderProvider, _) {
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
          bottomNavigationBar: Padding(padding: EdgeInsets.all(10),
          child: ElevatedButton(
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
                      _buildGenderSelection(genderProvider),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildGenderSelection(GenderProvider genderProvider) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              genderProvider.selectGender(Gender('Male'));
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: genderProvider.selectedGender?.type == 'Male'
                    ? pinkColor.withOpacity(0.1)
                    : Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: genderProvider.selectedGender?.type == 'Male'
                      ? pinkColor
                      : Colors.grey.shade300,
                  width: genderProvider.selectedGender?.type == 'Male' ? 2.5 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: genderProvider.selectedGender?.type == 'Male'
                        ? pinkColor.withOpacity(0.3)
                        : Colors.black12,
                    blurRadius: genderProvider.selectedGender?.type == 'Male' ? 10 : 5,
                    offset: Offset(0, genderProvider.selectedGender?.type == 'Male' ? 5 : 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.male,
                    size: 60,
                    color: genderProvider.selectedGender?.type == 'Male'
                        ? pinkColor
                        : Colors.grey[600],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Male",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: genderProvider.selectedGender?.type == 'Male'
                          ? pinkColor
                          : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: GestureDetector(
            onTap: () {
              genderProvider.selectGender(Gender('Female'));
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: genderProvider.selectedGender?.type == 'Female'
                    ? pinkColor.withOpacity(0.1)
                    : Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: genderProvider.selectedGender?.type == 'Female'
                      ? pinkColor
                      : Colors.grey.shade300,
                  width: genderProvider.selectedGender?.type == 'Female' ? 2.5 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: genderProvider.selectedGender?.type == 'Female'
                        ? pinkColor.withOpacity(0.3)
                        : Colors.black12,
                    blurRadius: genderProvider.selectedGender?.type == 'Female' ? 10 : 5,
                    offset: Offset(0, genderProvider.selectedGender?.type == 'Female' ? 5 : 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.female,
                    size: 60,
                    color: genderProvider.selectedGender?.type == 'Female'
                        ? pinkColor
                        : Colors.grey[600],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Female",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: genderProvider.selectedGender?.type == 'Female'
                          ? pinkColor
                          : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}