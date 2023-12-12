import 'package:captsone_2/widgets/app_bar.dart';
import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  final List<String> dataList = [
    '23.11.22          suprise',
    '23.11.20          fear',
    '23.11.07          angry',
    '23.10.26          angry',
    '23.10.24          neutral',
    '23.10.24          sad',
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
              trailing: Icon(
                Icons.play_arrow,
                size: 26,
                color: Colors.white,
              ),
              title: Text(
                dataList[index],
                style: TextStyle(color: Colors.white, fontSize: 18),
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
