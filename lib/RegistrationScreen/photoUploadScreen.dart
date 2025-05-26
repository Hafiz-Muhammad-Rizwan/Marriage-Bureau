import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:marriage_bereau_app/Essentials/colors.dart';
import 'package:marriage_bereau_app/Essentials/fontSizes.dart';

class PhotoUploadScreen extends StatefulWidget {
  const PhotoUploadScreen({super.key});

  @override
  State<PhotoUploadScreen> createState() => _PhotoUploadScreenState();
}

class _PhotoUploadScreenState extends State<PhotoUploadScreen> {
  XFile? _imageFile;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image selected!', style: TextStyle(color: whiteColor)),
            backgroundColor: pinkColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No image selected.', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.orangeAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print("Error picking image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: ${e.toString()}', style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _submitPhoto() {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload a photo to continue!', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    print("Image Path: ${_imageFile!.path}");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Photo uploaded successfully!', style: TextStyle(color: whiteColor)),
        backgroundColor: pinkColor,
        behavior: SnackBarBehavior.floating,
      ),
    );

  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final double horizontalPadding = width > 600 ? width * 0.15 : 25;
    final double avatarRadius = width * 0.25 > 100 ? 100 : width * 0.25;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Upload Your Photo",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
        backgroundColor: pinkColor,
        elevation: 0,
        centerTitle: true,
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Add Your Profile Picture",
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
                  "A clear photo helps others get to know you!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: subHeadingSize,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 50),

                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: pinkColor.withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: avatarRadius,
                      backgroundColor: pinkColor.withOpacity(0.2),
                      backgroundImage: _imageFile != null ? FileImage(File(_imageFile!.path)) : null,
                      child: _imageFile == null
                          ? Icon(
                        Icons.camera_alt,
                        size: avatarRadius * 0.6,
                        color: pinkColor.withOpacity(0.7),
                      )
                          : null,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                TextButton.icon(
                  onPressed: _pickImage,
                  icon: Icon(Icons.photo_library, color: pinkColor),
                  label: Text(
                    _imageFile == null ? "Choose Photo from Gallery" : "Change Photo",
                    style: TextStyle(
                      fontSize: subHeadingSize,
                      color: pinkColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: pinkColor.withOpacity(0.5)),
                    ),
                  ),
                ),

                const SizedBox(height: 50),

                ElevatedButton(
                  onPressed: _submitPhoto,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: pinkColor,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 8,
                    shadowColor: pinkColor.withOpacity(0.5),
                  ),
                  child: const Text(
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
}