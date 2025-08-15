// lib/functions/spm_bridge.dart
import 'package:flutter/services.dart';

class SpmBridge {
  static const MethodChannel _channel = MethodChannel('app.translator.tokenizer');

  /// Load an spm asset into native processor (modelId is a short key you choose)
  static Future<bool> loadSpm(String assetPath, String modelId) async {
    final res = await _channel.invokeMethod('loadSpm', {'assetPath': assetPath, 'modelId': modelId});
    return res == true;
  }

  /// Tokenize text -> list of ints
  static Future<List<int>> tokenize(String modelId, String text) async {
    final List<dynamic> ids = await _channel.invokeMethod('tokenize', {'modelId': modelId, 'text': text});
    return ids.cast<int>();
  }

  /// Detokenize list<int> -> text
  static Future<String> detokenize(String modelId, List<int> ids) async {
    return await _channel.invokeMethod('detokenize', {'modelId': modelId, 'ids': ids});
  }
}
