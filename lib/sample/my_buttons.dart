import 'package:flutter/material.dart';

class myButtons extends StatelessWidget {
  final String topic;
  final Function callbackFunction;
  const myButtons(
      {super.key, required this.topic, required this.callbackFunction});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        callbackFunction(topic);
      },
      child: Container(
        width: double.maxFinite,
        height: 70,
        margin: const EdgeInsets.only(top: 20, left: 40, right: 40, bottom: 50),
        decoration: BoxDecoration(
            color: Colors.lightBlue, borderRadius: BorderRadius.circular(20)),
        child: const Center(
          child: Text(
            "",
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
