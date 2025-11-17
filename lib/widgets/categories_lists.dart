import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoriesList extends StatefulWidget {
  final String imageUrl, labelText;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoriesList({
    super.key,
    required this.imageUrl,
    required this.labelText,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  State<CategoriesList> createState() => _CategoriesListState();
}

class _CategoriesListState extends State<CategoriesList> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: widget.isSelected
                    ? Border.all(
                        color: const Color(0xFF008B8B),
                        width: 3,
                      )
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: widget.isSelected
                        ? const Color(0xFF008B8B).withOpacity(0.4)
                        : Colors.black.withOpacity(0.1),
                    blurRadius: widget.isSelected ? 12 : 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: SizedBox(
                  height: 60,
                  width: 60,
                  child: Image.asset(
                    widget.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 72,
              child: Text(
                widget.labelText,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: widget.isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: widget.isSelected
                      ? const Color(0xFF008B8B)
                      : Colors.black87,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
