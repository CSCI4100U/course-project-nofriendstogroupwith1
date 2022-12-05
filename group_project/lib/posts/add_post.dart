import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:group_project/camera/camera.dart';
import 'package:group_project/constants.dart';

import 'package:group_project/models/post.dart';
import 'package:group_project/models/post_model.dart';
import 'package:latlong2/latlong.dart';

import 'dart:io';
import 'dart:async';

class AddPost extends StatefulWidget {
  const AddPost({Key? key}) : super(key: key);

  @override
  State<AddPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  String? _title;
  String? _imageURL;
  String? _caption;

  String? _imagePath;

  PostModel _model = PostModel();

  @override
  Widget build(BuildContext context) {
    var y;
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
            Container( 
                child: _imagePath != null?
                Image.file(File(_imagePath!))://Text("Yes pic"):
                Text("no pic") //Image.file(File(widget.imagePath!)),
            ),
            ElevatedButton(
                onPressed: takepic,
                child: const Text("Take a pic")
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

  Future<void> takepic() async {
    WidgetsFlutterBinding.ensureInitialized();
    //get a list of all cameras on the device
    final cameras = await availableCameras();
    // Get a specific camera from the list of available cameras.
    //final firstCamera = cameras.first;

    //runApp(Camera(cameras: cameras,));
    /*runApp(MaterialApp(
      theme: ThemeData.dark(),
      home: Camera(
      //pass the cameras list to the next widget
        cameras: cameras,
      ),
    )
  );*/
    var result = await Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return Camera(cameras: cameras);
    }));

    if (result!=null && result is String) {
      _imagePath = result;
    }

    setState(() {

    });
  }

}

