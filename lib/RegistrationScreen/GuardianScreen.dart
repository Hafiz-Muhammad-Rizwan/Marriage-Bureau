import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Backend Logic/Sign Up Logic.dart';
import '../Essentials/colors.dart';
import 'IntetrestScreen.dart'; // adjust path as needed

class GuardianScreen extends StatefulWidget {
  const GuardianScreen({super.key});

  @override
  State<GuardianScreen> createState() => _GuardianScreenState();
}

class _GuardianScreenState extends State<GuardianScreen> {
  String? _selectedGuardian;
  final TextEditingController _customGuardianController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();

  void _submitGuardianSelection() {
    final guardianProvider = Provider.of<
        GuardianLevelProvider>(context, listen: false);
    if (_selectedGuardian == "Other" && _customGuardianController.text.trim().isNotEmpty) {
      guardianProvider.setCustomGuardian(_customGuardianController.text.trim());
    }

    if (!guardianProvider.isValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select guardian and enter number!', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    print("Guardian Type: ${guardianProvider.selectedLevel?.level}");
    print("Guardian Number: ${guardianProvider.selectedLevel?.number}");
    final progressProvider = Provider.of<ProgressProvider>(context, listen: false);
    progressProvider.nextScreen();
    Navigator.push(context, MaterialPageRoute(builder: (_) => const Intetrestscreen()));
  }

  Widget _buildGuardianOption(String guardian, GuardianLevelProvider provider) {
    final bool isSelected = guardian == _selectedGuardian;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGuardian = guardian;
          if (guardian != 'Other') {
            _customGuardianController.clear();
            provider.selectType(guardian);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: EdgeInsets.symmetric(vertical: 5),
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
                guardian,
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
    final provider = Provider.of<GuardianLevelProvider>(context);
    final guardianTypes = provider.guardianTypes;
    return  Consumer<ProgressProvider>(builder: (context, progressProvider, child) {
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
        bottomNavigationBar: Padding(padding: EdgeInsets.all(10),
        child: ElevatedButton(
          onPressed: _submitGuardianSelection,
          style: ElevatedButton.styleFrom(
            backgroundColor: pinkColor,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: const Text("Continue",
              style: TextStyle(fontSize: 18, color: Colors.white)),
        ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Who is your guardian?",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Wrap(

                children: guardianTypes.map((g) => _buildGuardianOption(g, provider)).toList(),
              ),
              if (_selectedGuardian == "Other")
                Padding(
                  key: const ValueKey('textfield'),
                  padding: const EdgeInsets.only(bottom: 20),
                  child: TextField(
                    controller: _customGuardianController,
                    maxLength: 25,
                    onChanged: (value) {
                      _selectedGuardian = value;
                    },
                    decoration: InputDecoration(
                      labelText: "Your Guardian",
                      hintText: "Enter your Guardian",
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
                      counterText: "${_customGuardianController.text.length}/25",
                      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
                    ),
                    style: const TextStyle(fontSize: 18, color: Colors.black87),
                    cursorColor: pinkColor,
                  ),
                ),
              const SizedBox(height: 20),
              const Text("Guardian Phone Number",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextField(
                controller: _numberController,
                keyboardType: TextInputType.phone,
                onChanged: (value) => provider.setGuardianNumber(value.trim()),
                decoration: InputDecoration(
                  hintText: "Enter phone number",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.pink),
                  ),
                ),
              ),
            ],
          ),
        ),

      );
    });
  }}
