import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:group_project/constants.dart';
//import '../models/product.dart';
import 'package:group_project/models/post.dart';
import 'package:latlong2/latlong.dart';

import 'package:group_project/models/post_model.dart';

class AddPost extends StatefulWidget {
  const AddPost({Key? key}) : super(key: key);

  @override
  State<AddPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  String? _title;
  String? _imageURL;
  String? _caption;

  PostModel _model = PostModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
        children: [
              TextField(
              decoration: InputDecoration(
                labelText: "Title:"
              ),
              style: TextStyle(fontSize: 30),
              onChanged: (post_title){
                _title = post_title;
                },
            ),
            TextField(
              decoration: InputDecoration(
                  labelText: "imageURL"
              ),
              style: TextStyle(fontSize: 30),
              onChanged: (post_URL){
                _imageURL = post_URL;
              },
            ),
            TextField(
              decoration: InputDecoration(
                  labelText: "Caption"
              ),
              style: TextStyle(fontSize: 30),
              onChanged: (cap){
                _caption = cap;
              },
            ),            
          ],
      ),
      ),
      floatingActionButton: FloatingActionButton(
            onPressed: _addToDb,
            tooltip: "Add",
            child: const Icon(Icons.add),
          ),
    
    );
  }

  Future _addToDb() async{
    print("Adding a new entry...");
    Post post_data = Post (
      title: _title,
      imageURL: _imageURL,
      location: AppConstants.defaultLocation,
      caption: _caption
    );
    await _model.insertPost(post_data);
  }










}
