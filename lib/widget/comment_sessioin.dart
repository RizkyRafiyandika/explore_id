import 'package:explore_id/models/comment_model.dart';
import 'package:explore_id/models/listTrip.dart';
import 'package:explore_id/services/comment_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyCommentSession extends StatefulWidget {
  final ListTrip trip;
  const MyCommentSession({super.key, required this.trip});

  @override
  State<MyCommentSession> createState() => _MyCommentSessionState();
}

class _MyCommentSessionState extends State<MyCommentSession> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSubmitting = false;
  bool _showAllComments = false; // Tambahkan ini untuk expand/collapse

  @override
  void initState() {
    super.initState();
    _commentController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await addComment(widget.trip.id, _commentController.text.trim());
      _commentController.clear();
      _focusNode.unfocus();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Komentar berhasil ditambahkan!'),
            ],
          ),
          backgroundColor: Colors.green[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Gagal mengirim komentar'),
            ],
          ),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<void> _deleteComment(String commentId) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: 20),
                Icon(Icons.delete_outline, size: 48, color: Colors.red[400]),
                SizedBox(height: 16),
                Text(
                  'Hapus Komentar',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Apakah Anda yakin ingin menghapus komentar ini?',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text('Batal'),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[600],
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text('Hapus'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
    );

    if (result == true) {
      try {
        await deleteComment(commentId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Komentar berhasil dihapus'),
              ],
            ),
            backgroundColor: Colors.orange[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Gagal menghapus komentar'),
              ],
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        // Comment Input dengan glassmorphism effect
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16),
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black26 : Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                margin: EdgeInsets.all(8),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person, color: Colors.white, size: 20),
              ),

              Expanded(
                child: TextField(
                  controller: _commentController,
                  focusNode: _focusNode,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: "Tulis komentar Anda...",
                    hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 4,
                    ),
                  ),
                  style: TextStyle(fontSize: 14, height: 1.4),
                ),
              ),

              AnimatedContainer(
                duration: Duration(milliseconds: 200),
                margin: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  gradient:
                      _commentController.text.trim().isNotEmpty
                          ? LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          )
                          : null,
                  color:
                      _commentController.text.trim().isEmpty
                          ? Colors.grey[300]
                          : null,
                  shape: BoxShape.circle,
                ),
                child:
                    _isSubmitting
                        ? Container(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                        )
                        : IconButton(
                          icon: Icon(
                            Icons.send_rounded,
                            color:
                                _commentController.text.trim().isNotEmpty
                                    ? Colors.white
                                    : Colors.grey[600],
                            size: 20,
                          ),
                          onPressed: _submitComment,
                        ),
              ),
            ],
          ),
        ),

        SizedBox(height: 24),

        // Comments List dengan modern cards - DIPERBAIKI DI SINI
        StreamBuilder<List<Comment>>(
          stream: getCommentsStream(widget.trip.id),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Container(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // TAMBAHKAN INI
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.error_outline_rounded,
                        color: Colors.red[400],
                        size: 32,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Oops! Something went wrong',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Please try again later',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              );
            }

            if (!snapshot.hasData) {
              return Container(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // TAMBAHKAN INI
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading comments...',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              );
            }

            final comments = snapshot.data!;
            final sortedComments = sortComments(comments);

            if (sortedComments.isEmpty) {
              return Container(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // TAMBAHKAN INI
                  children: [
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF6366F1).withOpacity(0.1),
                            Color(0xFF8B5CF6).withOpacity(0.1),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.chat_bubble_outline_rounded,
                        color: Color(0xFF6366F1),
                        size: 48,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'No comments yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Be the first to share your thoughts!',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              );
            }

            // Batasi jumlah comment yang ditampilkan
            final displayedComments =
                _showAllComments
                    ? sortedComments
                    : sortedComments.take(3).toList();

            return Column(
              mainAxisSize: MainAxisSize.min, // TAMBAHKAN INI
              children: [
                ListView.separated(
                  shrinkWrap: true, // TAMBAHKAN INI
                  physics: NeverScrollableScrollPhysics(), // TAMBAHKAN INI
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                  itemCount: displayedComments.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final comment = displayedComments[index];
                    final isCurrentUser =
                        comment.userId ==
                        FirebaseAuth.instance.currentUser?.uid;

                    return FutureBuilder<String>(
                      future: getUsername(comment.userId),
                      builder: (context, usernameSnapshot) {
                        final username = usernameSnapshot.data ?? "Loading...";

                        return Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient:
                                isCurrentUser
                                    ? LinearGradient(
                                      colors: [
                                        Color(0xFF6366F1).withOpacity(0.1),
                                        Color(0xFF8B5CF6).withOpacity(0.05),
                                      ],
                                    )
                                    : null,
                            color:
                                isCurrentUser
                                    ? null
                                    : isDark
                                    ? Colors.grey[850]
                                    : Colors.grey[50],
                            borderRadius: BorderRadius.circular(16),
                            border:
                                isCurrentUser
                                    ? Border.all(
                                      color: Color(0xFF6366F1).withOpacity(0.3),
                                      width: 1,
                                    )
                                    : null,
                            boxShadow: [
                              BoxShadow(
                                color:
                                    isDark
                                        ? Colors.black26
                                        : Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors:
                                            isCurrentUser
                                                ? [
                                                  Color(0xFF6366F1),
                                                  Color(0xFF8B5CF6),
                                                ]
                                                : [
                                                  Colors.grey[400]!,
                                                  Colors.grey[500]!,
                                                ],
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          username.isNotEmpty
                                              ? username[0].toUpperCase()
                                              : '?',
                                          style: TextStyle(
                                            color:
                                                isCurrentUser
                                                    ? Color(0xFF6366F1)
                                                    : Colors.grey[600],
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              username,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                            ),
                                            if (isCurrentUser) ...[
                                              SizedBox(width: 6),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Color(0xFF6366F1),
                                                      Color(0xFF8B5CF6),
                                                    ],
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  'You',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        Text(
                                          '2 mins ago', // You can implement time calculation
                                          style: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isCurrentUser)
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.red[50],
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.delete_outline_rounded,
                                          color: Colors.red[400],
                                          size: 18,
                                        ),
                                        onPressed:
                                            () => _deleteComment(comment.id),
                                        tooltip: 'Delete comment',
                                      ),
                                    ),
                                ],
                              ),

                              SizedBox(height: 12),

                              Text(
                                comment.commentText,
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.5,
                                  color:
                                      isDark
                                          ? Colors.grey[200]
                                          : Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),

                // Show More/Less Button
                if (sortedComments.length > 3)
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _showAllComments = !_showAllComments;
                        });
                      },
                      icon: Icon(
                        _showAllComments
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF6366F1),
                      ),
                      label: Text(
                        _showAllComments
                            ? 'Show Less'
                            : 'Show ${sortedComments.length - 3} More Comments',
                        style: TextStyle(
                          color: Color(0xFF6366F1),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: Color(0xFF6366F1).withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
