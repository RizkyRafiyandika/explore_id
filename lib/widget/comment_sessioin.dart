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
  @override
  Widget build(BuildContext context) {
    TextEditingController _commentController = TextEditingController();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Komentar",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(hintText: "Tulis komentar..."),
              ),
            ),
            IconButton(
              icon: Icon(Icons.send),
              onPressed: () {
                addComment(widget.trip.id, _commentController.text);
                _commentController.clear();
              },
            ),
          ],
        ),
        Container(
          width: double.infinity,
          height: 300,
          child: StreamBuilder<List<Comment>>(
            stream: getCommentsStream(widget.trip.id),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              final comments = snapshot.data!;
              final sortedComments = sortComments(comments);
              return ListView.builder(
                itemCount: sortedComments.length,
                itemBuilder: (context, index) {
                  final comment = comments[index];
                  return FutureBuilder<String>(
                    future: getUsername(comment.userId),
                    builder: (context, usernameSnapshot) {
                      final username = usernameSnapshot.data ?? "Loading...";
                      return Container(
                        padding: EdgeInsets.all(8),
                        margin: EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,

                          children: [
                            Column(
                              children: [
                                Text(
                                  comment.commentText,
                                  style: TextStyle(color: Colors.white),
                                ),
                                Text(username),
                              ],
                            ),
                            if (comment.userId ==
                                FirebaseAuth.instance.currentUser?.uid)
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.white),
                                onPressed: () => deleteComment(comment.id),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
