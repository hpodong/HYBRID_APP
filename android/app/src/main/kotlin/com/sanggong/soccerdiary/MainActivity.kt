package com.hpodong.hybrid

import io.flutter.embedding.android.FlutterFragmentActivity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import android.provider.Settings
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.net.URISyntaxException

class MainActivity: FlutterActivity() {

    private val CHANNEL = "method_channel"
    private val TAG = "MainActivity"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        GeneratedPluginRegistrant.registerWith(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "openURL" -> {
                    val url: String = call.argument("url")!!

                    val success = startSchemeIntent(url)
                    if (success) {
                        result.success("App launched")
                    } else {
                        result.error("ERROR", "Failed to launch app", null)
                    }
                }
                "getPackage" -> {
                    val url: String = call.argument("url")!!

                    result.success(getPackageName(url))
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun getPackageName(url: String): String? {
        return try {
            val schemeIntent: Intent = Intent.parseUri(url, Intent.URI_INTENT_SCHEME) // Intent 스킴을 파싱
            schemeIntent.`package` // 패키지명 반환
        } catch (e: URISyntaxException) {
            null // 예외 발생 시 null 반환
        }
    }

    /*Intent 스킴을 처리하는 함수*/
    private fun startSchemeIntent(url: String): Boolean {

        val schemeIntent: Intent = try {
            Intent.parseUri(url, Intent.URI_INTENT_SCHEME) // Intent 스킴을 파싱
        } catch (e: URISyntaxException) {
            return false
        }

        Log.d(TAG, "Parsed Intent: $schemeIntent");

        return try {
            startActivity(schemeIntent) // 앱으로 이동
            true
        } catch (e: ActivityNotFoundException) { // 앱이 설치 안 되어 있는 경우
            val packageName = schemeIntent.`package`
            if (!packageName.isNullOrBlank()) {
                startActivity(
                    Intent(
                        Intent.ACTION_VIEW,
                        Uri.parse("market://details?id=$packageName") // 스토어로 이동
                    )
                )
                true
            } else {
                Log.d(TAG, "isNullOrBlank");
                false
            }
        } catch (e: Exception) {
            Log.d(TAG, e.toString())
            false
        }
    }
}
