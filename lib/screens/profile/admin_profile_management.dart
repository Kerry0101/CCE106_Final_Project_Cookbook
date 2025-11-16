import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cookbook/models/user_profile.dart';
import 'package:cookbook/services/user_profile_service.dart';
import 'package:cookbook/utils/colors.dart';
import 'package:cookbook/utils/utils.dart';

class AdminProfileManagement extends StatefulWidget {
  const AdminProfileManagement({super.key});

  @override
  State<AdminProfileManagement> createState() => _AdminProfileManagementState();
}

class _AdminProfileManagementState extends State<AdminProfileManagement> {
  final Utils utils = Utils();
  String _searchQuery = '';
  String _filterRole = 'all'; // 'all', 'admin', 'user'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'User Management',
          style: GoogleFonts.lato(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  onChanged: (value) {
                    setState(() => _searchQuery = value.toLowerCase());
                  },
                  decoration: InputDecoration(
                    hintText: 'Search users by name or email...',
                    hintStyle: GoogleFonts.poppins(fontSize: 14),
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryColor, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Filter Chips
                Row(
                  children: [
                    Text(
                      'Filter:',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildFilterChip('All', 'all'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Admins', 'admin'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Users', 'user'),
                  ],
                ),
              ],
            ),
          ),
          // User List
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  colors: [bgc1, bgc2, bgc3, bgc4],
                ),
              ),
              child: StreamBuilder<List<UserProfile>>(
              stream: UserProfileService.getAllUsersStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading users',
                          style: GoogleFonts.poppins(fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                var users = snapshot.data ?? [];

                // Apply filters
                if (_filterRole != 'all') {
                  users = users.where((user) => user.role == _filterRole).toList();
                }

                if (_searchQuery.isNotEmpty) {
                  users = users.where((user) {
                    return user.displayName.toLowerCase().contains(_searchQuery) ||
                        user.email.toLowerCase().contains(_searchQuery);
                  }).toList();
                }

                if (users.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No users found',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    return _buildUserCard(users[index]);
                  },
                );
              },
            ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterRole == value;
    return FilterChip(
      label: Text(
        label,
        style: GoogleFonts.montserrat(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isSelected ? Colors.white : Colors.grey[700],
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _filterRole = value);
      },
      selectedColor: primaryColor,
      backgroundColor: Colors.grey[200],
      checkmarkColor: Colors.white,
    );
  }

  Widget _buildUserCard(UserProfile user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Profile Picture
            Stack(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: user.photoURL != null
                      ? NetworkImage(user.photoURL!)
                      : null,
                  child: user.photoURL == null
                      ? Icon(Icons.person, size: 30, color: Colors.grey[600])
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'upload') {
                        _uploadUserProfilePicture(user.uid);
                      } else if (value == 'delete') {
                        _deleteUserProfilePicture(user.uid);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'upload',
                        child: Row(
                          children: [
                            const Icon(Icons.upload, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Change Photo',
                              style: GoogleFonts.poppins(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      if (user.photoURL != null)
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(Icons.delete, size: 18, color: Colors.red),
                              const SizedBox(width: 8),
                              Text(
                                'Remove Photo',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(Icons.camera_alt, size: 14, color: primaryColor),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.displayName,
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: user.isAdmin
                              ? Colors.amber[100]
                              : Colors.blue[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          user.isAdmin ? 'ADMIN' : 'USER',
                          style: GoogleFonts.montserrat(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: user.isAdmin
                                ? Colors.amber[900]
                                : Colors.blue[900],
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        user.phoneNumber!,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Role Toggle
            IconButton(
              icon: Icon(
                user.isAdmin ? Icons.admin_panel_settings : Icons.person,
                color: primaryColor,
              ),
              onPressed: () => _toggleUserRole(user),
              tooltip: 'Toggle role',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadUserProfilePicture(String uid) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result == null) return;

      final pickedFile = result.files.first;

      if (kIsWeb) {
        if (pickedFile.bytes != null) {
          await UserProfileService.updateUserProfilePicture(
            uid: uid,
            imageFile: pickedFile.bytes!,
            fileName: pickedFile.name,
            isWeb: true,
          );
        } else {
          throw Exception('Failed to read image data');
        }
      } else {
        final file = File(pickedFile.path!);
        await UserProfileService.updateUserProfilePicture(
          uid: uid,
          imageFile: file,
          fileName: pickedFile.name,
        );
      }

      if (mounted) {
        utils.showSuccess('Profile picture updated successfully!');
      }
    } catch (e) {
      if (mounted) {
        utils.showError('Failed to upload profile picture. Please try again.');
      }
    }
  }

  Future<void> _deleteUserProfilePicture(String uid) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Profile Picture',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to remove this user\'s profile picture?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.montserrat()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete', style: GoogleFonts.montserrat()),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await UserProfileService.deleteUserProfilePicture(uid);
      if (mounted) {
        utils.showSuccess('Profile picture removed');
      }
    } catch (e) {
      if (mounted) {
        utils.showError('Failed to remove profile picture');
      }
    }
  }

  Future<void> _toggleUserRole(UserProfile user) async {
    final newRole = user.isAdmin ? 'user' : 'admin';
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Change User Role',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to change ${user.displayName}\'s role to ${newRole.toUpperCase()}?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.montserrat()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Confirm', style: GoogleFonts.montserrat()),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await UserProfileService.updateUserRole(user.uid, newRole);
      if (mounted) {
        utils.showSuccess('User role updated to ${newRole.toUpperCase()}');
      }
    } catch (e) {
      if (mounted) {
        utils.showError('Failed to update user role');
      }
    }
  }
}
