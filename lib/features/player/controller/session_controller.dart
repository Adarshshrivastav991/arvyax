import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../../../data/models/ambience_model.dart';
import '../../../data/repositories/ambience_repository.dart';
import '../../../data/repositories/session_repository.dart';
import '../../../main.dart';

class SessionState {
  final AmbienceModel? ambience;
  final bool isPlaying;
  final int elapsedSeconds;
  final bool isSessionActive;
  final bool isSessionComplete;

  const SessionState({
    this.ambience,
    this.isPlaying = false,
    this.elapsedSeconds = 0,
    this.isSessionActive = false,
    this.isSessionComplete = false,
  });

  SessionState copyWith({
    AmbienceModel? ambience,
    bool? isPlaying,
    int? elapsedSeconds,
    bool? isSessionActive,
    bool? isSessionComplete,
  }) {
    return SessionState(
      ambience: ambience ?? this.ambience,
      isPlaying: isPlaying ?? this.isPlaying,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isSessionActive: isSessionActive ?? this.isSessionActive,
      isSessionComplete: isSessionComplete ?? this.isSessionComplete,
    );
  }

  double get progress {
    if (ambience == null || ambience!.duration == 0) return 0;
    return elapsedSeconds / ambience!.duration;
  }

  int get remainingSeconds {
    if (ambience == null) return 0;
    return (ambience!.duration - elapsedSeconds).clamp(0, ambience!.duration);
  }
}

class SessionController extends StateNotifier<SessionState> {
  final SessionRepository _sessionRepository;
  final AmbienceRepository _ambienceRepository;
  Timer? _timer;

  SessionController(this._sessionRepository, this._ambienceRepository)
    : super(const SessionState()) {
    _restoreSession();
  }

  // Use the global audio handler instead of local player
  AudioPlayer get audioPlayer => audioHandler.audioPlayer;

  Future<void> _restoreSession() async {
    final saved = await _sessionRepository.getActiveSession();
    if (saved == null) return;

    final ambienceId = saved['ambienceId'] as String;
    final elapsed = saved['elapsedSeconds'] as int;

    final ambience = await _ambienceRepository.getAmbienceById(ambienceId);
    if (ambience == null) return;

    if (elapsed >= ambience.duration) {
      await _sessionRepository.clearActiveSession();
      return;
    }

    state = SessionState(
      ambience: ambience,
      isPlaying: false,
      elapsedSeconds: elapsed,
      isSessionActive: true,
      isSessionComplete: false,
    );
  }

  Future<void> startSession(AmbienceModel ambience) async {
    _timer?.cancel();

    state = SessionState(
      ambience: ambience,
      isPlaying: true,
      elapsedSeconds: 0,
      isSessionActive: true,
      isSessionComplete: false,
    );

    // Use audio handler for background playback with notification
    await audioHandler.loadAudio(ambience.audio, ambience.title, ambience.tag);
    await audioHandler.play();

    _startTimer();
    _persistState();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (!state.isPlaying || !state.isSessionActive) return;

      final newElapsed = state.elapsedSeconds + 1;

      if (state.ambience != null && newElapsed >= state.ambience!.duration) {
        // Session complete
        _timer?.cancel();
        await audioHandler.stop();
        state = state.copyWith(
          elapsedSeconds: state.ambience!.duration,
          isPlaying: false,
          isSessionActive: false,
          isSessionComplete: true,
        );
        _sessionRepository.clearActiveSession();
      } else {
        state = state.copyWith(elapsedSeconds: newElapsed);
        if (newElapsed % 5 == 0) _persistState();
      }
    });
  }

  Future<void> togglePlayPause() async {
    if (state.isPlaying) {
      await audioHandler.pause();
      _timer?.cancel();
      state = state.copyWith(isPlaying: false);
    } else {
      try {
        await audioHandler.play();
      } catch (_) {}
      state = state.copyWith(isPlaying: true);
      _startTimer();
    }
    _persistState();
  }

  Future<void> seekTo(Duration position) async {
    final seconds = position.inSeconds.clamp(0, state.ambience?.duration ?? 0);
    await audioHandler.seek(position);
    state = state.copyWith(elapsedSeconds: seconds);
  }

  Future<void> skipForward() async {
    final newPos = (state.elapsedSeconds + 10).clamp(
      0,
      state.ambience?.duration ?? 0,
    );
    await seekTo(Duration(seconds: newPos));
  }

  Future<void> skipBackward() async {
    final newPos = (state.elapsedSeconds - 10).clamp(
      0,
      state.ambience?.duration ?? 0,
    );
    await seekTo(Duration(seconds: newPos));
  }

  Future<void> endSession() async {
    _timer?.cancel();
    await audioHandler.stop();
    state = state.copyWith(
      isPlaying: false,
      isSessionActive: false,
      isSessionComplete: true,
    );
    await _sessionRepository.clearActiveSession();
  }

  Future<void> clearSession() async {
    _timer?.cancel();
    await audioHandler.stop();
    state = const SessionState();
    await _sessionRepository.clearActiveSession();
  }

  void _persistState() {
    if (state.ambience != null) {
      _sessionRepository.saveActiveSession(
        ambienceId: state.ambience!.id,
        elapsedSeconds: state.elapsedSeconds,
        isPlaying: state.isPlaying,
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    // Don't dispose audio handler as it's global and managed by audio_service
    super.dispose();
  }
}

final sessionControllerProvider =
    StateNotifierProvider<SessionController, SessionState>((ref) {
      final sessionRepo = ref.watch(sessionRepositoryProvider);
      final ambienceRepo = ref.watch(ambienceRepositoryProvider);
      return SessionController(sessionRepo, ambienceRepo);
    });
