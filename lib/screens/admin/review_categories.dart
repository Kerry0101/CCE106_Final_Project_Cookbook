import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cookbook/utils/colors.dart';
import 'package:cookbook/services/firestore_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ReviewCategoriesScreen extends StatefulWidget {
  const ReviewCategoriesScreen({super.key});

  @override
  State<ReviewCategoriesScreen> createState() => _ReviewCategoriesScreenState();
}

class _ReviewCategoriesScreenState extends State<ReviewCategoriesScreen> {
  String _selectedStatus = 'pending';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Review Category Suggestions',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Status Filter Tabs
          Container(
            color: Colors.grey[100],
            child: Row(
              children: [
                _buildStatusTab('pending', 'Pending'),
                _buildStatusTab('approved', 'Approved'),
                _buildStatusTab('rejected', 'Rejected'),
              ],
            ),
          ),

          // Category Suggestions List
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: readCategorySuggestions(status: _selectedStatus),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: GoogleFonts.poppins(color: Colors.red),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final suggestions = snapshot.data ?? [];

                if (suggestions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.category_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No ${_selectedStatus} suggestions',
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: suggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = suggestions[index];
                    return _buildSuggestionCard(suggestion);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTab(String status, String label) {
    final isSelected = _selectedStatus == status;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedStatus = status;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: isSelected ? primaryColor : Colors.grey[300]!,
                width: isSelected ? 3 : 1,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionCard(Map<String, dynamic> suggestion) {
    final categoryName = suggestion['categoryName'] ?? 'Unknown';
    final description = suggestion['description'] ?? 'No description';
    final status = suggestion['status'] ?? 'pending';
    final submittedAt = suggestion['submittedAt'] as Timestamp?;
    final reviewedAt = suggestion['reviewedAt'] as Timestamp?;
    final rejectionReason = suggestion['rejectionReason'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Name
            Row(
              children: [
                Expanded(
                  child: Text(
                    categoryName,
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                  ),
                ),
                _buildStatusBadge(status),
              ],
            ),
            const SizedBox(height: 8),

            // Description
            if (description.isNotEmpty && description != 'No description')
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
              ),

            // Submitted Date
            if (submittedAt != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      'Submitted: ${DateFormat('MMM dd, yyyy').format(submittedAt.toDate())}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

            // Reviewed Date (if reviewed)
            if (reviewedAt != null && status != 'pending')
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      'Reviewed: ${DateFormat('MMM dd, yyyy').format(reviewedAt.toDate())}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

            // Rejection Reason (if rejected)
            if (status == 'rejected' && rejectionReason != null)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.red[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Reason: $rejectionReason',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.red[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Action Buttons (only for pending)
            if (status == 'pending') ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _showRejectDialog(suggestion['id']),
                    icon: const Icon(Icons.close, size: 18),
                    label: Text(
                      'Reject',
                      style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _approveSuggestion(suggestion['id']),
                    icon: const Icon(Icons.check, size: 18),
                    label: Text(
                      'Approve',
                      style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    IconData icon;
    String label;

    switch (status) {
      case 'approved':
        color = Colors.green;
        icon = Icons.check_circle;
        label = 'Approved';
        break;
      case 'rejected':
        color = Colors.red;
        icon = Icons.cancel;
        label = 'Rejected';
        break;
      default:
        color = Colors.orange;
        icon = Icons.pending;
        label = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _approveSuggestion(String suggestionId) async {
    try {
      await approveCategorySuggestion(suggestionId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Category suggestion approved!',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to approve suggestion',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showRejectDialog(String suggestionId) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Reject Suggestion',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w700,
            color: primaryColor,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please provide a reason for rejection:',
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Reason for rejection...',
                hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryColor, width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.montserrat(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Please provide a reason',
                      style: GoogleFonts.poppins(),
                    ),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              try {
                await rejectCategorySuggestion(
                  suggestionId,
                  reasonController.text.trim(),
                );
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Category suggestion rejected',
                        style: GoogleFonts.poppins(),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Failed to reject suggestion',
                        style: GoogleFonts.poppins(),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(
              'Reject',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
