import 'package:captsone_2/widgets/app_bar.dart';
import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  final List<String> dataList = [
    'Data 1',
    'Data 2',
    'Data 3',
    // Add more data here as needed
  ];

  HistoryScreen({super.key});

  void _showResultDialog(BuildContext context, String data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Result for $data'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your result description goes here...'),
              SizedBox(height: 10),
              // Add your audio player widget here to play the audio file
              // Example: AudioPlayerWidget(audioUrl: 'your_audio_file_url'),
              Text('Audio file goes here...'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFA7CDFD),
      body: ListView.builder(
        itemCount: dataList.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            color: Color(0xFF82B4F3),
            child: ListTile(
              title: Text(
                dataList[index],
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                _showResultDialog(context, dataList[index]);
              },
            ),
          );
        },
      ),
    );
  }
}
