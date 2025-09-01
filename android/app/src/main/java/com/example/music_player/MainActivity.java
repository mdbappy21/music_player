package com.example.music_player;

import android.media.audiofx.Equalizer;
import android.media.audiofx.BassBoost;
import android.os.Bundle;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "music_player_equalizer";

    private Equalizer equalizer;
    private BassBoost bassBoost;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Attach MethodChannel
        new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            switch (call.method) {
                                case "setEnabled":
                                    boolean enabled = call.argument("enabled");
                                    if (equalizer != null) equalizer.setEnabled(enabled);
                                    if (bassBoost != null) bassBoost.setEnabled(enabled);
                                    result.success(null);
                                    break;

                                case "setBandLevel":
                                    int band = call.argument("band");
                                    int level = call.argument("level");
                                    if (equalizer != null) equalizer.setBandLevel((short) band, (short) level);
                                    result.success(null);
                                    break;

                                case "setBassBoost":
                                    int value = call.argument("value");
                                    if (bassBoost != null) bassBoost.setStrength((short) value);
                                    result.success(null);
                                    break;

                                default:
                                    result.notImplemented();
                                    break;
                            }
                        }
                );
    }

    // Call this whenever audio session is ready
    public void initEqualizer(int audioSessionId) {
        if (equalizer != null) equalizer.release();
        equalizer = new Equalizer(0, audioSessionId);
        equalizer.setEnabled(true);

        if (bassBoost != null) bassBoost.release();
        bassBoost = new BassBoost(0, audioSessionId);
        bassBoost.setEnabled(true);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (equalizer != null) equalizer.release();
        if (bassBoost != null) bassBoost.release();
    }
}
