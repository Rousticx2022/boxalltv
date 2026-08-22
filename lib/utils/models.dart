import 'package:cloud_firestore/cloud_firestore.dart';

class Posts {
  final String postID;
  final String uid;
  final String caption;
  final List<dynamic> content;
  final int likes;
  final int comments;
  final int shares;
  final String vid;
  final bool isTrimmed;
  final int recordingStartedFrom;
  final Timestamp postDate;

  const Posts(
    this.postID,
    this.uid,
    this.caption,
    this.content,
    this.likes,
    this.comments,
    this.shares,
    this.vid,
    this.isTrimmed,
    this.recordingStartedFrom,
    this.postDate,
  );

  factory Posts.fromDocument(DocumentSnapshot document) {
    return Posts(
      document.id,
      document['uid'],
      document['caption'],
      document['content'],
      document['likes'],
      document['comments'],
      document['shares'],
      document["vid"],
      document["isTrimmed"],
      document["recordingStartedFrom"],
      document['postDate'],
    );
  }
}

class MessageModel {
  final String chatID;
  final String message;
  final String type;
  final String sentBy;
  final Timestamp sentOn;

  const MessageModel(
    this.chatID,
    this.message,
    this.type,
    this.sentBy,
    this.sentOn,
  );

  factory MessageModel.fromDocument(DocumentSnapshot document) {
    return MessageModel(
      document.id,
      document['message'],
      document['type'],
      document['sentBy'],
      document['sentOn'],
    );
  }
}
