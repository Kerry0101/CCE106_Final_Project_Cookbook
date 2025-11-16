import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TextBoxField extends StatefulWidget {
  final String label, placeholderText;
  final TextEditingController formController;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;

  const TextBoxField({
    super.key,
    required this.label,
    required this.formController,
    required this.placeholderText,
    this.onChanged,
    this.validator,
  });

  @override
  _TextBoxFieldState createState() => _TextBoxFieldState();
}

class _TextBoxFieldState extends State<TextBoxField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: TextFormField(
              controller: widget.formController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: widget.label,
                hintText: widget.placeholderText,
                suffixIcon: IconButton(
                  onPressed: () {
                    widget.formController.clear();
                  },
                  icon: const Icon(Icons.clear),
                ),
                labelStyle: GoogleFonts.lato(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                hintStyle: GoogleFonts.lato(
                  fontSize: 16,
                ),
              ),
              onChanged: (value) {
                if (widget.onChanged != null) {
                  widget.onChanged!(value);
                }
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: widget.validator ?? (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'This field is required';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }
}
