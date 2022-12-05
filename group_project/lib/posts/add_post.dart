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
import 'package:group_project/models/saved_model.dart';
import 'package:group_project/models/settings_model.dart';
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

  final PostModel _model = PostModel();
  final SavedModel _savedMode = SavedModel();
  final SettingsModel _settingsModel = SettingsModel();

  bool isBusy = false;

  @override
  Widget build(BuildContext context) {
    Geolocator.isLocationServiceEnabled().then((value) => null);
    Geolocator.requestPermission().then((value) => null);
    Geolocator.checkPermission().then((LocationPermission permission) {
      //print("Check Location Permission: $permission");
    });

    if (isBusy) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 10,),
                  Text("Uploading Post...")
                ],
            )
        ),
      );

    }

    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(labelText: "Title:"),
              style: const TextStyle(fontSize: 30),
              onChanged: (post_title) {
                _title = post_title;
              },
            ),
            TextField(
              decoration: InputDecoration(
                  labelText: "Caption"
              ),
              style: TextStyle(fontSize: 30),
              onChanged: (cap) {
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
        onPressed: () {
          setState(() {
            isBusy = true;
          });
          _addToDb().then((value) => Navigator.of(context).pop());
        },
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
    if (_imageURL!=null) {
      print("Image upload successful!");
      Post post_data = Post(
          title: _title,
          imageURL: _imageURL,
          location: LatLng(pos.latitude, pos.longitude),
          caption: _caption
      );
      var ref = await _model.insertPost(post_data);

      bool saveOnPost = await _settingsModel.getBoolSetting(SettingsModel.settingAutoSave)??true;
      if (saveOnPost) {
        post_data.reference = ref;
        await _savedMode.savePost(null, post_data);
      }
      setState(() {
        Navigator.of(context).pop();
      });
    } else {
      print("Failed to upload image!");
    }
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

