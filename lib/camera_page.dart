import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter/services.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isCameraAvailable = true;

  // New state variables for enhanced functionality
  bool _isProcessing = false;
  String _extractedText = '';
  final FlutterTts _tts = FlutterTts();
  final TextRecognizer _textRecognizer = TextRecognizer();
  double _speechRate = 0.5;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initTts(); // Initialize text-to-speech
  }

  // CHANGE in _initTts
  Future<void> _initTts() async {
    // Set Filipino (Tagalog) voice
    await _tts.setLanguage('fil-PH');
    await _tts.setSpeechRate(_speechRate);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        setState(() {
          _isCameraAvailable = false;
        });
        return;
      }

      final firstCamera = cameras.first;

      _controller = CameraController(
        firstCamera,
        ResolutionPreset.medium,
      );

      _initializeControllerFuture = _controller.initialize();
      setState(() {}); // Rebuild UI after initialization
    } catch (e) {
      print('Error initializing camera: $e');
      setState(() {
        _isCameraAvailable = false;
      });
    }
  }

  // Process image from camera
  Future<void> _processImage() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _extractedText = '';
    });

    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();
      await _processImageFile(image.path);
    } catch (e) {
      print('Error processing image: $e');
      setState(() {
        _extractedText = 'Error processing image: $e';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  // Process image from gallery
  Future<void> _processImageFromGallery() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _extractedText = '';
    });

    try {
      final imagePicker = ImagePicker();
      final pickedFile =
          await imagePicker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        await _processImageFile(pickedFile.path);
      }
    } catch (e) {
      print('Error processing gallery image: $e');
      setState(() {
        _extractedText = 'Error processing image: $e';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  // // Process image file with OCR
  // Future<void> _processImageFile(String imagePath) async {
  //   try {
  //     final inputImage = InputImage.fromFilePath(imagePath);
  //     final recognizedText = await _textRecognizer.processImage(inputImage);

  //     setState(() {
  //       _extractedText = recognizedText.text;
  //     });

  //     if (_extractedText.isNotEmpty) {
  //       await _tts.speak(_extractedText);
  //     }
  //   } catch (e) {
  //     print('Error recognizing text: $e');
  //     setState(() {
  //       _extractedText = 'Error recognizing text: $e';
  //     });
  //   }
  // }
  // //CHANGE in _processImageFile
  // Future<void> _processImageFile(String imagePath) async {
  //   try {
  //     final inputImage = InputImage.fromFilePath(imagePath);
  //     final recognizedText = await _textRecognizer.processImage(inputImage);

  //     setState(() {
  //       _extractedText = recognizedText.text;
  //     });

  //     if (_extractedText.isNotEmpty) {
  //       await _tts.setLanguage('fil-PH'); // ensure Filipino each time
  //       await _tts.speak(_extractedText);
  //     }
  //   } catch (e) {
  //     print('Error recognizing text: $e');
  //     setState(() {
  //       _extractedText = 'Error recognizing text: $e';
  //     });
  //   }
  // }
//   Future<void> _processImageFile(String imagePath) async {
//   try {
//     final inputImage = InputImage.fromFilePath(imagePath);
//     final recognizedText = await _textRecognizer.processImage(inputImage);

//   //  setState(() {
//       final extracted  = recognizedText.text;
//   // });

//     if (_extractedText.isNotEmpty) {
//       await _tts.setLanguage('fil-PH');
//       await _tts.speak(extracted);

//       // ✅ Return to previous screen with extracted text
//       Navigator.pop(context, extracted);
//     }
//   } catch (e) {
//     print('Error recognizing text: $e');
//     setState(() {
//       _extractedText = 'Error recognizing text: $e';
//     });
//   }
// }

Future<void> _processImageFile(String imagePath) async {
  try {
    final inputImage = InputImage.fromFilePath(imagePath);
    final recognizedText = await _textRecognizer.processImage(inputImage);

    final extracted = recognizedText.text;

    if (extracted.isNotEmpty) {
      // await _tts.setLanguage('fil-PH');
      // await _tts.speak(extracted);

      Navigator.pop(context, extracted);
    }
  } catch (e) {
    print('Error recognizing text: $e');
    setState(() {
      _extractedText = 'Error recognizing text: $e';
    });
  }
}



  // Copy text to clipboard
  Future<void> _copyToClipboard() async {
    if (_extractedText.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: _extractedText));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Text copied to clipboard')),
      );
    }
  }

  // Adjust speech rate
  Future<void> _adjustSpeechRate(double rate) async {
    setState(() {
      _speechRate = rate;
    });
    await _tts.setSpeechRate(rate);
  }

  @override
  void dispose() {
    if (_isCameraAvailable) {
      _controller.dispose();
    }
    _textRecognizer.close(); // Clean up text recognizer
    _tts.stop(); // Clean up TTS
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Translation'),
        backgroundColor: Colors.blue.shade700,
        actions: [
          if (_extractedText.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: _copyToClipboard,
              tooltip: 'Copy text',
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: !_isCameraAvailable
                ? const Center(
                    child: Text('Camera not available or permission denied.'))
                : FutureBuilder<void>(
                    future: _initializeControllerFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return Stack(
                          children: [
                            CameraPreview(_controller),
                            if (_isProcessing)
                              const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              ),
                          ],
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                            child: Text('Error initializing camera.'));
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
          ),
          if (_extractedText.isNotEmpty)
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  border: Border(top: BorderSide(color: Colors.grey.shade400)),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _extractedText,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_isCameraAvailable)
            FloatingActionButton(
              heroTag: 'camera',
              onPressed: _processImage,
              child: const Icon(Icons.camera_alt),
            ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'gallery',
            onPressed: _processImageFromGallery,
            child: const Icon(Icons.photo_library),
          ),
          if (_extractedText.isNotEmpty) ...[
            const SizedBox(height: 16),
            FloatingActionButton(
              heroTag: 'speak',
              child: const Icon(Icons.volume_up),
              onPressed: () => _tts.speak(_extractedText),
            ),
          ],
        ],
      ),
      // bottomNavigationBar: _extractedText.isNotEmpty
      //     ? SafeArea(
      //         child: Padding(
      //           padding:
      //               const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      //           child: Row(
      //             children: [
      //               const Text('Speed:'),
      //               Expanded(
      //                 child: Slider(
      //                   value: _speechRate,
      //                   min: 0.1,
      //                   max: 1.0,
      //                   divisions: 9,
      //                   label: _speechRate.toStringAsFixed(1),
      //                   onChanged: _adjustSpeechRate,
      //                 ),
      //               ),
      //               IconButton(
      //                 icon: const Icon(Icons.stop),
      //                 onPressed: _tts.stop,
      //                 tooltip: 'Stop speech',
      //               ),
      //             ],
      //           ),
      //         ),
      //       )
      //     : null,
    );
  }
}
