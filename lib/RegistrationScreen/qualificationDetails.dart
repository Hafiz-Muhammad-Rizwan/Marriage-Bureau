import 'package:flutter/material.dart';
import 'package:marriage_bereau_app/Essentials/colors.dart';
import 'package:marriage_bereau_app/Essentials/fontSizes.dart';
import '../Essentials/customTextField.dart';  // Import your custom text field here

class QualificationScreen extends StatefulWidget {
  const QualificationScreen({super.key});

  @override
  State<QualificationScreen> createState() => _QualificationScreenState();
}

class _QualificationScreenState extends State<QualificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _degreeController = TextEditingController();
  final _universityController = TextEditingController();
  final _yearController = TextEditingController();
  final _gradeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isWide = width > 600;
    final double horizontalPadding = isWide ? 50 : 20;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 30),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            CustomTextField(
              label: "Highest Qualification",
              hint: "e.g. Bachelor of Science",
              controller: _degreeController,
              validator: (value) => value!.isEmpty ? "Please enter Highest Qualification" : null,
            ),
            CustomTextField(
              label: "University / College",
              hint: "e.g. XYZ University",
              controller: _universityController,
              validator: (value) => value!.isEmpty ? "Please enter University / College" : null,
            ),
            CustomTextField(
              label: "Year of Passing",
              hint: "e.g. 2023",
              controller: _yearController,
              keyboardType: TextInputType.number,
              validator: (value) => value!.isEmpty ? "Please enter Year of Passing" : null,
            ),
            CustomTextField(
              label: "Grade / Percentage",
              hint: "e.g. 3.8 GPA / 85%",
              controller: _gradeController,
              validator: (value) => value!.isEmpty ? "Please enter Grade / Percentage" : null,
            ),
          ],
        ),
      ),
    );
  }
}
