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
  String? _nrc; // Variable to store extracted student ID
  final _nrcController = TextEditingController(); // Controller for student ID

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

    setState(() {
      _extractedText = extractedText;

      // Extract and store nrc ID (I'm specifically interested in the 3rd line
      //of the extracted text. This is not ideal if we factor in that the MLKit
      //dependency can not always have the 3rd text as nrc id)
      final lines = _extractedText!.split('\n');
      if (lines.length >= 3) {
        _nrc = lines[2];
        _nrcController.text = _nrc!;
      } else {
        _nrc = null;
        _nrcController.text = "";
      }
    });

    print(extractedText); // You can keep this for debugging purposes
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
              controller: _nrcController,
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
