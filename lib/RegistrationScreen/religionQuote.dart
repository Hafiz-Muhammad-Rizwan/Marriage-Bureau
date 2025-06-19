import 'package:flutter/material.dart';
import 'package:marriage_bereau_app/Backend%20Logic/Sign%20Up%20Logic.dart';
import 'package:marriage_bereau_app/Essentials/colors.dart';
import 'package:marriage_bereau_app/Essentials/fontSizes.dart';
import 'package:marriage_bereau_app/RegistrationScreen/sectScreen.dart';
import 'package:provider/provider.dart';

class MotivationalQuoteScreen extends StatelessWidget {
  const MotivationalQuoteScreen({super.key});

  final String _motivationalQuote =
      "\"The best way to predict the future is to create it.\"";
  final String _quoteAuthor = "- Peter Drucker";

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final double horizontalPadding = width > 600 ? width * 0.15 : 30;
    final double verticalPadding = width > 600 ? 80 : 50;

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
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.pink.shade50, Colors.white],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: width * 0.15 > 100 ? 100 : width * 0.15,
                    color: pinkColor.withOpacity(0.7),
                  ),
                  const SizedBox(height: 30),

                  Text(
                    _motivationalQuote,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: width * 0.06 > 28 ? 28 : width * 0.06,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // The Author
                  Text(
                    _quoteAuthor,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: width * 0.04 > 18 ? 18 : width * 0.04,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 50),

                  ElevatedButton(
                    onPressed: () {
                      final progressProvider = Provider.of<ProgressProvider>(context, listen: false);
                      progressProvider.nextScreen();
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>Sectscreen()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: pinkColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                      shadowColor: pinkColor.withOpacity(0.5),
                    ),
                    child: Text(
                      "Get More Inspiration",
                      style: TextStyle(
                        fontSize: subHeadingSize,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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
}