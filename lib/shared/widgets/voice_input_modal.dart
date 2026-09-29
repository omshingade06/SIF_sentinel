import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'custom_button.dart';

class VoiceInputModal extends StatefulWidget {
  final Function(String transcribedText) onTextTranscribed;

  const VoiceInputModal({super.key, required this.onTextTranscribed});

  @override
  State<VoiceInputModal> createState() => _VoiceInputModalState();
}

class _VoiceInputModalState extends State<VoiceInputModal> with SingleTickerProviderStateMixin {
  bool _isRecording = true;
  int _recordingSeconds = 0;
  Timer? _timer;
  late AnimationController _animController;
  String _liveTranscription = '';

  final List<String> _samplePhrases = [
    'During maintenance at Separator Vessel V-102...',
    'During maintenance at Separator Vessel V-102, contractor technician entered the confined space...',
    'During turnaround maintenance activity at Separator Vessel V-102, a contractor technician entered the confined space without completing mandatory 4-gas testing and forced ventilation. The entry permit was not properly verified.',
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _startSimulation();
  }

  void _startSimulation() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _recordingSeconds++;
        if (_recordingSeconds == 1) {
          _liveTranscription = _samplePhrases[0];
        } else if (_recordingSeconds == 2) {
          _liveTranscription = _samplePhrases[1];
        } else if (_recordingSeconds >= 4) {
          _liveTranscription = _samplePhrases[2];
          _isRecording = false;
          _animController.stop();
          _timer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Speak Safety Observation',
                    style: AppTypography.headingMedium.copyWith(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isRecording ? AppColors.criticalBg : AppColors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _isRecording ? AppColors.critical : AppColors.textTertiary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isRecording ? '00:0${_recordingSeconds}s • LISTENING' : 'PROCESSED',
                        style: AppTypography.overline.copyWith(
                          color: _isRecording ? AppColors.critical : AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          // Animated Microphone / Waveform
          GestureDetector(
            onTap: () {
              setState(() {
                if (_isRecording) {
                  _isRecording = false;
                  _timer?.cancel();
                  _animController.stop();
                  if (_liveTranscription.isEmpty) {
                    _liveTranscription = _samplePhrases[2];
                  }
                } else {
                  _isRecording = true;
                  _recordingSeconds = 0;
                  _animController.repeat(reverse: true);
                  _startSimulation();
                }
              });
            },
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                final scale = _isRecording ? (1.0 + (_animController.value * 0.15)) : 1.0;
                return Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isRecording ? AppColors.primaryRed.withValues(alpha: 0.12) : AppColors.surfaceSecondary,
                    border: Border.all(
                      color: _isRecording ? AppColors.primaryRed : AppColors.border,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isRecording ? AppColors.primaryRed : AppColors.primaryBlack,
                        ),
                        child: Icon(
                          _isRecording ? Icons.mic_rounded : Icons.mic_none_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _isRecording ? 'Listening to voice in English/Hindi/Assamese...' : 'Tap mic to record again or apply text',
            style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          // Live Transcription Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'REAL-TIME TRANSCRIPTION',
                      style: AppTypography.overline.copyWith(color: AppColors.textTertiary),
                    ),
                    const Icon(Icons.auto_awesome, size: 14, color: AppColors.info),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _liveTranscription.isEmpty ? 'Say something like: "Worker entered confined space without gas test..."' : _liveTranscription,
                  style: AppTypography.bodyMedium.copyWith(
                    color: _liveTranscription.isEmpty ? AppColors.textTertiary : AppColors.textPrimary,
                    fontStyle: _liveTranscription.isEmpty ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  label: 'Cancel',
                  variant: ButtonVariant.outlined,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  label: 'Use This Text',
                  variant: ButtonVariant.primary,
                  onPressed: () {
                    final textToUse = _liveTranscription.isNotEmpty
                        ? _liveTranscription
                        : 'During turnaround maintenance activity at Separator Vessel V-102, a contractor technician entered the confined space without completing mandatory 4-gas testing and forced ventilation. The entry permit was not properly verified.';
                    widget.onTextTranscribed(textToUse);
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
  }
}
