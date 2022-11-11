import 'package:cloud_firestore/cloud_firestore.dart';

class SavedPost {
  int? id;                      //ID within the local database
  DocumentReference? reference; //Reference to the post that has been saved.
  bool? hidden=false;            //Whether or not this is a hidden post

  SavedPost({this.id, this.reference, this.hidden=false});

  SavedPost.fromMap(var map) {
    id=map['id'];
    reference=map['reference'];
    hidden=map['hidden'];
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'reference': reference,
      'hidden': hidden,
    };
  }
}