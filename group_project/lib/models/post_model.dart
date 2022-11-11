import 'dart:async';

import 'package:flutter/material.dart';
import 'package:group_project/constants.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:group_project/models/post.dart';

class PostModel {
  //
  //  Add a new post to Firestore
  //
  Future insertPost(Post post) async {
    await FirebaseFirestore.instance.collection(AppConstants.postCollectionName)
        .doc().set(post.toMap());
  }

  //
  //  Update post in Firestore
  //
  Future updatePost(Post post) async {
    await FirebaseFirestore.instance.collection(AppConstants.postCollectionName)
        .doc(post.reference!.id).update(post.toMap());
  }

  //
  //  Remove post from Firestore
  //
  Future deletePost(Post post) async {
    await FirebaseFirestore.instance.collection(AppConstants.postCollectionName)
        .doc(post.reference!.id).delete();
  }

  //
  // Returns a list of all posts from Firestore
  //
  Future< List<Post> > getAllPostsList() async {
    var postData = await FirebaseFirestore.instance.collection(AppConstants.postCollectionName).get();
    return postData.docs.map<Post>(
            (document) => Post.fromMap(document, reference: document.reference)
    ).toList();
  }
}