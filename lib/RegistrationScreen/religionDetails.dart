import 'package:flutter/material.dart';
import '../Essentials/colors.dart';
import '../Essentials/fontSizes.dart';
import '../Essentials/customTextField.dart';

class ReligionDetailsScreen extends StatelessWidget {
  const ReligionDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final _casteControler=TextEditingController();
    final _practicesControler=TextEditingController();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Religion"),
          _buildDropDown(),

          SizedBox(height: height * 0.03),
          _buildSectionTitle("Caste (if applicable)"),
          CustomTextField(
            hint: "Enter Caste", label: 'Caste',
            controller: _casteControler,
          ),

          SizedBox(height: height * 0.03),
          _buildSectionTitle("Religious Practices"),
          CustomTextField(
            controller: _practicesControler,
            hint: "Describe religious practices (optional)",
            maxLines: 4, label: 'Practices',
          ),

          SizedBox(height: height * 0.05),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: pinkColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
              ),
              onPressed: () {
                // Submit action
              },
              child: Text(
                "Submit",
                style: TextStyle(fontSize: subHeadingSize, color: whiteColor, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: subHeadingSize, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildDropDown() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Select Religion',
        ),
        items: ["Islam", "Christianity", "Hinduism", "Buddhism", "Other"]
            .map((religion) => DropdownMenuItem(
          value: religion,
          child: Text(religion),
        ))
            .toList(),
        onChanged: (value) {},
      ),
    );
  }
}
