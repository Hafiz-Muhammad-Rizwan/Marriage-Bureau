import 'package:flutter/material.dart';
import 'package:marriage_bereau_app/Backend%20Logic/Sign%20Up%20Logic.dart';
import 'package:marriage_bereau_app/Essentials/colors.dart';
import 'package:marriage_bereau_app/Essentials/fontSizes.dart';
import 'package:marriage_bereau_app/RegistrationScreen/photoUploadScreen.dart';
import 'package:provider/provider.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  String? _selectedEducation;

  final List<String> _educationLevels = [
    "High School",
    "Diploma",
    "Undergraduate (Bachelor's)",
    "Postgraduate (Master's)",
    "Doctorate (PhD)",
    "Vocational Training",
    "Other",
  ];

  void _submitEducationSelection() {
    if (_selectedEducation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your education level to proceed!', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    print("Selected Education: $_selectedEducation");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('You have selected: $_selectedEducation!', style: const TextStyle(color: Colors.white)),
        backgroundColor: pinkColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
    final progressProvider = Provider.of<ProgressProvider>(context, listen: false);
    progressProvider.nextScreen();
    Navigator.push(context, MaterialPageRoute(builder: (context)=>PhotoUploadScreen()));

  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final double horizontalPadding = width > 600 ? width * 0.15 : 25;

    return Consumer<ProgressProvider>(builder: (context,progressProvider,child)
    {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Marriage Beuru",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
          backgroundColor: Colors.pink,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: () {
              progressProvider.previousScreen();
              Navigator.pop(context);
            },
          ),
          actions: [
            Consumer<ProgressProvider>(
              builder: (context, progressProvider, child) {
                final percentage = (progressProvider.progress * 100).toStringAsFixed(0);
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          value: progressProvider.progress,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          backgroundColor: Colors.grey[300],
                          strokeWidth: 2.0,
                        ),
                      ),
                      SizedBox(width: 4),
                      Text(
                        '$percentage%',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
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
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "What's your educational background?",
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
                    "Choose your highest level of education.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: subHeadingSize,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 40),

                  Column(
                    children: _educationLevels.map((education) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: _buildEducationOption(education),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 50),

                  ElevatedButton(
                    onPressed: _submitEducationSelection,
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
      );
    }
    );
  }

  Widget _buildEducationOption(String education) {
    bool isSelected = _selectedEducation == education;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedEducation = education;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? pinkColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(15),
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
            Icon(
              Icons.school,
              size: 24,
              color: isSelected ? pinkColor : Colors.grey[600],
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                education,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? pinkColor : Colors.black87,
                ),
              ),
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