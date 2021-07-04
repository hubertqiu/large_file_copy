package com.example.largefilecopy

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
 
import java.io.File
import java.io.InputStream
import io.flutter.util.PathUtils

class LargeFileCopyPlugin: MethodCallHandler {

  private final val mRegistrar: Registrar

  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "ch.ideenkaffee.largefilecopy")
      channel.setMethodCallHandler(LargeFileCopyPlugin(registrar))
    }
  }

  constructor(registrar : Registrar) {
    this.mRegistrar = registrar
  }

  override fun onMethodCall(call: MethodCall, result: Result) {

    // flutter cmds dispatched on Android device :
    when (call.method) {
      "copyLargeFile" -> {
        val args = call.arguments as Map<String, Any>
        val sourceFilePath = args["sourceFilePath"] as String?
        val distFilePath = args["distFilePath"] as String?
        if (sourceFilePath != null && distFilePath != null) {
          result.success(copyFileIfNeeded(sourceFilePath, distFilePath))
        } else {
          result.success(false)
        } 
      }
      "getPlatformVersion" -> result.success("Running on Android: ${android.os.Build.VERSION.RELEASE}")
      else -> result.success("Android calling method not recognized")
    }
  }

  private fun copyFileIfNeeded(sourceFilePath: String, distFilePath: String): Boolean {
    val appliationDocumentsFolderPath: String = PathUtils.getDataDirectory(mRegistrar.context())
    val outputFilePath: String = distFilePath
    val outputFile = File(outputFilePath)
    val outputFileDirectory = File(outputFile.getParentFile().getName())
    if(!outputFileDirectory.isDirectory()){
      outputFileDirectory.mkdirs()
    }
    if (outputFile.exists()) {
      return true;
    }
    val assetStream: InputStream = mRegistrar.context().assets.open(sourceFilePath)
    outputFile.copyInputStreamToFile(assetStream)   
    return true;
  }

  private fun File.copyInputStreamToFile(inputStream: InputStream) {
    inputStream.use { input ->
        this.outputStream().use { fileOut ->
            input.copyTo(fileOut)
        }
    }
  }
}
