import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:marriage_bereau_app/Backend%20Logic/Sign%20Up%20Logic.dart';
import 'package:marriage_bereau_app/RegistrationScreen/MaritalStatus.dart';
import 'package:marriage_bereau_app/RegistrationScreen/photoUploadScreen.dart';
import 'package:provider/provider.dart';

class HeightScreen extends StatefulWidget
{
  @override
  State<HeightScreen>createState()=>HeightState();
}
class HeightState extends State<HeightScreen>
{
  @override
  Widget build(BuildContext context)
  {
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
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'How tall are You?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Consumer<HeightProvider>(
                builder: (context, provider, child) {
                  return ListView.builder(
                    itemCount: provider.heights.length,
                    itemBuilder: (context, index) {
                      final height = provider.heights[index];
                      final isSelected = provider.selectedHeight == height;

                      return ListTile(
                        title: Text(
                          '${height.cm}cm . ${height.inches}',
                          style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                        ),
                        tileColor: isSelected ? Colors.grey[200] : null,
                        trailing: isSelected ? Icon(Icons.check_circle, color: Colors.red) : null,
                        onTap: () {
                          provider.selectHeight(height);
                          _submitHeightSelection();
                        },
                      );
                    },
                  );
                },

              ),
            ),
          ],
        ),

      );
    });
  }

  void _submitHeightSelection() {
    final heightProvider = Provider.of<HeightProvider>(context, listen: false);

    if (heightProvider.selectedHeight == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your height to proceed!', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    print("Selected Height: ${heightProvider.selectedHeight?.inches}");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('You have selected: ${heightProvider.selectedHeight?.inches}!', style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.pink,
        behavior: SnackBarBehavior.floating,
      ),
    );

    final progressProvider = Provider.of<ProgressProvider>(context, listen: false);
    progressProvider.nextScreen();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => maritalStatus())
    );
  }
}