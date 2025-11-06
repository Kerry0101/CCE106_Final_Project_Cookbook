import 'package:cookbook/sample/my_buttons.dart';
import 'package:flutter/material.dart';

class samplePage extends StatefulWidget {
  const samplePage({super.key});

  @override
  State<samplePage> createState() => _samplePageState();
}

class _samplePageState extends State<samplePage> {
  String topic = "Packages";
  callback(varTopic) {
    setState(() {
      topic = varTopic;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Learning FLutter"),
      ),
      body: Column(
        children: [
          Container(
            width: double.maxFinite,
            height: 70,
            margin:
            const EdgeInsets.only(top: 50, left: 40, right: 40, bottom: 50),
            decoration: BoxDecoration(
                color: Colors.lightBlue,
                borderRadius: BorderRadius.circular(20)),
            child: Center(
              child: Text(
                "We are learning $topic",
                style: const TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
          ),
          myButtons(topic: "cubit", callbackFunction: callback),
          myButtons(
              topic: "the man who cnat be moved", callbackFunction: callback),
          myButtons(topic: "annyeong", callbackFunction: callback)
        ],
      ),
    );
  }
}

