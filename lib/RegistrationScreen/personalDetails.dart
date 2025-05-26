import 'package:flutter/material.dart';
import 'package:marriage_bereau_app/Essentials/colors.dart';
import '../Essentials/customTextField.dart';
import '../Essentials/fontSizes.dart';

class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({super.key});

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            CustomTextField(
              label: "Full Name",
              controller: _nameController,
              hint: "Enter your full name",
              prefixIcon: Icons.person,
              validator: (value) => value!.isEmpty ? "Please enter your name" : null,
            ),
            _buildDatePickerField(),
            CustomTextField(
              label: "Phone Number",
              controller: _phoneController,
              hint: "Enter your phone number",
              prefixIcon: Icons.phone,
              keyboardType: TextInputType.phone,
              validator: (value) => value!.isEmpty ? "Please enter your phone number" : null,
            ),
            CustomTextField(
              label: "Address",
              controller: _addressController,
              hint: "Enter your address",
              prefixIcon: Icons.home,
              maxLines: 3,
              validator: (value) => value!.isEmpty ? "Please enter your address" : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePickerField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Date of Birth",
            style: TextStyle(
              fontSize: subHeadingSize,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 3)),
              ],
            ),
            child: TextFormField(
              controller: _dobController,
              readOnly: true,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                hintText: "Select your date of birth",
                border: InputBorder.none,
                prefixIcon: Icon(Icons.calendar_today, color: pinkColor),
              ),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime(2000),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null) {
                  setState(() {
                    _dobController.text =
                    "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                  });
                }
              },
              validator: (value) =>
              value!.isEmpty ? "Please select your date of birth" : null,
            ),
          ),
        ],
      ),
    );
  }
}
