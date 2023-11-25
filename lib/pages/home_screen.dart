import 'dart:async';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:captsone_2/widgets/bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

int _pageIndex = 0;

class DurationState {
  const DurationState(
      {required this.progress, required this.buffered, required this.total});
  final Duration progress;
  final Duration buffered;
  final Duration total;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

StreamController<DurationState> durationStateController =
    StreamController<DurationState>.broadcast();
PlayerController playerController = PlayerController();
RecorderController recorderController = RecorderController();
String myRecordPath = "";
int? audioDuration;
bool isPlaying = false;

List<Widget> titleWidget() {
  return [
    const Text(
      "Mood Wave",
      style: TextStyle(fontSize: 32, color: Colors.white),
    ),
    const SizedBox(height: 20),
  ];
}

class _HomeScreenState extends State<HomeScreen> {
  Widget _buildPage() {
    switch (_pageIndex) {
      case 0:
        return _buildPageMain();
      case 1:
        return _buildPageRecordMain();
      case 2:
        return _buildPageRecording();
      case 3:
        return _buildPageStopped();
      default:
        return Container(); // Handle unknown index
    }
  }

  void setupPlayerStateListener() {
    playerController.onPlayerStateChanged.listen((state) {
      if (state.isStopped) {
        if (mounted) {
          setState(() {
            isPlaying = false;
          });
          print("AUDIO ENDED!");
        }
      }
    });
  }

  // void setupRecorderListener() {
  //   recorderController.onCurrentDuration.listen((duration) async {
  //     setState(() {
  //       recorderCurrentDuration = duration;
  //     });
  //   });
  // }

  void setupPlayerListener() {
    setupPlayerStateListener();
    playerController.onCurrentDurationChanged.listen((int seconds) async {
      int currentPosition =
          await playerController.getDuration(DurationType.current);

      DurationState durationState = DurationState(
        progress: Duration(milliseconds: currentPosition),
        buffered: Duration.zero,
        total: Duration(milliseconds: audioDuration!),
      );
      durationStateController.add(durationState);

      if (currentPosition + 100 >= audioDuration!) {
        setState(() {
          isPlaying = false;
        });
      }
    });
  }

  _buildPageMain() {
    return Column(
      children: [
        ...titleWidget(),
        Image.asset('assets/images/mainLogo.PNG'),
        TextButton(
            onPressed: () {
              setState(() {
                _pageIndex = 1;
              });
            },
            child: Text("record"))
      ],
    );
  }

  _buildPageRecordMain() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ...titleWidget(),
          SizedBox(height: 50),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Color(0xFF82B4F3),
              ),
              borderRadius:
                  BorderRadius.circular(25.0), // Set the border radius
            ),
            child: TextButton(
              onPressed: () async {
                var status = await Permission.microphone.request();

                if (status.isGranted) {
                  // Permission granted, you can now use the microphone
                  print('Microphone permission granted');
                  await recorderController.record();
                  setState(() {
                    _pageIndex = 2;
                  });
                } else {
                  // Permission denied, show a dialog or handle it as needed
                  print('Microphone permission denied');
                }
              },
              child: Text("Start"),
            ),
          ),
          SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Color(0xFF82B4F3),
              ),
              borderRadius:
                  BorderRadius.circular(25.0), // Set the border radius
            ),
            child: TextButton(
              onPressed: () {
                setState(() {
                  _pageIndex = 0;
                });
              },
              child: Text("Back"),
            ),
          ),
        ],
      ),
    );
  }

  _buildPageRecording() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ...titleWidget(),
          const SizedBox(height: 80),
          AudioWaveforms(
            size: Size(MediaQuery.of(context).size.width, 40),
            enableGesture: true,
            recorderController: recorderController,
            waveStyle: const WaveStyle(
              waveColor: Colors.red,
              waveThickness: 1.5,
              spacing: 2.0,
              extendWaveform: true,
              showMiddleLine: false,
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              // duration of recording here
              const Spacer(),
              // widget id = 1
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final path = await recorderController.stop();
                    myRecordPath = path!;
                    print("Path: $myRecordPath");
                    await playerController.preparePlayer(
                      path: myRecordPath,
                      noOfSamples: 100,
                    );
                    audioDuration =
                        await playerController.getDuration(DurationType.max);
                    setState(() {
                      _pageIndex = 3;
                    });
                  },
                  child: Center(
                      child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.stop,
                      color: Colors.white,
                      size: 30,
                    ),
                  )),
                ),
              ),
              const Spacer()
            ],
          ),
        ],
      ),
    );
  }

  _buildPageStopped() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ...titleWidget(),
          const SizedBox(height: 80),
          StreamBuilder<DurationState>(
            stream: durationStateController.stream,
            builder: (context, snapshot) {
              final durationState = snapshot.data;
              final progress = durationState?.progress ?? Duration.zero;
              final buffered = durationState?.buffered ?? Duration.zero;
              final total = Duration(milliseconds: audioDuration!);
              return ProgressBar(
                thumbColor: Colors.red,
                baseBarColor: Colors.red,
                progressBarColor: Colors.red,
                timeLabelTextStyle: const TextStyle(color: Colors.red),
                progress: progress,
                buffered: buffered,
                total: total,
                onSeek: (duration) {
                  print('User selected a new time: $duration');
                  // _playerController.seekTo(duration.inMilliseconds);
                },
                onDragEnd: () {
                  setState(() {
                    isPlaying = false;
                  });
                },
              );
            },
          ),
          SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    if (!isPlaying) {
                      // PLAY AUDIO
                      setState(() {
                        isPlaying = !isPlaying;
                      });
                      await playerController.startPlayer(
                          finishMode: FinishMode.pause);
                    } else {
                      setState(() {
                        isPlaying = !isPlaying;
                      });
                      await playerController.pausePlayer();
                    }
                  },
                  child: Center(
                      child: isPlaying == false
                          ? Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 30,
                              ),
                            )
                          : Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.pause,
                                color: Colors.white,
                                size: 30,
                              ),
                            )),
                ),
              ),
              SizedBox(width: 20),
              // RESET AUDIO
              InkWell(
                onTap: () async {
                  playerController.dispose();

                  recorderController = RecorderController();
                  playerController = PlayerController();
                  setState(() {
                    //recorderCurrentDuration = Duration.zero;
                    _pageIndex = 1;
                    audioDuration = 0;
                    isPlaying = false;
                    myRecordPath = "";
                  });
                  setupPlayerListener();
                  // _setupRecorderListener();
                },
                child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.rectangle,
                    ),
                    child: const Icon(Icons.delete,
                        color: Colors.white, size: 32)),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _pageIndex = 0;
    isPlaying = false;
    myRecordPath = "";
    audioDuration = 0;
    playerController = PlayerController();
    recorderController = RecorderController();
    recorderController.androidEncoder = AndroidEncoder.aac;
    recorderController.androidOutputFormat = AndroidOutputFormat.mpeg4;
    recorderController.sampleRate = 44100;
    recorderController.bitRate = 48000;

    //setupRecorderListener();
    setupPlayerListener();
  }

  @override
  Widget build(BuildContext context) {
    // return const Scaffold(body: HomeContent());
    return Scaffold(
      backgroundColor: Color(0xFFA7CDFD),
      bottomNavigationBar: const BottomBar(),
      body: Padding(padding: const EdgeInsets.all(32), child: _buildPage()),
    );
  }
}
