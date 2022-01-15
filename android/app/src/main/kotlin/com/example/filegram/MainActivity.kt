package com.sks.filegram

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.util.Base64
import java.io.FileInputStream
import java.io.FileOutputStream
import javax.crypto.Cipher
import javax.crypto.CipherInputStream
import javax.crypto.CipherOutputStream
import javax.crypto.KeyGenerator
import javax.crypto.spec.IvParameterSpec
import javax.crypto.spec.SecretKeySpec
import java.security.SecureRandom
import kotlinx.coroutines.*
import kotlin.coroutines.*


class MainActivity: FlutterActivity() {
    
    private val algorithm = "AES"
    private val transformation = "AES/CBC/PKCS5Padding"
    private val CHANNEL = "file_encrypter"
    private val mainScope = CoroutineScope(Dispatchers.Main) 
   
override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
      // Note: this method is invoked on the main thread.
      call, result ->
      when (call.method) {
                "encrypt" -> { 
                    mainScope.launch {
                      withContext(Dispatchers.Default) {
                    encrypt(call.argument("key"),call.argument("iv"),call.argument("inFileName"), call.argument("outFileName"),result)
                     }
                      }
                            }
                "decrypt" -> {
                     mainScope.launch {
                             withContext(Dispatchers.Default) {
                decrypt(call.argument("key"), call.argument("inFileName"), call.argument("outFileName"),result)
                             }
                     }
                }

                "getfileiv" -> {
                     mainScope.launch {
                 getfileiv(call.argument("inFileName"),result)
                    }
                }

                "generatekey" -> {
                     mainScope.launch {
                    generatekey(result)
                }
                 }
                
                "generateiv" -> {
                    mainScope.launch {
                    generateiv(result)
                    }
                }

                else ->{
                    result.notImplemented()
                }
            }
    }
  }

  

    private suspend fun successResult(data: String?,result: MethodChannel.Result ) {
        
            result.success(data)
        
    }

    private suspend fun errorResult(message: String?,result: MethodChannel.Result) {
       
            result.error("", message, message)
      
    }

    private suspend fun encrypt(key: String?,iv: String?,inFileName: String?, outFileName: String? ,result: MethodChannel.Result) {
        val cipher = Cipher.getInstance(transformation)
         val encodedKey = Base64.decode(key, Base64.DEFAULT)
        val secretKey = SecretKeySpec(encodedKey, 0, encodedKey.size, algorithm)
        val fileIv = Base64.decode(iv, Base64.DEFAULT)
        try {
            FileOutputStream(outFileName!!).use { fileOut ->
                cipher.init(Cipher.ENCRYPT_MODE, secretKey ,IvParameterSpec(fileIv))
                CipherOutputStream(fileOut, cipher).use { cipherOut ->
                    fileOut.write(cipher.iv)
                    val buffer = ByteArray(8192)
                    FileInputStream(inFileName!!).use { fileIn ->
                        var byteCount = fileIn.read(buffer)
                        while (byteCount != -1) {
                            cipherOut.write(buffer, 0, byteCount)
                            byteCount = fileIn.read(buffer)
                        }
                    }
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
            errorResult(e.message,result )
            return
        }

       result.success(true)
    }

    private suspend fun decrypt(key: String?, inFileName: String?, outFileName: String?,result: MethodChannel.Result) {
        val cipher = Cipher.getInstance(transformation)
        val encodedKey = Base64.decode(key, Base64.DEFAULT)
        val secretKey = SecretKeySpec(encodedKey, 0, encodedKey.size, algorithm)

        try {
            FileInputStream(inFileName!!).use { fileIn ->
                val fileIv = ByteArray(16)
                fileIn.read(fileIv)
                cipher.init(Cipher.DECRYPT_MODE, secretKey, IvParameterSpec(fileIv))
                CipherInputStream(fileIn, cipher).use { cipherIn ->
                    val buffer = ByteArray(8192)
                    FileOutputStream(outFileName!!).use { fileOut ->
                        var byteCount = cipherIn.read(buffer)
                        while (byteCount != -1) {
                            fileOut.write(buffer, 0, byteCount)
                            byteCount = cipherIn.read(buffer)
                        }
                    }
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
            errorResult(e.message,result)
            return
        }
        result.success(true)
    }

      private suspend fun getfileiv(inFileName: String?,result:MethodChannel.Result){
         val fileIv = ByteArray(16)
        try{
             FileInputStream(inFileName!!).use { fileIn ->
               
                fileIn.read(fileIv)
             }

        } catch (e: Exception) {
            e.printStackTrace()
            errorResult(e.message,result)
            return
        }
        
        val fileivString = Base64.encodeToString(fileIv, Base64.DEFAULT)
        successResult(fileivString,result)
    }

    private suspend fun generatekey(result: MethodChannel.Result) {
        val secretKey = KeyGenerator.getInstance("AES").generateKey()
        val keyString = Base64.encodeToString(secretKey.encoded, Base64.DEFAULT)
        successResult(keyString,result )
    }

     private suspend fun generateiv(result: MethodChannel.Result){
        val iv = ByteArray(16)
         SecureRandom().nextBytes(iv)
         val ivString = Base64.encodeToString(iv, Base64.DEFAULT)
         successResult(ivString,result)
    }
}
