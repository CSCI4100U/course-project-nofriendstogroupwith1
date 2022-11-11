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


  //TODO: Remove and use Firestore database to store posts
  //Take two seconds, then return the post
  //
  //Just to make sure we can see what it looks like
  //  while the app loads a post from online
  //
  Future<Post> getTestPost() async {
    await Future.delayed(
        const Duration(seconds: 2),
        () {}
    );

    //Return hard-coded test post
    return Post(
        title: "Lorem Ispum",
        imageURL: "https://cc0.photo/wp-content/uploads/2022/02/New-York-skyline-in-October-2017-980x656.jpg",
        location: LatLng(43.945137,-78.900231),
        caption: "Lorem ipsum dolor sit amet, consectetur adipiscing elit",
    );
  }
}