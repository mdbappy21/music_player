package com.example.music_player;

import android.media.audiofx.Equalizer;
import android.os.Bundle;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private Equalizer equalizer;
    private static final String CHANNEL = "music_player_equalizer";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        // Initialize equalizer on global audio session 0
        equalizer = new Equalizer(0, 0);
        equalizer.setEnabled(true);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL).setMethodCallHandler(
                (call, result) -> {
                    switch (call.method) {
                        case "getBandCount":
                            result.success(equalizer.getNumberOfBands());
                            break;
                        case "getBandLevelRange":
                            short[] range = equalizer.getBandLevelRange();
                            result.success(new int[]{range[0], range[1]});
                            break;
                        case "getBandLevels":
                            int bandCount = equalizer.getNumberOfBands();
                            int[] levels = new int[bandCount];
                            for (short i = 0; i < bandCount; i++) {
                                levels[i] = equalizer.getBandLevel(i);
                            }
                            result.success(levels);
                            break;
                        case "setBandLevel":
                            int band = call.argument("band");
                            int level = call.argument("level");
                            equalizer.setBandLevel((short) band, (short) level);
                            result.success(null);
                            break;
                        case "setEnabled":
                            boolean enabled = call.argument("enabled");
                            equalizer.setEnabled(enabled);
                            result.success(null);
                            break;
                        default:
                            result.notImplemented();
                    }
                }
        );
    }
}
