import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/material.dart';
import 'package:marriage_bereau_app/RegistrationScreen/personalDetails.dart';
import 'package:marriage_bereau_app/RegistrationScreen/qualificationDetails.dart';
import 'package:marriage_bereau_app/RegistrationScreen/religionDetails.dart';

class Stepmanager extends StatefulWidget {
  const Stepmanager({super.key});

  @override
  State<Stepmanager> createState() => _StepmanagerState();
}

class _StepmanagerState extends State<Stepmanager> {
  int currentStep = 0;

  final screens = [
    PersonalDetailsScreen(),
    QualificationScreen(),
    ReligionDetailsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Registration", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.pinkAccent,
        centerTitle: true,
        elevation: 4,
        shadowColor: Colors.pinkAccent.shade100,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: EasyStepper(
              direction: Axis.horizontal,
              activeStep: currentStep,
              lineStyle: LineStyle(
                lineLength: 60,
                lineThickness: 4,
                lineSpace: 0,
                lineType: LineType.normal,
                activeLineColor: Colors.pinkAccent,
                finishedLineColor: Colors.pinkAccent,
                defaultLineColor: Colors.grey.shade300,
              ),
              activeStepTextColor: Colors.pinkAccent,
              finishedStepTextColor: Colors.pinkAccent,
              internalPadding: 12,
              showLoadingAnimation: false,
              borderThickness: 2,
              stepRadius: 20,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              showStepBorder: true,
              steps: [
                EasyStep(
                  icon: Icon(Icons.person, color: Colors.white),
                  title: 'Personal',
                  customStep: CircleAvatar(
                    backgroundColor: currentStep >= 0 ? Colors.pinkAccent : Colors.grey.shade300,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                ),
                EasyStep(
                  icon: Icon(Icons.school, color: Colors.white),
                  title: 'Qualification',
                  customStep: CircleAvatar(
                    backgroundColor: currentStep >= 1 ? Colors.pinkAccent : Colors.grey.shade300,
                    child: Icon(Icons.school, color: Colors.white),
                  ),
                ),
                EasyStep(
                  icon: Icon(Icons.account_balance, color: Colors.white),
                  title: 'Religion',
                  customStep: CircleAvatar(
                    backgroundColor: currentStep >= 2 ? Colors.pinkAccent : Colors.grey.shade300,
                    child: Icon(Icons.account_balance, color: Colors.white),
                  ),
                ),
              ],
              onStepReached: (index) {
                setState(() {
                  currentStep = index;
                });
              },
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
              child: Container(
                key: ValueKey(currentStep),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: screens[currentStep],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (currentStep > 0)
                  OutlinedButton.icon(
                    onPressed: () => setState(() => currentStep--),
                    icon: Icon(Icons.arrow_back),
                    label: const Text("Back"),
                  ),
                ElevatedButton.icon(
                  onPressed: () {
                    if (currentStep < screens.length - 1) {
                      setState(() => currentStep++);
                    } else {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Completed"),
                          content: const Text("You have submitted all the details."),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text("OK"),
                            )
                          ],
                        ),
                      );
                    }
                  },
                  icon: Icon(currentStep == screens.length - 1 ? Icons.check : Icons.arrow_forward),
                  label: Text(currentStep == screens.length - 1 ? 'Submit' : 'Next'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
