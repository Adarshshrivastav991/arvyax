import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class ArvyaxAudioHandler extends BaseAudioHandler with SeekHandler {
  AudioPlayer _audioPlayer = AudioPlayer();

  ArvyaxAudioHandler() {
    _listenToPlayer();
  }

  void _listenToPlayer() {
    _audioPlayer.playbackEventStream.listen((event) {
      _updatePlaybackState();
    });

    _audioPlayer.positionStream.listen((position) {
      _updatePlaybackState();
    });

    _audioPlayer.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _updatePlaybackState();
      }
    });
  }

  void _updatePlaybackState() {
    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.rewind,
          _audioPlayer.playing ? MediaControl.pause : MediaControl.play,
          MediaControl.fastForward,
          MediaControl.stop,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: _mapProcessingState(_audioPlayer.processingState),
        playing: _audioPlayer.playing,
        updatePosition: _audioPlayer.position,
        bufferedPosition: _audioPlayer.bufferedPosition,
        speed: _audioPlayer.speed,
      ),
    );
  }

  AudioProcessingState _mapProcessingState(ProcessingState state) {
    switch (state) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
        return AudioProcessingState.loading;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
    }
  }

  AudioPlayer get audioPlayer => _audioPlayer;

  Future<void> loadAudio(
    String assetPath,
    String title,
    String ambienceTag,
  ) async {
    try {
      // If the player was disposed, create a new one
      try {
        _audioPlayer.processingState;
      } catch (_) {
        _audioPlayer = AudioPlayer();
        _listenToPlayer();
      }

      await _audioPlayer.setAsset(assetPath);
      await _audioPlayer.setLoopMode(LoopMode.all);

      // Update media item for notification
      mediaItem.add(
        MediaItem(
          id: assetPath,
          title: title,
          artist: 'ArvyaX',
          album: ambienceTag,
          playable: true,
          duration: _audioPlayer.duration,
        ),
      );

      _updatePlaybackState();
    } catch (e) {
      playbackState.add(
        playbackState.value.copyWith(
          processingState: AudioProcessingState.error,
        ),
      );
    }
  }

  @override
  Future<void> play() async {
    await _audioPlayer.play();
  }

  @override
  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  @override
  Future<void> stop() async {
    await _audioPlayer.stop();
    // Clear playback state to dismiss notification
    playbackState.add(
      PlaybackState(
        controls: [],
        processingState: AudioProcessingState.idle,
        playing: false,
      ),
    );
    // Clear media item
    mediaItem.add(null);
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  @override
  Future<void> fastForward() async {
    final newPosition = _audioPlayer.position + const Duration(seconds: 10);
    await _audioPlayer.seek(newPosition);
  }

  @override
  Future<void> rewind() async {
    final newPosition = _audioPlayer.position - const Duration(seconds: 10);
    await _audioPlayer.seek(
      newPosition > Duration.zero ? newPosition : Duration.zero,
    );
  }
}
