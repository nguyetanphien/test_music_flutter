import 'dart:math';
import 'package:flutter/material.dart';
import '../music_vm.dart';

class SeekBarWidget extends StatefulWidget {
  const SeekBarWidget({
    super.key,
    required this.duration,
    required this.position,
    required this.bufferedPosition,
    this.onChanged,
    this.onChangeEnd,
    required this.provider,
  });

  final Duration duration;
  final Duration position;
  final Duration bufferedPosition;
  final ValueChanged<Duration>? onChanged;
  final ValueChanged<Duration>? onChangeEnd;
  final MusicVM provider;

  @override
  State<SeekBarWidget> createState() => _SeekBarWidgetState();
}

class _SeekBarWidgetState extends State<SeekBarWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Row(
            children: [
              Text(
                widget.provider.formatDuration(widget.position),
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              Text(
                widget.provider.formatDuration(widget.duration),
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        Slider(
          min: 0.0,
          max: widget.duration.inMilliseconds.toDouble(),
          value: min(widget.provider.dragValue ?? widget.position.inMilliseconds.toDouble(),
              widget.duration.inMilliseconds.toDouble()),
          onChanged: (value) {
            setState(() {
              widget.provider.dragValue = value;
            });
            if (widget.onChanged != null) {
              widget.onChanged!(Duration(milliseconds: value.round()));
            }
          },
          onChangeEnd: (value) {
            if (widget.onChangeEnd != null) {
              widget.onChangeEnd!(Duration(milliseconds: value.round()));
            }
            widget.provider.dragValue = null;
          },
          thumbColor: Colors.white,
          activeColor: Colors.white,
          inactiveColor: Colors.white.withOpacity(0.5),
        ),
      ],
    );
  }
}
