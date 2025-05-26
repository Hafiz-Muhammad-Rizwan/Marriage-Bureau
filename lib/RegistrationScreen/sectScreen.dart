import 'package:flutter/material.dart';
import 'package:marriage_bereau_app/Essentials/colors.dart';
import 'package:marriage_bereau_app/Essentials/fontSizes.dart';
import 'package:marriage_bereau_app/RegistrationScreen/professionScreen.dart';

class Sectscreen extends StatefulWidget {
  const Sectscreen({super.key});

  @override
  State<Sectscreen> createState() => _SectscreenState();
}

class _SectscreenState extends State<Sectscreen> {
  String? _selectedSect;
  final List<String> _sects = [
    "Sunni",
    "Shia",
    "Deobandi",
    "Wahabi",
    "Other",
  ];
  void _submitSectSelection() {
    if (_selectedSect == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your sect to proceed!', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    print("Selected Sect: $_selectedSect");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('You have selected: $_selectedSect!', style: const TextStyle(color: Colors.white)),
        backgroundColor: pinkColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.push(context, MaterialPageRoute(builder: (context)=>Professionscreen()));
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final double horizontalPadding = width > 600 ? width * 0.15 : 25;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Select Your Sect",
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
                  children: _sects.map((sect) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: _buildSectOption(sect),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 50),
                ElevatedButton(
                  onPressed: _submitSectSelection,
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

  Widget _buildSectOption(String sect) {
    bool isSelected = _selectedSect == sect;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSect = sect;
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
              Icons.circle,
              size: 20,
              color: isSelected ? pinkColor : Colors.grey[400],
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                sect,
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