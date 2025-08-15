package com.example.a_project

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import ai.djl.sentencepiece.SentencePieceProcessor
import java.io.File
import java.io.FileOutputStream

class MainActivity: FlutterActivity() {
  private val CHANNEL = "app.translator.tokenizer"

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
      when (call.method) {
        "loadSpm" -> {
          val assetPath = call.argument<String>("assetPath")!! // e.g. "assets/models/tl_en/source.spm"
          val modelId = call.argument<String>("modelId")!! // e.g. "tl_en"
          try {
            val sp = loadSpmAsset(assetPath, modelId)
            // store in memory map if you want; for now return success
            result.success(true)
          } catch (e: Exception) {
            result.error("LOAD_ERROR", e.message, null)
          }
        }
        "tokenize" -> {
          val modelId = call.argument<String>("modelId")!!
          val text = call.argument<String>("text")!!
          try {
            val ids = tokenizeWithSpm(modelId, text)
            result.success(ids)
          } catch (e: Exception) {
            result.error("TOKENIZE_ERROR", e.message, null)
          }
        }
        "detokenize" -> {
          val modelId = call.argument<String>("modelId")!!
          val ids = call.argument<List<Int>>("ids")!!
          try {
            val txt = detokenizeWithSpm(modelId, ids)
            result.success(txt)
          } catch (e: Exception) {
            result.error("DETOKENIZE_ERROR", e.message, null)
          }
        }
        else -> result.notImplemented()
      }
    }
  }

  // We'll keep a simple in-memory map of processors keyed by modelId
  private val processors = HashMap<String, SentencePieceProcessor>()

  private fun loadSpmAsset(assetPath: String, modelId: String): Boolean {
    // Copy asset to files dir and load with SentencePieceProcessor
    val inputStream = assets.open(assetPath.removePrefix("assets/"))
    val outFile = File(filesDir, "$modelId.spm")
    FileOutputStream(outFile).use { fos ->
      inputStream.copyTo(fos)
    }
    val sp = SentencePieceProcessor()
    sp.load(outFile.absolutePath)
    processors[modelId] = sp
    return true
  }

  private fun tokenizeWithSpm(modelId: String, text: String): List<Int> {
    val sp = processors[modelId] ?: throw Exception("SPM not loaded for $modelId")
    val ids = sp.encodeAsIds(text)
    // Convert to List<Int>
    return ids.toList()
  }

  private fun detokenizeWithSpm(modelId: String, ids: List<Int>): String {
    val sp = processors[modelId] ?: throw Exception("SPM not loaded for $modelId")
    val arr = ids.toIntArray()
    return sp.decodeIds(arr)
  }
}
