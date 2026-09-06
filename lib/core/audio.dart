import 'package:audioplayers/audioplayers.dart';

// Authored narration replaces asset IDs without changing a screen. No microphone or TTS network access.
abstract class AudioService {
  Future<void> configure({
    required bool musicOn,
    required bool effectsOn,
    required bool voiceOn,
  });
  Future<void> reward();
  Future<void> narrate(String asset);
  Future<void> pause();
  void dispose();
}

class SilentAudio implements AudioService {
  @override
  Future<void> configure({
    required bool musicOn,
    required bool effectsOn,
    required bool voiceOn,
  }) async {}
  @override
  Future<void> reward() async {}
  @override
  Future<void> narrate(String asset) async {}
  @override
  Future<void> pause() async {}
  @override
  void dispose() {}
}

class AudioDirector implements AudioService {
  final _music = AudioPlayer();
  final _effects = AudioPlayer();
  final _voice = AudioPlayer();
  bool music = false, effects = true, voice = true;
  AudioDirector() {
    _voice.onPlayerComplete.listen((_) {
      if (music) _music.setVolume(.18);
    });
  }
  @override
  Future<void> configure({
    required bool musicOn,
    required bool effectsOn,
    required bool voiceOn,
  }) async {
    music = musicOn;
    effects = effectsOn;
    voice = voiceOn;
    if (!music) {
      await _music.stop();
    } else if (_music.state != PlayerState.playing) {
      await _music.setReleaseMode(ReleaseMode.loop);
      await _music.setVolume(.18);
      await _music.play(AssetSource('audio/room.wav'));
    }
    if (!effects) await _effects.stop();
    if (!voice) await _voice.stop();
  }

  @override
  Future<void> reward() async {
    if (effects) {
      await _effects.play(AssetSource('audio/reward.wav'), volume: .3);
    }
  }

  @override
  Future<void> narrate(String asset) async {
    if (!voice) return;
    await _music.setVolume(.04);
    try {
      await _voice.play(AssetSource(asset));
    } catch (_) {
      if (music) await _music.setVolume(.18);
    }
  }

  @override
  Future<void> pause() async {
    await _music.pause();
    await _voice.stop();
    await _effects.stop();
  }

  @override
  void dispose() {
    _music.dispose();
    _effects.dispose();
    _voice.dispose();
  }
}
