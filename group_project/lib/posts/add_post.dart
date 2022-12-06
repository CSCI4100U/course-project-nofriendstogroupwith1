import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:group_project/camera/camera.dart';
import 'package:group_project/constants.dart';

import 'package:geolocator/geolocator.dart';
import 'package:group_project/models/post.dart';
import 'package:group_project/models/post_model.dart';
import 'package:latlong2/latlong.dart';

import 'dart:io';
import 'dart:async';

import "package:uuid/uuid.dart";

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

  int? _dateTime;

  PostModel _model = PostModel();

  @override
  Widget build(BuildContext context) {
    Geolocator.isLocationServiceEnabled().then((value) => null);
    Geolocator.requestPermission().then((value) => null);
    Geolocator.checkPermission().then((LocationPermission permission) {
      //print("Check Location Permission: $permission");
    });

    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(labelText: "Title:"),
              style: TextStyle(fontSize: 30),
              onChanged: (post_title) {
                _title = post_title;
              },
            ),
            TextField(
              decoration: InputDecoration(labelText: "Caption"),
              style: TextStyle(fontSize: 30),
              onChanged: (cap) {
                _caption = cap;
              },
            ),
            Container(
                child: _imagePath != null
                    ? Image.file(File(_imagePath!))
                    : //Text("Yes pic"):
                    Text("no pic") //Image.file(File(widget.imagePath!)),
                ),
            ElevatedButton(onPressed: takepic, child: const Text("Take a pic")),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: userConfirmation,
        tooltip: "Add",
        child: const Icon(Icons.add),
      ),
    );
  }

  Future _addToDb() async {
    print("Adding a new entry...");

    Position pos = await Geolocator.getCurrentPosition();
    final uuid = Uuid();
    _imageURL = await uploadPhoto(uuid.v1(), File(_imagePath!));
    if (_imageURL != null) {
      print("Image upload successful!");
      Post post_data = Post(
          title: _title,
          imageURL: _imageURL,
          dateTime: _dateTime,
          location: LatLng(pos.latitude, pos.longitude),
          caption: _caption);

      await _model.insertPost(post_data);

      // snackbar to tell user the post is created
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
          "Post Created",
          style: TextStyle(fontSize: 14),
        )),
      );
      Navigator.pop(context);
    } else {
      print("Failed to upload image!");
    }
  }

// this method is used to confirm information inputed by the user before creating the post
  Future userConfirmation() async {
    var confirmation = await showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text(
                "Is the following information correct?\n\n Title: $_title\n Caption: $_caption"),
            children: [
              SimpleDialogOption(
                child: const Text("Yes"),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
              SimpleDialogOption(
                child: const Text("No"),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
            ],
          );
        });

    print("User confirmation of post: $confirmation");

    if (confirmation == true) {
      _addToDb();
    } else {
      confirmation == false;
    }

    return confirmation;
  }

  Future<String?> uploadPhoto(String name, File file) async {
    final storageRef = FirebaseStorage.instance.ref();
    final photoRef = storageRef.child("images/$name.jpg");

    try {
      await photoRef.putFile(file);

      return photoRef.getDownloadURL();
    } catch (e) {
      print(e);
    }
  }

  Future<void> takepic() async {
    WidgetsFlutterBinding.ensureInitialized();
    //get a list of all cameras on the device
    final cameras = await availableCameras();

    _dateTime = DateTime.now().millisecondsSinceEpoch;

    var result = await Navigator.of(context).push(
        MaterialPageRoute(builder: (context) {
            return Camera(cameras: cameras);
          }
        ),
    );

    if (result != null && result is String) {
      _imagePath = result;
    }

    setState(() {});
  }
}
