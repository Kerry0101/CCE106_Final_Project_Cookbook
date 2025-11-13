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

class _ReviewCategoriesScreenState extends State<ReviewCategoriesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Review Categories',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pending', icon: Icon(Icons.hourglass_empty)),
            Tab(text: 'Approved', icon: Icon(Icons.check_circle)),
            Tab(text: 'Rejected', icon: Icon(Icons.cancel)),
          ],
          labelColor: textColor1,
          unselectedLabelColor: textColor1.withOpacity(0.5),
          indicatorColor: bgc1,
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [bgc1, bgc2, bgc3, bgc4],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPendingTab(),
          _buildApprovedTab(),
          _buildRejectedTab(),
        ],
      ),
    );
  }

  Widget _buildPendingTab() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: readCategorySuggestions(status: 'pending'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final suggestions = snapshot.data ?? [];

        if (suggestions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 64, color: textColor1.withOpacity(0.3)),
                const SizedBox(height: 16),
                Text(
                  'No pending suggestions',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: textColor1.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: suggestions.length,
          padding: const EdgeInsets.all(8),
          itemBuilder: (context, index) {
            return _buildSuggestionCard(suggestions[index], isPending: true);
          },
        );
      },
    );
  }

  Widget _buildApprovedTab() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: readCategorySuggestions(status: 'approved'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final suggestions = snapshot.data ?? [];

        if (suggestions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, size: 64, color: textColor1.withOpacity(0.3)),
                const SizedBox(height: 16),
                Text(
                  'No approved suggestions',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: textColor1.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: suggestions.length,
          padding: const EdgeInsets.all(8),
          itemBuilder: (context, index) {
            return _buildSuggestionCard(suggestions[index], isPending: false);
          },
        );
      },
    );
  }

  Widget _buildRejectedTab() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: readCategorySuggestions(status: 'rejected'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final suggestions = snapshot.data ?? [];

        if (suggestions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cancel_outlined, size: 64, color: textColor1.withOpacity(0.3)),
                const SizedBox(height: 16),
                Text(
                  'No rejected suggestions',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: textColor1.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: suggestions.length,
          padding: const EdgeInsets.all(8),
          itemBuilder: (context, index) {
            return _buildSuggestionCard(suggestions[index], isPending: false);
          },
        );
      },
    );
  }

  Widget _buildSuggestionCard(Map<String, dynamic> suggestion, {required bool isPending}) {
    final categoryName = suggestion['categoryName'] ?? 'Unknown';
    final description = suggestion['description'] ?? '';
    final submittedAt = suggestion['submittedAt'] as Timestamp?;
    final reviewedAt = suggestion['reviewedAt'] as Timestamp?;
    final rejectionReason = suggestion['rejectionReason'];
    final suggestedBy = suggestion['suggestedBy'] ?? '';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Name
            Text(
              categoryName,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textColor1,
              ),
            ),
            const SizedBox(height: 4),

            // Description
            if (description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: textColor1.withOpacity(0.7),
                  ),
                ),
              ),

            // Submitted By (with user name lookup)
            FutureBuilder<String>(
              future: _getUserName(suggestedBy),
              builder: (context, userSnapshot) {
                final userName = userSnapshot.data ?? 'Loading...';
                return Row(
                  children: [
                    Icon(Icons.person, size: 14, color: textColor1.withOpacity(0.5)),
                    const SizedBox(width: 4),
                    Text(
                      'Submitted by: $userName',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: textColor1.withOpacity(0.5),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 4),

            // Submitted Date
            if (submittedAt != null)
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: textColor1.withOpacity(0.5)),
                  const SizedBox(width: 4),
                  Text(
                    'Submitted: ${DateFormat('MMM dd, yyyy').format(submittedAt.toDate())}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: textColor1.withOpacity(0.5),
                    ),
                  ),
                ],
              ),

            // Approved/Rejected Info
            if (!isPending) ...[
              const SizedBox(height: 4),
              if (reviewedAt != null && rejectionReason == null)
                Row(
                  children: [
                    const Icon(Icons.check_circle, size: 14, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      'Approved: ${DateFormat('MMM dd, yyyy').format(reviewedAt.toDate())}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              if (rejectionReason != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.cancel, size: 14, color: Colors.red),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Reason: $rejectionReason',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],

            // Action Buttons (only for pending)
            if (isPending) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _showRejectDialog(suggestion['id']),
                    icon: const Icon(Icons.cancel, size: 18),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _approveSuggestion(suggestion['id']),
                    icon: const Icon(Icons.check_circle, size: 18),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
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

  Future<String> _getUserName(String userId) async {
    if (userId.isEmpty) return 'Unknown User';
    
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      
      if (userDoc.exists) {
        return userDoc.data()?['name'] ?? 'Unknown User';
      }
      return 'Unknown User';
    } catch (e) {
      return 'Unknown User';
    }
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
        title: Text(
          'Reject Suggestion',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Provide a reason for rejection:',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: 'Rejection Reason',
                hintText: 'Enter reason...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please provide a reason'),
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
                    const SnackBar(
                      content: Text('Category suggestion rejected'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to reject suggestion'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}
