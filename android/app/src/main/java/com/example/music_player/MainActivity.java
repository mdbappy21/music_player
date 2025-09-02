package com.example.music_player;

import android.media.audiofx.Equalizer;
import android.media.audiofx.BassBoost;

import androidx.annotation.NonNull;

import com.ryanheise.audioservice.AudioServiceActivity; // <-- important

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends AudioServiceActivity { // <-- important
    private static final String CHANNEL = "music_player_equalizer";

    private Equalizer equalizer;
    private BassBoost bassBoost;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler((call, result) -> {
                    switch (call.method) {
                        case "initEqualizer": {
                            Integer sessionId = call.argument("sessionId");
                            if (sessionId != null) {
                                initEqualizer(sessionId);
                            }
                            result.success(null);
                            break;
                        }
                        case "setEnabled": {
                            Boolean enabled = call.argument("enabled");
                            if (enabled != null) {
                                if (equalizer != null) equalizer.setEnabled(enabled);
                                if (bassBoost != null) bassBoost.setEnabled(enabled);
                            }
                            result.success(null);
                            break;
                        }
                        case "setBandLevel": {
                            Integer band = call.argument("band");
                            Integer level = call.argument("level");
                            if (band != null && level != null && equalizer != null) {
                                equalizer.setBandLevel((short)(int)band, (short)(int)level);
                            }
                            result.success(null);
                            break;
                        }
                        case "setBassBoost": {
                            Integer value = call.argument("value");
                            if (value != null && bassBoost != null) {
                                bassBoost.setStrength((short)(int)value); // 0..1000
                            }
                            result.success(null);
                            break;
                        }
                        default:
                            result.notImplemented();
                    }
                });
    }

    private void initEqualizer(int audioSessionId) {
        if (equalizer != null) {
            equalizer.release();
            equalizer = null;
        }
        if (bassBoost != null) {
            bassBoost.release();
            bassBoost = null;
        }

        equalizer = new Equalizer(0, audioSessionId);
        equalizer.setEnabled(true);

        bassBoost = new BassBoost(0, audioSessionId);
        bassBoost.setEnabled(true);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (equalizer != null) {
            equalizer.release();
            equalizer = null;
        }
        if (bassBoost != null) {
            bassBoost.release();
            bassBoost = null;
        }
    }
}
