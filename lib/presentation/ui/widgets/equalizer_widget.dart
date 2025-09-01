import 'package:flutter/material.dart';
import 'package:music_player/data/services/equalizer_service.dart';
import 'package:hive/hive.dart';

class EqualizerWidget extends StatefulWidget {
  const EqualizerWidget({super.key});

  @override
  State<EqualizerWidget> createState() => _EqualizerWidgetState();
}

class _EqualizerWidgetState extends State<EqualizerWidget> {
  bool isEnabled = false;
  int bandCount = 5;
  int minLevel = -1500;
  int maxLevel = 1500;
  List<int> bandLevels = [0, 0, 0, 0, 0];
  int bassBoost = 0;

  List<String> presets = ['Normal', 'Classical', 'Dance', 'Flat', 'Custom'];
  String selectedPreset = 'Normal';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // Load saved settings from Hive
    var box = await Hive.openBox('equalizerBox');
    isEnabled = box.get('enabled', defaultValue: false);
    selectedPreset = box.get('preset', defaultValue: 'Normal');
    bandLevels = List<int>.from(box.get('bands', defaultValue: [0, 0, 0, 0, 0]));
    bassBoost = box.get('bass', defaultValue: 0);

    // Apply to native
    await EqualizerService.setEnabled(isEnabled);
    for (int i = 0; i < bandCount; i++) {
      await EqualizerService.setBandLevel(i, bandLevels[i]);
    }
    await EqualizerService.setBassBoost(bassBoost);

    setState(() {});
  }

  void _saveSettings() async {
    var box = await Hive.openBox('equalizerBox');
    await box.put('enabled', isEnabled);
    await box.put('preset', selectedPreset);
    await box.put('bands', bandLevels);
    await box.put('bass', bassBoost);
  }

  void _applyPreset(String preset) async {
    if (!isEnabled) return;
    List<List<int>> presetBands = [
      [0, 0, 0, 0, 0], // Normal
      [500, 0, -500, 300, 0], // Classical
      [1000, 500, 0, 500, 1000], // Dance
      [0, 0, 0, 0, 0], // Flat
    ];
    if (preset == 'Custom') return; // do not override custom

    int index = presets.indexOf(preset);
    if (index < presetBands.length) {
      bandLevels = List<int>.from(presetBands[index]);
      for (int i = 0; i < bandCount; i++) {
        await EqualizerService.setBandLevel(i, bandLevels[i]);
      }
      selectedPreset = preset;
      _saveSettings();
      setState(() {});
    }
  }

  void _onSliderChange(int index, double value) async {
    if (!isEnabled) return;
    bandLevels[index] = value.toInt();
    selectedPreset = 'Custom';
    await EqualizerService.setBandLevel(index, bandLevels[index]);
    _saveSettings();
    setState(() {});
  }

  void _onBassChange(double value) async {
    if (!isEnabled) return;
    bassBoost = value.toInt();
    await EqualizerService.setBassBoost(bassBoost);
    selectedPreset = 'Custom';
    _saveSettings();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Enable switch
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Equalizer", style: TextStyle(color: Colors.white, fontSize: 18)),
              Switch(
                value: isEnabled,
                onChanged: (v) async {
                  isEnabled = v;
                  await EqualizerService.setEnabled(isEnabled);
                  _saveSettings();
                  setState(() {});
                },
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Presets
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: presets.map((p) {
                bool selected = p == selectedPreset;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selected ? Colors.orange : Colors.grey[800],
                    ),
                    onPressed: isEnabled ? () => _applyPreset(p) : null,
                    child: Text(p),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Sliders for bands
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(bandCount, (i) {
              return Column(
                children: [
                  RotatedBox(
                    quarterTurns: -1,
                    child: Slider(
                      value: bandLevels[i].toDouble(),
                      min: minLevel.toDouble(),
                      max: maxLevel.toDouble(),
                      onChanged: isEnabled ? (v) => _onSliderChange(i, v) : null,
                      activeColor: Colors.orange,
                      inactiveColor: Colors.white24,
                    ),
                  ),
                  Text("B${i + 1}", style: const TextStyle(color: Colors.white70)),
                ],
              );
            }),
          ),

          const SizedBox(height: 8),

          // Bass boost
          Column(
            children: [
              const Text("Bass Boost", style: TextStyle(color: Colors.white70)),
              Slider(
                value: bassBoost.toDouble(),
                min: 0,
                max: 1000,
                onChanged: isEnabled ? _onBassChange : null,
                activeColor: Colors.orange,
                inactiveColor: Colors.white24,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
