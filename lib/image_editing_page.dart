// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_cropper/image_cropper.dart';
import 'custom_popup.dart'; // Import the CustomPopup widget

class ImageEditingPage extends StatefulWidget {
  final String imagePath;

  const ImageEditingPage({super.key, required this.imagePath});

  @override
  _ImageEditingPageState createState() => _ImageEditingPageState();
}

class _ImageEditingPageState extends State<ImageEditingPage> {
  late Image rotatedImage;
  int rotationAngle = 0; // Current rotation angle, initially 0 degrees

  @override
  void initState() {
    super.initState();
    rotatedImage = Image.file(File(widget.imagePath));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Image'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.rotate_right),
            tooltip: 'Rotate Right',
            onPressed: () {
              setState(() {
                rotationAngle += 90; // Increment rotation angle by 90 degrees
                rotatedImage = Image.memory(rotateImage(
                    Image.file(File(widget.imagePath)), rotationAngle));
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.flip),
            tooltip: 'Flip',
            onPressed: () {
              // Handle flip action
            },
          ),
          IconButton(
            icon: const Icon(Icons.crop),
            tooltip: 'Crop',
            onPressed: () {
              cropImage();
            },
          ),
        ],
      ),
      body: Center(
        child: rotatedImage,
      ),
    );
  }

  Future<void> cropImage() async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: widget.imagePath,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        uiSettings: [AndroidUiSettings(
          toolbarTitle: 'Crop',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          minimumAspectRatio: 1.0,
        ),]
      );

      if (croppedFile != null) {
        // Pass the cropped image path back to the home page
        Navigator.pop(context, croppedFile.path);
        // Show the custom popup
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomPopup(
              onClose: () {
                Navigator.of(context).pop();
              },
              onSelect: () {
                // Handle the select action here
                Navigator.of(context).pop(); // Close the popup
              },
            );
          },
        );
      }
    } catch (e) {
      print('Error cropping image: $e');
    }
  }

  Uint8List rotateImage(Image image, int angle) {
    final img.Image imgSrc =
        img.decodeImage(File(widget.imagePath).readAsBytesSync())!;
    final img.Image rotatedImg = img.copyRotate(imgSrc,
        angle: angle); // Rotate the image by the specified angle
    return Uint8List.fromList(
        img.encodePng(rotatedImg)); // Convert the rotated image to memory
  }
}
