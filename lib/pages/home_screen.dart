import 'dart:async';
import 'dart:convert';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:captsone_2/pages/history_screen.dart';
import 'package:captsone_2/util/app_icons.dart';
import 'package:captsone_2/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:http/http.dart' as http;

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
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

StreamController<DurationState> durationStateController =
    StreamController<DurationState>.broadcast();
PlayerController playerController = PlayerController();
RecorderController recorderController = RecorderController();
final record = AudioRecorder();
String myRecordPath = "";
int? audioDuration;
bool isPlaying = false;
String myEmotion = '';

class _HomeScreenState extends State<HomeScreen> {
  Widget _buildPage() {
    switch (_pageIndex) {
      // Home
      case 0:
        return _buildPageMain();
      // Profile
      case 1:
        return _buildPageExamples();
      // History
      case 2:
        return HistoryScreen();
      // Settings
      case 3:
        return _buildSettingsPage();
      /////
      case 4:
        return _buildPageRecordMain();
      case 5:
        return _buildPageRecording();
      case 6:
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

  Future<String?> sendAudioFile(String filePath, String serverUrl) async {
    try {
      var request =
          http.MultipartRequest('POST', Uri.parse('$serverUrl/predict'))
            ..files.add(await http.MultipartFile.fromPath('file', filePath));

      var response = await request.send();

      if (response.statusCode == 200) {
        final Map<String, dynamic> result = json.decode(
            await http.Response.fromStream(response)
                .then((value) => value.body));
        print(result);
        return result['emotion'];
      } else {
        print('Error: ${response.statusCode}');
        return null;
      }
    } catch (error) {
      print('Error: $error');
      return null;
    }
  }

  _buildPageMain() {
    return Column(
      children: [
        Image.asset('assets/images/mainLogo.PNG'),
        const SizedBox(height: 24),
        TextButton(
            onPressed: () {
              setState(() {
                _pageIndex = 4;
              });
            },
            child: Text("RECORD", style: TextStyle(fontSize: 24)))
      ],
    );
  }

  _buildSettingsPage() {
    return Column(
      children: [
        Image.asset('assets/images/mainLogo.PNG'),
        const SizedBox(height: 24),
        TextButton(
            onPressed: () {},
            child: Text("EXIT", style: TextStyle(fontSize: 24)))
      ],
    );
  }

  _buildPageExamples() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Center(
            child: Text("Recording Examples", style: TextStyle(fontSize: 18))),
        const SizedBox(height: 24),
        Row(
          children: [
            AppIcons.getIcon("sad"),
            const SizedBox(width: 12),
            Text("Sad", style: TextStyle(fontSize: 20)),
            const SizedBox(width: 40),
            GestureDetector(
              onTap: () {
                AssetsAudioPlayer.newPlayer().open(
                  Audio("assets/audio/Sad.wav"),
                  autoStart: true,
                  showNotification: true,
                );
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            )
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            AppIcons.getIcon("angry"),
            const SizedBox(width: 12),
            Text("Angry", style: TextStyle(fontSize: 20)),
            const SizedBox(width: 40),
            GestureDetector(
              onTap: () {
                AssetsAudioPlayer.newPlayer().open(
                  Audio("assets/audio/Angry.wav"),
                  autoStart: true,
                  showNotification: true,
                );
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            )
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            AppIcons.getIcon("disgust"),
            const SizedBox(width: 12),
            Text("Disgust", style: TextStyle(fontSize: 20)),
            const SizedBox(width: 40),
            GestureDetector(
              onTap: () {
                AssetsAudioPlayer.newPlayer().open(
                  Audio("assets/audio/Disgust.wav"),
                  autoStart: true,
                  showNotification: true,
                );
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            )
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            AppIcons.getIcon("fear"),
            const SizedBox(width: 12),
            Text("Fear", style: TextStyle(fontSize: 20)),
            const SizedBox(width: 40),
            GestureDetector(
              onTap: () {
                AssetsAudioPlayer.newPlayer().open(
                  Audio("assets/audio/Fear.wav"),
                  autoStart: true,
                  showNotification: true,
                );
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            )
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            AppIcons.getIcon("happy"),
            const SizedBox(width: 12),
            Text("Happy", style: TextStyle(fontSize: 20)),
            const SizedBox(width: 40),
            GestureDetector(
              onTap: () {
                AssetsAudioPlayer.newPlayer().open(
                  Audio("assets/audio/Happy.wav"),
                  autoStart: true,
                  showNotification: true,
                );
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            )
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            AppIcons.getIcon("neutral"),
            const SizedBox(width: 12),
            Text("Neutral", style: TextStyle(fontSize: 20)),
            const SizedBox(width: 40),
            GestureDetector(
              onTap: () {
                AssetsAudioPlayer.newPlayer().open(
                  Audio("assets/audio/Neutral.wav"),
                  autoStart: true,
                  showNotification: true,
                );
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            )
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            AppIcons.getIcon("surprise"),
            const SizedBox(width: 12),
            Text("Suprise", style: TextStyle(fontSize: 20)),
            const SizedBox(width: 40),
            GestureDetector(
              onTap: () {
                AssetsAudioPlayer.newPlayer().open(
                  Audio("assets/audio/Suprise.wav"),
                  autoStart: true,
                  showNotification: true,
                );
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            )
          ],
        ),
      ],
    );
  }

  _buildPageRecordMain() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset('assets/images/mainLogo.PNG'),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(8),
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
                  DateTime now = DateTime.now();
                  int milliseconds = now.millisecondsSinceEpoch;
                  await record.start(
                      const RecordConfig(encoder: AudioEncoder.wav),
                      path:
                          '/data/user/0/com.example.captsone_2/cache/$milliseconds.wav');
                  setState(() {
                    _pageIndex = 5;
                  });
                } else {
                  // Permission denied, show a dialog or handle it as needed
                  print('Microphone permission denied');
                }
              },
              child: const Text("Start", style: TextStyle(fontSize: 24)),
            ),
          ),
          SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(8),
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
              child: Text("Back", style: TextStyle(fontSize: 24)),
            ),
          ),
        ],
      ),
    );
  }

  _buildPageRecording() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AudioWaveforms(
            size: Size(MediaQuery.of(context).size.width, 120),
            enableGesture: true,
            recorderController: recorderController,
            waveStyle: WaveStyle(
              waveColor: Colors.blue,
              waveThickness: 2.5,
              spacing: 3.0,
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
                    final path2 = await record.stop();
                    await recorderController.stop();
                    myRecordPath = path2!;
                    print("Path: $myRecordPath");
                    await playerController.preparePlayer(
                      path: myRecordPath,
                      noOfSamples: 100,
                    );
                    audioDuration =
                        await playerController.getDuration(DurationType.max);
                    setState(() {
                      _pageIndex = 6;
                    });
                  },
                  child: Center(
                      child: Container(
                    child: Icon(
                      Icons.stop,
                      color: Colors.white,
                      size: 36,
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
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          StreamBuilder<DurationState>(
            stream: durationStateController.stream,
            builder: (context, snapshot) {
              final durationState = snapshot.data;
              final progress = durationState?.progress ?? Duration.zero;
              final buffered = durationState?.buffered ?? Duration.zero;
              final total = Duration(milliseconds: audioDuration!);
              return ProgressBar(
                thumbColor: Colors.blue,
                baseBarColor: Colors.blue,
                progressBarColor: Colors.blue,
                timeLabelTextStyle: const TextStyle(color: Colors.blue),
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
              InkWell(
                onTap: () async {
                  ///
                  final String? result = await sendAudioFile(
                      myRecordPath, "http://192.168.71.98:5000");
                  print(result);
                  setState(() {
                    myEmotion = result!;
                  });
                },
                child: Container(
                    padding: const EdgeInsets.all(5),
                    child: const Icon(Icons.save_alt,
                        color: Colors.white, size: 32)),
              ),
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
                              child: Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 36,
                              ),
                            )
                          : Container(
                              child: Icon(
                                Icons.pause,
                                color: Colors.white,
                                size: 36,
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
                    _pageIndex = 4;
                    audioDuration = 0;
                    isPlaying = false;
                    myRecordPath = "";
                    myEmotion = '';
                  });
                  setupPlayerListener();
                  // _setupRecorderListener();
                },
                child: Container(
                    child: const Icon(Icons.delete,
                        color: Colors.white, size: 36)),
              ),
            ],
          ),
          const SizedBox(height: 32),
          if (myEmotion != '') Text(myEmotion, style: TextStyle(fontSize: 24)),
          if (myEmotion != '') const SizedBox(height: 16),
          if (myEmotion != '') AppIcons.getIcon(myEmotion),
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
      appBar: AppBarCustom(),
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _pageIndex,
        onTap: (i) => setState(() {
          _pageIndex = i;
        }),
        items: [
          /// Home
          SalomonBottomBarItem(
            icon: Icon(Icons.home),
            title: Text("Home"),
            selectedColor: Colors.purple,
          ),

          /// Likes
          SalomonBottomBarItem(
            icon: Icon(Icons.info_outline),
            title: Text("Tutorial"),
            selectedColor: Colors.pink,
          ),

          /// Search
          SalomonBottomBarItem(
            icon: Icon(Icons.history),
            title: Text("History"),
            selectedColor: Colors.orange,
          ),

          /// Profile
          SalomonBottomBarItem(
            icon: Icon(Icons.settings),
            title: Text("Settings"),
            selectedColor: Colors.teal,
          ),
        ],
      ),
      body: Padding(padding: const EdgeInsets.all(32), child: _buildPage()),
    );
  }
}
