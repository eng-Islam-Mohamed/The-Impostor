package com.baraalsalfa.bara_alsalfa

import android.media.AudioManager
import android.media.ToneGenerator
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "bara_alsalfa/audio"
    private var soundEnabled = true
    private val handler = Handler(Looper.getMainLooper())
    private val toneGenerator by lazy { ToneGenerator(AudioManager.STREAM_MUSIC, 45) }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setEnabled" -> {
                        soundEnabled = call.argument<Boolean>("enabled") ?: true
                        result.success(null)
                    }

                    "playSoftTap" -> {
                        playPattern(
                            ToneStep(ToneGenerator.TONE_PROP_BEEP2, 28, 0),
                        )
                        result.success(null)
                    }

                    "playVoteConfirm" -> {
                        playPattern(
                            ToneStep(ToneGenerator.TONE_PROP_BEEP2, 32, 0),
                            ToneStep(ToneGenerator.TONE_PROP_ACK, 58, 55),
                        )
                        result.success(null)
                    }

                    "playSuspenseReveal" -> {
                        playPattern(
                            ToneStep(ToneGenerator.TONE_CDMA_LOW_PBX_SLS, 120, 0),
                            ToneStep(ToneGenerator.TONE_CDMA_ALERT_CALL_GUARD, 140, 135),
                            ToneStep(ToneGenerator.TONE_PROP_ACK, 90, 305),
                        )
                        result.success(null)
                    }

                    "playCorrectGuess" -> {
                        playPattern(
                            ToneStep(ToneGenerator.TONE_PROP_BEEP2, 35, 0),
                            ToneStep(ToneGenerator.TONE_PROP_BEEP, 55, 60),
                            ToneStep(ToneGenerator.TONE_PROP_ACK, 85, 140),
                        )
                        result.success(null)
                    }

                    "playWrongGuess" -> {
                        playPattern(
                            ToneStep(ToneGenerator.TONE_PROP_NACK, 90, 0),
                            ToneStep(ToneGenerator.TONE_CDMA_SOFT_ERROR_LITE, 120, 105),
                        )
                        result.success(null)
                    }

                    else -> result.notImplemented()
                }
            }
    }

    override fun onDestroy() {
        toneGenerator.release()
        super.onDestroy()
    }

    private fun playTone(tone: Int, durationMs: Int) {
        if (!soundEnabled) {
            return
        }
        toneGenerator.startTone(tone, durationMs)
    }

    private fun playPattern(vararg steps: ToneStep) {
        if (!soundEnabled) {
            return
        }
        steps.forEach { step ->
            handler.postDelayed(
                { playTone(step.tone, step.durationMs) },
                step.delayMs.toLong(),
            )
        }
    }
}

private data class ToneStep(
    val tone: Int,
    val durationMs: Int,
    val delayMs: Int,
)
