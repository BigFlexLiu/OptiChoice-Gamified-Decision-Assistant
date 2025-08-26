package dev.vfile.decision_spin

import android.os.Bundle
import android.util.Log
import android.content.pm.ApplicationInfo
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.android.installreferrer.api.InstallReferrerClient
import com.android.installreferrer.api.InstallReferrerStateListener
import com.android.installreferrer.api.ReferrerDetails
import java.util.concurrent.atomic.AtomicBoolean

class MainActivity : FlutterActivity() {
    private val CHANNEL = "install_referrer"
    private val TAG = "InstallReferrerNative"
    private val verbose by lazy { (applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0 }
    private var referrerClient: InstallReferrerClient? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        WindowCompat.setDecorFitsSystemWindows(window, false)
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getInstallReferrer" -> {
                        if (verbose) Log.d(TAG, "MethodChannel call: getInstallReferrer")
                        getInstallReferrer(result)
                    }
                    else -> {
                        if (verbose) Log.w(TAG, "MethodChannel call not implemented: ${call.method}")
                        result.notImplemented()
                    }
                }
            }
    }

    private fun getInstallReferrer(result: MethodChannel.Result) {
        val replied = AtomicBoolean(false)
        fun replySuccess(map: Map<String, Any?>) {
            if (replied.compareAndSet(false, true)) {
                if (verbose) Log.d(TAG, "Install referrer success (keys=${map.keys})")
                runOnUiThread { result.success(map) }
            }
        }
        fun replyEmpty() = replySuccess(emptyMap()) // lets Dart mark “processed”
        fun replyError(code: String, msg: String) {
            if (replied.compareAndSet(false, true)) {
                Log.w(TAG, "Install referrer error code=$code msg=$msg")
                runOnUiThread { result.error(code, msg, null) }
            }
        }

        try {
            if (verbose) Log.d(TAG, "Starting InstallReferrer connection")
            referrerClient = InstallReferrerClient.newBuilder(applicationContext).build()
            referrerClient?.startConnection(object : InstallReferrerStateListener {
                override fun onInstallReferrerSetupFinished(responseCode: Int) {
                    if (verbose) Log.d(TAG, "InstallReferrer setupFinished code=$responseCode")
                    try {
                        when (responseCode) {
                            InstallReferrerClient.InstallReferrerResponse.OK -> {
                                try {
                                    val resp: ReferrerDetails = referrerClient!!.installReferrer
                                    Log.i(TAG, "Install referrer obtained (len=${resp.installReferrer?.length ?: 0})")
                                    val map = mapOf(
                                        "installReferrer" to (resp.installReferrer ?: ""),
                                        // NOTE: seconds, not millis
                                        "referrerClickTimestamp" to resp.referrerClickTimestampSeconds,
                                        "installBeginTimestamp" to resp.installBeginTimestampSeconds,
                                        "googlePlayInstant" to resp.googlePlayInstantParam
                                    )
                                    replySuccess(map)
                                } catch (e: Exception) {
                                    Log.e(TAG, "Exception reading ReferrerDetails: ${e.message}", e)
                                    replyEmpty()
                                }
                            }
                            InstallReferrerClient.InstallReferrerResponse.FEATURE_NOT_SUPPORTED -> {
                                // Treat as empty so the app stops retrying
                                if (verbose) Log.w(TAG, "FEATURE_NOT_SUPPORTED")
                                replyEmpty()
                            }
                            InstallReferrerClient.InstallReferrerResponse.SERVICE_UNAVAILABLE -> {
                                // Transient — surface as error; Dart may choose to retry next launch
                                Log.w(TAG, "SERVICE_UNAVAILABLE")
                                replyError("SERVICE_UNAVAILABLE", "Install Referrer service unavailable")
                            }
                            else -> {
                                // Unknown code — treat as empty
                                if (verbose) Log.w(TAG, "Unknown response code=$responseCode (treat empty)")
                                replyEmpty()
                            }
                        }
                    } catch (e: Exception) {
                        // Unexpected exception — return empty map rather than error to avoid infinite retries
                        Log.e(TAG, "Unexpected exception in setupFinished: ${e.message}", e)
                        replyEmpty()
                    } finally {
                        try { referrerClient?.endConnection() } catch (_: Exception) {}
                        referrerClient = null
                        if (verbose) Log.d(TAG, "InstallReferrer connection ended")
                    }
                }

                override fun onInstallReferrerServiceDisconnected() {
                    // Don’t call result.* here; optional: you could retry once if not replied.
                    if (verbose) Log.d(TAG, "InstallReferrer service disconnected")
                }
            })
        } catch (e: Exception) {
            Log.e(TAG, "InstallReferrer start exception: ${e.message}", e)
            replyError("CONNECTION_ERROR", "Error connecting to Install Referrer service: ${e.message}")
            try { referrerClient?.endConnection() } catch (_: Exception) {}
            referrerClient = null
        }
    }

    override fun onDestroy() {
        super.onDestroy()
    try { referrerClient?.endConnection() } catch (_: Exception) {}
        referrerClient = null
    }
}
