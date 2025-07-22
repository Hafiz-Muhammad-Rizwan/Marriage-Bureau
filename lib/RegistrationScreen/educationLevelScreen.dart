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
  final List<String> _educationLevels = [
    "High School",
    "Diploma",
    "Undergraduate (Bachelor's)",
    "Postgraduate (Master's)",
    "Doctorate (PhD)",
    "Vocational Training",
    "Other",
  ];

  final TextEditingController _customEducationController = TextEditingController();
  String? _selectedEducation;

  @override
  void dispose() {
    _customEducationController.dispose();
    super.dispose();
  }

  void _submitEducationSelection() {
    final educationProvider = Provider.of<EducationLevelProvider>(context, listen: false);

    if (educationProvider.selectedLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your education level to proceed!', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (educationProvider.selectedLevel?.level == "Other" &&
        _customEducationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your education level!', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (educationProvider.selectedLevel?.level == "Other") {
      educationProvider.setCustomEducation(_customEducationController.text.trim());
    }
    print(educationProvider.selectedLevel?.level);
    final progressProvider = Provider.of<ProgressProvider>(context, listen: false);
    progressProvider.nextScreen();
    Navigator.push(context, MaterialPageRoute(builder: (context) => PhotoUploadScreen()));
  }

  Widget _buildEducationOption(String education) {
    final educationProvider = Provider.of<EducationLevelProvider>(context, listen: false);
    bool isSelected = educationProvider.selectedLevel?.level == education;

    return GestureDetector(
      onTap: () {
        educationProvider.selectLevel(EducationLevel(education));

        if (education != "Other") {
          _customEducationController.clear();
        }

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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final double horizontalPadding = width > 600 ? width * 0.15 : 25;

    return Consumer<ProgressProvider>(builder: (context, progressProvider, child) {
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
            icon: Icon(Icons.arrow_back, color: Colors.white),
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
                      Text('$percentage%', style: TextStyle(color: Colors.white)),
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
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text("What's your educational background?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: headingSize * 1.1,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    )),
                const SizedBox(height: 10),
                Text("Choose your highest level of education.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: subHeadingSize, color: Colors.grey[700])),
                const SizedBox(height: 40),

                ..._educationLevels.map((education) => Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: _buildEducationOption(education),
                )),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _selectedEducation == "Other"
                      ? Padding(
                    key: ValueKey('textfield'), // Ensures smooth transition
                    padding: const EdgeInsets.only(bottom: 20),
                    child: TextField(
                      controller: _customEducationController,
                      maxLength: 25,
                      onChanged: (value) {
                        // Optional: update live if needed
                      },
                      decoration: InputDecoration(
                        labelText: "Your Education",
                        hintText: "Enter your Education",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: pinkColor,
                            width: 2.5,
                          ),
                        ),
                        counterText: "${_customEducationController.text.length}/25",
                        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
                      ),
                      style: const TextStyle(fontSize: 18, color: Colors.black87),
                      cursorColor: pinkColor,
                    ),
                  )
                      : const SizedBox.shrink(),
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
                  ),
                  child: const Text(
                    "Continue",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
