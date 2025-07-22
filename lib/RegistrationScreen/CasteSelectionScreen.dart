import 'package:flutter/material.dart';
import 'package:marriage_bereau_app/Backend%20Logic/Sign%20Up%20Logic.dart';
import 'package:marriage_bereau_app/Essentials/colors.dart';
import 'package:marriage_bereau_app/Essentials/fontSizes.dart';
import 'package:provider/provider.dart';

class CasteSelectionScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const CasteSelectionScreen({
    Key? key,
    required this.onNext,
    required this.onBack,
  }) : super(key: key);

  @override
  _CasteSelectionScreenState createState() => _CasteSelectionScreenState();
}

class _CasteSelectionScreenState extends State<CasteSelectionScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _animationController;
  Animation<double>? _fadeAnimation;
  final TextEditingController _customCasteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _customCasteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final double horizontalPadding = width > 600 ? width * 0.15 : 25;
    final casteProvider = Provider.of<CasteProvider>(context);
    final progressProvider = Provider.of<ProgressProvider>(context);

    // Check if "Other" option is selected
    bool isOtherSelected = casteProvider.selectedCaste?.name == 'Other';

    // Sync the controller with the provider's custom caste name
    if (isOtherSelected && _customCasteController.text != casteProvider.customCasteName) {
      _customCasteController.text = casteProvider.customCasteName;
    }

    return Scaffold(
      appBar: AppBar(
        title: _fadeAnimation != null
            ? FadeTransition(
          opacity: _fadeAnimation!,
          child: const Text(
            "Marriage Beuru",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
        )
            : const Text(
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
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: widget.onBack,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    value: progressProvider.progress,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    backgroundColor: Colors.grey[300],
                    strokeWidth: 2.0,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${(progressProvider.progress * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
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
            child: _fadeAnimation != null
                ? FadeTransition(
              opacity: _fadeAnimation!,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Tell us about your community...",
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
                    "Which caste do you identify with?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: subHeadingSize,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Column(
                    children: casteProvider.castes.map((caste) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: _buildCasteOption(caste, casteProvider),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  // Show custom caste text field only when "Other" is selected
                  if (isOtherSelected)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.only(bottom: 20),
                      child: TextField(
                        controller: _customCasteController,
                        maxLength: 25, // Limit to 25 characters
                        onChanged: (value) {
                          // Update the provider when text changes
                          casteProvider.setCustomCasteName(value);
                        },
                        decoration: InputDecoration(
                          labelText: "Your Caste Name",
                          labelStyle: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 16,
                          ),
                          hintText: "Enter your caste name",
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
                          counterText: "${_customCasteController.text.length}/25",
                          counterStyle: TextStyle(
                            color: _customCasteController.text.length >= 25 ? Colors.red : Colors.grey[600],
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
                    onPressed: casteProvider.selectedCaste == null || _isLoading
                        ? null
                        : () {
                      setState(() {
                        _isLoading = true;
                      });
                      widget.onNext();
                      setState(() {
                        _isLoading = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: pinkColor,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 8,
                      shadowColor: pinkColor.withOpacity(0.5),
                      disabledBackgroundColor: pinkColor.withOpacity(0.5),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                        : const Text(
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
            )
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Tell us about your community...",
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
                  "Which caste do you identify with?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: subHeadingSize,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 40),
                Column(
                  children: casteProvider.castes.map((caste) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: _buildCasteOption(caste, casteProvider),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                // Show custom caste text field only when "Other" is selected
                if (isOtherSelected)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.only(bottom: 20),
                    child: TextField(
                      controller: _customCasteController,
                      maxLength: 25, // Limit to 25 characters
                      onChanged: (value) {
                        // Update the provider when text changes
                        casteProvider.setCustomCasteName(value);
                      },
                      decoration: InputDecoration(
                        labelText: "Your Caste Name",
                        labelStyle: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 16,
                        ),
                        hintText: "Enter your caste name",
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
                        counterText: "${_customCasteController.text.length}/25",
                        counterStyle: TextStyle(
                          color: _customCasteController.text.length >= 25 ? Colors.red : Colors.grey[600],
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
                  onPressed: casteProvider.selectedCaste == null || _isLoading
                      ? null
                      : () {
                    setState(() {
                      _isLoading = true;
                    });
                    widget.onNext();
                    setState(() {
                      _isLoading = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: pinkColor,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 8,
                    shadowColor: pinkColor.withOpacity(0.5),
                    disabledBackgroundColor: pinkColor.withOpacity(0.5),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                      : const Text(
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

  Widget _buildCasteOption(Caste caste, CasteProvider provider) {
    bool isSelected = provider.selectedCaste == caste;
    return GestureDetector(
      onTap: () {
        provider.selectCaste(caste);
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
                caste.name,
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