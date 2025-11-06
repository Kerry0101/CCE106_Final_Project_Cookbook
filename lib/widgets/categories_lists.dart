import 'package:cookbook/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoriesList extends StatefulWidget {
  final String imageUrl, labelText;

  const CategoriesList(
      {super.key, required this.imageUrl, required this.labelText});

  @override
  State<CategoriesList> createState() => _CategoriesListState();
}

class _CategoriesListState extends State<CategoriesList> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print('Tapped on ${widget.labelText}');
      },
      child: Container(
        color: p_color,
        child: Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: SizedBox(
                  height: 100,
                  width: 100,
                  child: Image.asset(widget.imageUrl),
                ),
              ),
              Text(
                widget.labelText,
                style:
                GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
