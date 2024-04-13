import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class OCRScreen extends StatefulWidget {
  const OCRScreen({super.key});

  @override
  State<OCRScreen> createState() => _OCRScreenState();
}

class _OCRScreenState extends State<OCRScreen> {
  File? _file;
  String? _extractedText;
  final _studentIdController = TextEditingController();
  String?
      _potentialRegistrationNumber; // Variable to store potential registration number

  Future<void> _pickImage(ImageSource source) async {
    final imagePicker = await ImagePicker().pickImage(source: source);
    if (imagePicker != null) {
      setState(() {
        _file = File(imagePicker!.path);
      });
      _processImage();
    }
  }

  Future<void> _processImage() async {
    final inputImage = InputImage.fromFilePath(_file!.path);
    final textRecognizer = TextRecognizer();
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);
    String extractedText = recognizedText.text;

    // Update state with extracted text and find potential registration number
    setState(() {
      _extractedText = extractedText;
      _potentialRegistrationNumber =
          _findPotentialRegistrationNumber(extractedText);
      _studentIdController.text = _potentialRegistrationNumber!;
    });

    print(extractedText); // You can keep this for debugging purposes
  }

  String? _findPotentialRegistrationNumber(String text) {
    final lines = text.split('\n');
    for (var line in lines) {
      if (line.contains(RegExp(r'\d'))) {
        // Check if line has at least one digit
        return line;
      }
    }
    return null; // No potential registration number found
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OCR Test APPLICATION'),
      ),
      body: Center(
        child: ListView(
          children: [
            _file == null
                ? const Text('Select an image file')
                : Image.file(_file!),
            const SizedBox(
              height: 20,
            ),
            const Text('Student ID:'),
            TextFormField(
              controller: _studentIdController,
              decoration: const InputDecoration(
                hintText: 'Enter or edit Student ID',
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  child: const Text('Pick from Gallery'),
                ),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                  onPressed: () => _pickImage(ImageSource.camera),
                  child: const Text('Capture with Camera'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
