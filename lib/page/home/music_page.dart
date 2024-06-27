import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:test_music_flutter/base/base_page.dart';
import 'package:test_music_flutter/page/home/music_vm.dart';
import '../../model/position_data_model.dart';
import 'widget/circle_painter_widget.dart';
import 'widget/seek_bar_widget.dart';

class MusicPage extends StatefulWidget {
  const MusicPage({super.key});

  @override
  State<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> with MixinBasePage<MusicVM> {
  @override
  void dispose() {
    provider.player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return builder(() => Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple.shade900, Colors.deepPurple.shade400],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
            child: Stack(
              children: [
                PageView(
                  controller: provider.pageController,
                  children: [
                    Center(
                      child: Container(
                        height: 100,
                        width: 100,
                        margin: const EdgeInsets.only(bottom: 150),
                        child: CustomPaint(
                          size: const Size(100, 100),
                          painter: CirclePainterWidget(),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 200),
                      color: Colors.transparent,
                      child: StreamBuilder<PlayerState>(
                          stream: provider.player.playerStateStream,
                          builder: (context, snapshot) {
                            final playerState = snapshot.data;
                            final playing = playerState?.playing ?? false;
                            return provider.christianLyrics.getLyric(context, isPlaying: playing);
                          }),
                    ),
                  ],
                ),
                Positioned(
                  bottom: 70,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      StreamBuilder<PositionDataModel>(
                          stream: provider.positionDataStream,
                          builder: (context, snapshot) {
                            final positionData = snapshot.data;

                            if (positionData != null) {
                              provider.christianLyrics.setPositionWithOffset(
                                  position: positionData.position.inMilliseconds,
                                  duration: positionData.duration.inMilliseconds);
                            }
                            return SeekBarWidget (
                              duration: positionData?.duration ?? Duration.zero,
                              position: positionData?.position ?? Duration.zero,
                              bufferedPosition: positionData?.bufferedPosition ?? Duration.zero,
                              onChangeEnd: (Duration d) {
                                provider.christianLyrics.resetLyric();
                                provider.christianLyrics.setPositionWithOffset(
                                    position: d.inMilliseconds, duration: positionData!.duration.inMilliseconds);
                                provider.player.seek(d);
                              },
                              provider: provider,
                            );
                          }),
                      Visibility(
                        visible: !provider.isPlaying,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              provider.isPlaying = true;
                              provider.player.play();
                            });
                          },
                          child: const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: provider.isPlaying,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              provider.isPlaying = false;
                              provider.player.pause();
                            });
                          },
                          child: const Icon(
                            Icons.pause,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }

  @override
  MusicVM create() {
    return MusicVM();
  }

  @override
  void initialise(BuildContext context) {}
}
