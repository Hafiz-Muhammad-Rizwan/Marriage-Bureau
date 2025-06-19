import 'package:flutter/material.dart';
import 'package:marriage_bereau_app/Backend%20Logic/Sign%20Up%20Logic.dart';
import 'package:marriage_bereau_app/Essentials/fontSizes.dart';
import 'package:marriage_bereau_app/RegistrationScreen/religionQuote.dart';
import 'package:provider/provider.dart';
class Bioscreen extends StatefulWidget {
  const Bioscreen({super.key});

  @override
  State<Bioscreen> createState() => _BioscreenState();
}

class _BioscreenState extends State<Bioscreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // Dispose is handled by BioProvider
    super.dispose();
  }

  void _submitBio(BuildContext context) {
    final bioProvider = Provider.of<BioProvider>(context, listen: false);
    final progressProvider = Provider.of<ProgressProvider>(context, listen: false);

    if (_formKey.currentState!.validate()) {
      final bio = bioProvider.bio.trim();
      if (bio.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter your bio!', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      print("Bio: $bio");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bio saved successfully!', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.pink,
          behavior: SnackBarBehavior.floating,
        ),
      );

      progressProvider.nextScreen();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MotivationalQuoteScreen()),
      );
    }
  }
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isWide = width > 600;
    final double horizontalPadding = isWide ? width * 0.15 : 25;
    return Consumer2<ProgressProvider,BioProvider>(builder: (context,progressProvider,bioProvider,child){
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
                print('Progress: ${progressProvider.progress}, Percentage: $percentage%'); // Debug print
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
        body: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, Colors.grey[100]!],
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 30),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Bio",
                      style: TextStyle(
                        fontSize: headingSize * 1.2,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Tell us about yourself, your hobbies & future plans!",
                      style: TextStyle(
                        fontSize: subHeadingSize,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: bioProvider.bioController,
                      decoration: InputDecoration(
                        hintText: "Add bio",
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.pink),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: EdgeInsets.all(16),
                      ),
                      maxLines: 5,
                      onChanged: (value) => bioProvider.updateBio(value),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Please enter your bio";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 50),
                    ElevatedButton(
                      onPressed: () => _submitBio(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 8,
                        shadowColor: Colors.pink.withOpacity(0.5),
                      ),
                      child: const Text(
                        "Add bio",
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
    });
  }
}
