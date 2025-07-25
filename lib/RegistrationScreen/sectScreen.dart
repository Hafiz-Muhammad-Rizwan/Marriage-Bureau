import 'package:flutter/material.dart';
import 'package:marriage_bereau_app/Backend%20Logic/Sign%20Up%20Logic.dart';
import 'package:marriage_bereau_app/Essentials/colors.dart';
import 'package:marriage_bereau_app/Essentials/fontSizes.dart';
import 'package:marriage_bereau_app/RegistrationScreen/CasteSelectionScreen.dart'; // Added import for CasteSelectionScreen
import 'package:marriage_bereau_app/RegistrationScreen/professionScreen.dart';
import 'package:provider/provider.dart';

class Sectscreen extends StatefulWidget {
  const Sectscreen({super.key});

  @override
  State<Sectscreen> createState() => _SectscreenState();
}

class _SectscreenState extends State<Sectscreen> {
  final TextEditingController _customSectController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final double horizontalPadding = width > 600 ? width * 0.15 : 25;
    return Consumer<ProgressProvider>(builder: (context, progressProvider, child) {
      return Consumer<SectProvider>(builder: (context, sectProvider, _) {
        bool isOtherSelected = sectProvider.selectedSect?.name == "Other";

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
                      "Tell us about your faith...",
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
                      "Which sect do you identify with?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: subHeadingSize,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 40),

                    Column(
                      children: sectProvider.sects.map((sect) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: _buildSectOption(sect, sectProvider),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Show custom sect text field only when "Other" is selected
                    if (isOtherSelected)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.only(bottom: 20),
                        child: TextField(
                          controller: _customSectController,
                          maxLength: 25, // Limit to 25 characters
                          onChanged: (value) {
                            // Update the provider when text changes
                            sectProvider.setCustomSectName(value);
                          },
                          decoration: InputDecoration(
                            labelText: "Your Sect Name",
                            labelStyle: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 16,
                            ),
                            hintText: "Enter your sect name",
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
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
                            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
                            counterText: "${_customSectController.text.length}/25",
                            counterStyle: TextStyle(
                              color: _customSectController.text.length >= 25 ? Colors.red : Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                          cursorColor: pinkColor,
                        ),
                      ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () => _submitSectSelection(sectProvider, progressProvider),
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
      });
    });
  }

  void _submitSectSelection(SectProvider sectProvider, ProgressProvider progressProvider) {
    if (sectProvider.selectedSect == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your sect to proceed!', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    print("Selected Sect: ${sectProvider.selectedSect?.name}");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('You have selected: ${sectProvider.selectedSect?.name}!', style: const TextStyle(color: Colors.white)),
        backgroundColor: pinkColor,
        behavior: SnackBarBehavior.floating,
      ),
    );

    progressProvider.nextScreen();

    // Navigate to CasteSelectionScreen instead of ProfessionScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CasteSelectionScreen(
          onNext: () {
            progressProvider.nextScreen();
            Navigator.push(context, MaterialPageRoute(builder: (context) => Professionscreen()));
          },
          onBack: () {
            progressProvider.previousScreen();
            Navigator.pop(context);
          },
        ),

      ),

    );
  }

  Widget _buildSectOption(Sect sect, SectProvider provider) {
    bool isSelected = provider.selectedSect == sect;
    return GestureDetector(
      onTap: () {
        provider.selectSect(sect);
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
              Icons.circle,
              size: 20,
              color: isSelected ? pinkColor : Colors.grey[400],
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                sect.name,
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

