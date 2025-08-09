import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
// For ThemeProvider

class VoiceInputPage extends StatefulWidget {
  const VoiceInputPage({super.key});

  @override
  State<VoiceInputPage> createState() => _VoiceInputPageState();
}

class _VoiceInputPageState extends State<VoiceInputPage> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _recognizedText = '';
  String _statusMessage = 'Tap the microphone to start speaking';
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();
  }

  void _initSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        setState(() {
          _statusMessage = status;
          if (status == 'done') {
            _isListening = false;
          }
        });
      },
      onError: (error) {
        setState(() {
          _errorMessage = error.errorMsg;
          _isListening = false;
        });
      },
    );

    if (!available) {
      setState(() => _errorMessage = 'Speech recognition not available');
    }
  }

  void _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    } else {
      setState(() {
        _recognizedText = '';
        _errorMessage = '';
        _statusMessage = 'Listening...';
      });

      bool started = await _speech.listen(
        onResult: (result) => setState(() {
          _recognizedText = result.recognizedWords;
          if (result.finalResult) {
            _isListening = false;
            _statusMessage = 'Tap microphone to speak again';
          }
        }),
        listenFor: const Duration(seconds: 30),
        localeId: 'en_US',
      );

      if (started) {
        setState(() => _isListening = true);
      } else {
        setState(() => _errorMessage = 'Failed to start listening');
      }
    }
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Input'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              Navigator.pushReplacementNamed(context, '/dashboard'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Status message
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  _errorMessage,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            // Voice visualization animation
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: _isListening
                      ? theme.colorScheme.primary
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Center(
                child: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  size: 60,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Status text
            Text(
              _errorMessage.isEmpty ? _statusMessage : '',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 30),

            // Recognized text display
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      if (_recognizedText.isNotEmpty)
                        Text(_recognizedText, style: theme.textTheme.bodyLarge)
                      else
                        Text(
                          'Your transcription will appear here',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.textTheme.bodyLarge?.color
                                ?.withOpacity(0.5),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  heroTag: 'mic_button',
                  backgroundColor: _isListening
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary,
                  onPressed: _toggleListening,
                  child: Icon(
                    _isListening ? Icons.stop : Icons.mic,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
                if (_recognizedText.isNotEmpty) ...[
                  const SizedBox(width: 20),
                  FloatingActionButton(
                    heroTag: 'send_button',
                    backgroundColor: theme.colorScheme.secondary,
                    onPressed: () {
                      Navigator.pop(context, _recognizedText);
                    },
                    child: Icon(
                      Icons.send,
                      color: theme.colorScheme.onSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
