import 'package:cloud_firestore/cloud_firestore.dart';

class SavedPost {
  int? id;                      //ID within the local database
  String? documentID;           //Reference to the post that has been saved.
  bool? hidden=false;           //Whether or not this is a hidden post

  SavedPost({this.id, this.documentID, this.hidden=false});

  SavedPost.fromMap(var map) {
    id=map['id'];
    documentID=map['documentID'];
    hidden=map['hidden']!=0;
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'documentID': documentID,
      'hidden': hidden,
    };
  }
}