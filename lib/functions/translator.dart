// lib/functions/translator.dart
// Full encoder -> decoder_with_past greedy generation for Marian-style ONNX exports.
// Requires a native SentencePiece bridge: SpmBridge.loadSpm / tokenize / detokenize.
//
// Assets layout expected:
// assets/models/tl_en/encoder_model_q.onnx
// assets/models/tl_en/decoder_model_q.onnx
// assets/models/tl_en/decoder_with_past_model_q.onnx
// assets/models/tl_en/source.spm
// assets/models/tl_en/target.spm
//
// assets/models/en_ceb/... (same structure)
//
// IMPORTANT: implement the native SpmBridge (Kotlin) we discussed earlier.

import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:onnxruntime/onnxruntime.dart';
import 'spm_bridge.dart';

import 'package:flutter/material.dart';

class Translator {
  // TL->EN sessions
  OrtSession? _encoderTlEn;
  OrtSession? _decoderTlEn;
  OrtSession? _decoderWithPastTlEn;

  // EN->CEB sessions
  OrtSession? _encoderEnCeb;
  OrtSession? _decoderEnCeb;
  OrtSession? _decoderWithPastEnCeb;

  /// Load ONNX sessions and sentencepiece tokenizers.
  Future<void> loadAllModels() async {
    // Load tl_en sessions
    final encTlBytes =
        (await rootBundle.load('assets/models/tl_en/encoder_model_quantized.onnx')).buffer.asUint8List();
    final decTlBytes =
        (await rootBundle.load('assets/models/tl_en/decoder_model_quantized.onnx')).buffer.asUint8List();
    final decPastTlBytes =
        (await rootBundle.load('assets/models/tl_en/decoder_with_past_model_quantized.onnx'))
            .buffer
            .asUint8List();

    _encoderTlEn = OrtSession.fromBuffer(encTlBytes, OrtSessionOptions());
    _decoderTlEn = OrtSession.fromBuffer(decTlBytes, OrtSessionOptions());
    _decoderWithPastTlEn = OrtSession.fromBuffer(decPastTlBytes, OrtSessionOptions());

    // Load en_ceb sessions
    final encEnBytes =
        (await rootBundle.load('assets/models/en_ceb/encoder_model_quantized.onnx')).buffer.asUint8List();
    final decEnBytes =
        (await rootBundle.load('assets/models/en_ceb/decoder_model_quantized.onnx')).buffer.asUint8List();
    final decPastEnBytes =
        (await rootBundle.load('assets/models/en_ceb/decoder_with_past_model_quantized.onnx'))
            .buffer
            .asUint8List();

    _encoderEnCeb = OrtSession.fromBuffer(encEnBytes, OrtSessionOptions());
    _decoderEnCeb = OrtSession.fromBuffer(decEnBytes, OrtSessionOptions());
    _decoderWithPastEnCeb = OrtSession.fromBuffer(decPastEnBytes, OrtSessionOptions());

    // Load sentencepiece models via native bridge (Kotlin)
    await SpmBridge.loadSpm('assets/models/tl_en/source.spm', 'tl_en_src');
    await SpmBridge.loadSpm('assets/models/tl_en/target.spm', 'tl_en_tgt');
    await SpmBridge.loadSpm('assets/models/en_ceb/source.spm', 'en_ceb_src');
    await SpmBridge.loadSpm('assets/models/en_ceb/target.spm', 'en_ceb_tgt');

    // Print input/output names to help debug if your ONNX uses different names
    print('tl_en encoder inputs: ${_encoderTlEn!.inputNames}, outputs: ${_encoderTlEn!.outputNames}');
    print('tl_en decoder inputs: ${_decoderTlEn!.inputNames}, outputs: ${_decoderTlEn!.outputNames}');
    print(
        'tl_en decoder_with_past inputs: ${_decoderWithPastTlEn!.inputNames}, outputs: ${_decoderWithPastTlEn!.outputNames}');

    print('en_ceb encoder inputs: ${_encoderEnCeb!.inputNames}, outputs: ${_encoderEnCeb!.outputNames}');
    print('en_ceb decoder inputs: ${_decoderEnCeb!.inputNames}, outputs: ${_decoderEnCeb!.outputNames}');
    print(
        'en_ceb decoder_with_past inputs: ${_decoderWithPastEnCeb!.inputNames}, outputs: ${_decoderWithPastEnCeb!.outputNames}');
  }

  void _ensureLoaded() {
    if (_encoderTlEn == null ||
        _decoderTlEn == null ||
        _decoderWithPastTlEn == null ||
        _encoderEnCeb == null ||
        _decoderEnCeb == null ||
        _decoderWithPastEnCeb == null) {
      throw Exception('Models are not loaded. Call loadAllModels() first.');
    }
  }

  /// Tagalog -> Cebuano: tl_en (tl->en) then en_ceb (en->ceb)
  Future<String> translateTlToCeb(String tagalogText, {int maxNewTokens = 60}) async {
    _ensureLoaded();

    final en = await _runEncoderDecoder(
      tagalogText,
      encoder: _encoderTlEn!,
      decoder: _decoderTlEn!,
      decoderWithPast: _decoderWithPastTlEn!,
      tokenizerSrc: 'tl_en_src',
      tokenizerTgt: 'tl_en_tgt',
      maxNewTokens: maxNewTokens,
    );

    final ceb = await _runEncoderDecoder(
      en,
      encoder: _encoderEnCeb!,
      decoder: _decoderEnCeb!,
      decoderWithPast: _decoderWithPastEnCeb!,
      tokenizerSrc: 'en_ceb_src',
      tokenizerTgt: 'en_ceb_tgt',
      maxNewTokens: maxNewTokens,
    );

    return ceb;
  }

  /// Cebuano -> Tagalog: en_ceb (ceb->en) then tl_en (en->tl)
  Future<String> translateCebToTl(String cebText, {int maxNewTokens = 60}) async {
    _ensureLoaded();

    final en = await _runEncoderDecoder(
      cebText,
      encoder: _encoderEnCeb!,
      decoder: _decoderEnCeb!,
      decoderWithPast: _decoderWithPastEnCeb!,
      tokenizerSrc: 'en_ceb_src',
      tokenizerTgt: 'en_ceb_tgt',
      maxNewTokens: maxNewTokens,
    );

    final tl = await _runEncoderDecoder(
      en,
      encoder: _encoderTlEn!,
      decoder: _decoderTlEn!,
      decoderWithPast: _decoderWithPastTlEn!,
      tokenizerSrc: 'tl_en_src',
      tokenizerTgt: 'tl_en_tgt',
      maxNewTokens: maxNewTokens,
    );

    return tl;
  }

  /// Core encoder->decoder_with_past greedy generation implementation.
  Future<String> _runEncoderDecoder(
    String text, {
    required OrtSession encoder,
    required OrtSession decoder,
    required OrtSession decoderWithPast,
    required String tokenizerSrc,
    required String tokenizerTgt,
    int maxNewTokens = 40,
  }) async {
    // 1) Tokenize source
    final List<int> srcIds = await SpmBridge.tokenize(tokenizerSrc, text);
    if (srcIds.isEmpty) return '';

    final int seqLen = srcIds.length;
    final List<int> attentionMask = List<int>.filled(seqLen, 1);

    // Create input tensors for encoder
    final OrtValue idsTensor = OrtValueTensor.createTensorWithDataList(srcIds, <int>[1, seqLen]);
    final OrtValue maskTensor = OrtValueTensor.createTensorWithDataList(attentionMask, <int>[1, seqLen]);

    // Build encoder input map
    final Map<String, OrtValue> encInputs = <String, OrtValue>{};
    if (encoder.inputNames.isEmpty) {
      idsTensor.release();
      maskTensor.release();
      throw Exception('Encoder input names not found. Inspect the model export.');
    }
    encInputs[encoder.inputNames[0]] = idsTensor;
    if (encoder.inputNames.length > 1) encInputs[encoder.inputNames[1]] = maskTensor;

    // Run encoder
    final OrtRunOptions encRunOpts = OrtRunOptions();
    final List<OrtValue?>? encOutputs = await encoder.runAsync(encRunOpts, encInputs);
    encRunOpts.release();

    if (encOutputs == null || encOutputs.isEmpty || encOutputs[0] == null) {
      // cleanup
      idsTensor.release();
      maskTensor.release();
      throw Exception('Encoder returned no outputs.');
    }

    // Keep encoder hidden states (first output)
    final OrtValue encoderHidden = encOutputs[0]!;

    // Release encoder input ids (we can release the tensor now)
    try {
      idsTensor.release();
    } catch (_) {}

    // release any other encoder outputs (if any) except the kept encoderHidden
    for (int i = 1; i < encOutputs.length; i++) {
      try {
        encOutputs[i]?.release();
      } catch (_) {}
    }

    // Get BOS/EOS ids via target tokenizer
    final List<int> bosList = await SpmBridge.tokenize(tokenizerTgt, "<s>");
    final List<int> eosList = await SpmBridge.tokenize(tokenizerTgt, "</s>");
    final int bosId = (bosList.isNotEmpty) ? bosList[0] : 0;
    final int eosId = (eosList.isNotEmpty) ? eosList[0] : 1;

    // ---------- First decoder pass (no past) ----------
    if (decoder.inputNames.isEmpty) {
      // cleanup
      try { encoderHidden.release(); } catch (_) {}
      try { maskTensor.release(); } catch (_) {}
      throw Exception('Decoder input names not found.');
    }

    final OrtValue curTokenTensor = OrtValueTensor.createTensorWithDataList([bosId], <int>[1, 1]);

    // Build decoder input map
    final Map<String, OrtValue> decInputs = <String, OrtValue>{};
    decInputs[decoder.inputNames[0]] = curTokenTensor;
    if (decoder.inputNames.length > 1) decInputs[decoder.inputNames[1]] = encoderHidden;
    // if decoder expects encoder_attention_mask as third input, create a temporary mask tensor for it
    OrtValue? tmpDecMask;
    if (decoder.inputNames.length > 2) {
      tmpDecMask = OrtValueTensor.createTensorWithDataList(attentionMask, <int>[1, seqLen]);
      decInputs[decoder.inputNames[2]] = tmpDecMask;
    }

    final OrtRunOptions decRunOpts = OrtRunOptions();
    final List<OrtValue?>? decOutputs = await decoder.runAsync(decRunOpts, decInputs);
    decRunOpts.release();

    // release temporary inputs we created
    try { curTokenTensor.release(); } catch (_) {}
    if (tmpDecMask != null) try { tmpDecMask.release(); } catch (_) {}

    if (decOutputs == null || decOutputs.isEmpty || decOutputs[0] == null) {
      try { encoderHidden.release(); } catch (_) {}
      try { maskTensor.release(); } catch (_) {}
      throw Exception('Decoder (first pass) returned no logits.');
    }

    // logits and present/past
    OrtValue logits = decOutputs[0]!;
    OrtValue? past = (decOutputs.length > 1) ? decOutputs[1] : null;

    // compute next id
    final int nextId = _argmaxFromLogits(logits.value);
    try { logits.release(); } catch (_) {}

    if (past == null) {
      try { encoderHidden.release(); } catch (_) {}
      try { maskTensor.release(); } catch (_) {}
      throw Exception('Decoder did not return present/past tensors; cannot continue.');
    }

    final List<int> outputIds = <int>[nextId];

    // ---------- Iterative decoding with decoder_with_past ----------
    OrtValue currentPast = past;
    for (int step = 0; step < maxNewTokens; step++) {
      final int lastToken = outputIds.last;
      if (lastToken == eosId) break;

      final OrtValue inputTokenTensor =
          OrtValueTensor.createTensorWithDataList([lastToken], <int>[1, 1]);

      final Map<String, OrtValue> stepInputs = <String, OrtValue>{};
      if (decoderWithPast.inputNames.isEmpty) {
        inputTokenTensor.release();
        try { currentPast.release(); } catch (_) {}
        try { encoderHidden.release(); } catch (_) {}
        try { maskTensor.release(); } catch (_) {}
        throw Exception('decoder_with_past input names empty.');
      }

      stepInputs[decoderWithPast.inputNames[0]] = inputTokenTensor;
      if (decoderWithPast.inputNames.length > 1) stepInputs[decoderWithPast.inputNames[1]] = encoderHidden;
      if (decoderWithPast.inputNames.length > 2) stepInputs[decoderWithPast.inputNames[2]] = maskTensor;

      // past slot (index 3 or a name containing 'past'/'present')
      if (decoderWithPast.inputNames.length > 3) {
        stepInputs[decoderWithPast.inputNames[3]] = currentPast;
      } else {
        final foundPastName = decoderWithPast.inputNames
            .firstWhere((n) => n.toLowerCase().contains('past') || n.toLowerCase().contains('present'),
                orElse: () => '');
        if (foundPastName.isNotEmpty) {
          stepInputs[foundPastName] = currentPast;
        } else {
          inputTokenTensor.release();
          try { currentPast.release(); } catch (_) {}
          try { encoderHidden.release(); } catch (_) {}
          try { maskTensor.release(); } catch (_) {}
          throw Exception('decoder_with_past has no recognizable past input name.');
        }
      }

      final OrtRunOptions stepRunOpts = OrtRunOptions();
      final List<OrtValue?>? stepOutputs = await decoderWithPast.runAsync(stepRunOpts, stepInputs);
      stepRunOpts.release();

      inputTokenTensor.release();

      if (stepOutputs == null || stepOutputs.isEmpty || stepOutputs[0] == null) {
          try { currentPast.release(); } catch (_) {}
          try { encoderHidden.release(); } catch (_) {}
          try { maskTensor.release(); } catch (_) {}
          throw Exception('decoder_with_past step returned no outputs.');
      }

      // logits are always the first output
      logits = stepOutputs[0]!;

      // compute next token
      final int nextStepId = _argmaxFromLogits(logits.value);
      outputIds.add(nextStepId);

      // release logits
      try { logits.release(); } catch (_) {}


      // update past for next step (usually the second output)
      if (stepOutputs.length > 1 && stepOutputs[1] != null) {
          final OrtValue newPast = stepOutputs[1]!;
          try { currentPast.release(); } catch (_) {}
          currentPast = newPast;
      } else {
          try { currentPast.release(); } catch (_) {}
          break; // if no past returned, stop decoding
      }

      // stop if EOS
      if (nextStepId == eosId) break;

      // release any other extra outputs
      for (int i = 2; i < stepOutputs.length; i++) {
          try { stepOutputs[i]?.release(); } catch (_) {}
      }
    }

    // cleanup
    // detokenize
    final String decoded = await SpmBridge.detokenize(tokenizerTgt, outputIds);
    try { currentPast.release(); } catch (_) {}
    try { encoderHidden.release(); } catch (_) {}
    try { maskTensor.release(); } catch (_) {}
    return decoded;

  }

  /// Argmax helper for typical nested list logits shapes
  int _argmaxFromLogits(dynamic logitsValue) {
    final List<double> logits = List<double>.from(logitsValue as Iterable);
    double maxVal = logits[0];
    int maxIdx = 0;
    for (int i = 1; i < logits.length; i++) {
      if (logits[i] > maxVal) {
        maxVal = logits[i];
        maxIdx = i;
      }
    }
    return maxIdx;
  }


  /// Release all sessions
  void dispose() {
    try { _encoderTlEn?.release(); } catch (_) {}
    try { _decoderTlEn?.release(); } catch (_) {}
    try { _decoderWithPastTlEn?.release(); } catch (_) {}
    try { _encoderEnCeb?.release(); } catch (_) {}
    try { _decoderEnCeb?.release(); } catch (_) {}
    try { _decoderWithPastEnCeb?.release(); } catch (_) {}

    _encoderTlEn = null;
    _decoderTlEn = null;
    _decoderWithPastTlEn = null;
    _encoderEnCeb = null;
    _decoderEnCeb = null;
    _decoderWithPastEnCeb = null;
  }
}
