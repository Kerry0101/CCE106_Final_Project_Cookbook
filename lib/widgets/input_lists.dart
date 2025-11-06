import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ignore: must_be_immutable
class InputLists extends StatefulWidget {
  List<String> listController = [];
  final String header, label;

  InputLists(
      {super.key,
        required this.header,
        required this.listController,
        required this.label});

  @override
  State<InputLists> createState() => _InputListsState();
}

class _InputListsState extends State<InputLists> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.header,
            style: GoogleFonts.lato(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                itemCount: widget.listController.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: widget.listController[index],
                            decoration: InputDecoration(
                              labelText: '${widget.label} ${index + 1}',
                              border: const OutlineInputBorder(),
                            ),
                            onChanged: (newValue) {
                              setState(() {
                                widget.listController[index] = newValue;
                              });
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              widget.listController.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      widget.listController.add('');
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
