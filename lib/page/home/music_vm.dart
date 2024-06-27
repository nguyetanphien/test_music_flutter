import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:christian_lyrics/christian_lyrics.dart';
import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:test_music_flutter/base/base_vm.dart';
import 'package:xml/xml.dart' as xml;
import 'package:xml/xml.dart';
import 'package:http/http.dart' as http;

import '../../model/position_data_model.dart';

class MusicVM extends BaseViewModel {
  AudioPlayer player = AudioPlayer();
  double? dragValue;
  bool isPlaying = true;
  PageController pageController = PageController(initialPage: 0);
  String lyricSrt = '';
  final christianLyrics = ChristianLyrics();
  Stream<PositionDataModel> get positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionDataModel>(
          player.positionStream,
          player.bufferedPositionStream,
          player.durationStream,
          (position, bufferedPosition, duration) =>
              PositionDataModel(position, bufferedPosition, duration ?? Duration.zero));
  @override
  Future<void> onInit() async {
    try {
      await player.setAudioSource(
        AudioSource.uri(Uri.parse("https://storage.googleapis.com/ikara-storage/tmp/beat.mp3")),
        initialPosition: Duration.zero,
      );
    } catch (e) {
      log("Error loading audio source: $e");
    }
    await fetchLyrics();
    // set lyric content
    christianLyrics.setLyricContent(lyricSrt);
    player.play();
    notifyListeners();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  ///
  /// format Duration "00:00"
  ///
  String formatDuration(Duration? duration) {
    if (duration == null) return '00:00';
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  ///
  /// format Duration Srt "00:00:00,000"
  ///
  String formatDurationSrt(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    final milliseconds = (duration.inMilliseconds % 1000).toString().padLeft(3, '0');
    return '$hours:$minutes:$seconds,$milliseconds';
  }

  ///
  /// fetch Lyrics from xml
  ///
  Future<void> fetchLyrics() async {
    final response = await http.get(Uri.parse('https://storage.googleapis.com/ikara-storage/ikara/lyrics.xml'));

    if (response.statusCode == 200) {
      final document = xml.XmlDocument.parse(utf8.decode(response.bodyBytes));
      lyricSrt = convertXmlToSrt(document);
      notifyListeners();
    } else {
      throw Exception('Failed to load lyrics');
    }
  }

  ///
  /// convert Xml To Srt from xml
  ///
  String convertXmlToSrt(XmlDocument xmlContent) {
    final params = xmlContent.findAllElements('param');

    final srtBuffer = StringBuffer();
    int index = 1;

    if (params.isNotEmpty) {
      final firstEndElement = params.first.findElements('i').first;
      final firstEndVa = double.parse(firstEndElement.getAttribute('va')!);
      final firstEndTime = Duration(milliseconds: (firstEndVa * 1000).toInt());

      srtBuffer.writeln('$index');
      srtBuffer.writeln('00:00:00,000 --> ${formatDurationSrt(firstEndTime)}');
      srtBuffer.writeln('* * *');
      srtBuffer.writeln();
      index++;
    }

    for (var param in params) {
      final startElement = param.findElements('i').first;
      final endElement = param.findElements('i').last;

      final startVa = double.parse(startElement.getAttribute('va')!);
      final endVa = double.parse(endElement.getAttribute('va')!);

      final startTime = Duration(milliseconds: (startVa * 1000).toInt());
      final endTime = Duration(milliseconds: (endVa * 1000).toInt());

      srtBuffer.writeln('$index');
      srtBuffer.writeln('${formatDurationSrt(startTime)} --> ${formatDurationSrt(endTime)}');

      final text = param.children.whereType<XmlElement>().map((e) => e.innerText).join(' ').trim();
      srtBuffer.writeln(text);
      srtBuffer.writeln();
      index++;
    }
    return srtBuffer.toString();
  }
}
