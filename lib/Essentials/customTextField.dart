import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData? prefixIcon;
  final int maxLines;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final EdgeInsetsGeometry contentPadding;
  final bool filled;
  final Color fillColor;
  final Color borderColor;
  final Color focusedBorderColor;
  final Color errorBorderColor;
  final double borderRadius;

  const CustomTextField({
    Key? key,
    required this.label,
    required this.hint,
    required this.controller,
    this.prefixIcon,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    this.filled = true,
    this.fillColor = Colors.white,
    this.borderColor = const Color(0xFFBDBDBD), // Grey 400
    this.focusedBorderColor = Colors.pinkAccent,
    this.errorBorderColor = Colors.red,
    this.borderRadius = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final subHeadingSize = 16.0; // Or pass as parameter

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: subHeadingSize,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: TextFormField(
              controller: controller,
              maxLines: maxLines,
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              validator: validator ??
                      (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter $label';
                    }
                    return null;
                  },
              decoration: InputDecoration(
                filled: filled,
                fillColor: fillColor,
                hintText: hint,
                contentPadding: contentPadding,
                prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: focusedBorderColor) : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: BorderSide(color: focusedBorderColor, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: BorderSide(color: errorBorderColor, width: 2),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                  borderSide: BorderSide(color: errorBorderColor, width: 2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
