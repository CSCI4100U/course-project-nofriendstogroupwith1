import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'product.dart';
import 'package:latlong2/latlong.dart';

class AddPost extends StatefulWidget {
  const AddPost({Key? key}) : super(key: key);

  @override
  State<AddPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  String? _title;
  String? _imageURL;
  String? _caption;  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
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
            floatingActionButton: FloatingActionButton(
            onPressed: _addToDb,
            tooltip: "Add",
            child: const Icon(Icons.add),
          ),
      ),
    );
  }

  Future _addToDb() async{
    print("Adding a new entry...");
    Post post_data = <String,Object?>{
      "title": _title,
      "imageURL": _imageURL,
      "location": LatLng(gp.latitude, gp.longitude),
      "caption": _caption
    };
    await
    FirebaseFirestore.instance.collection('posts').doc().set(post_data);
    setState(() {
      print("Added data: $post_data");
    });
  }










}
