import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:group_project/camera/camera.dart';
import 'package:group_project/constants.dart';
import 'package:group_project/dev_tools/post_test_list.dart';
import 'package:group_project/models/db_utils.dart';
import 'package:group_project/posts/add_post.dart';
import 'package:group_project/views/home_page.dart';
import 'package:group_project/views/map_view.dart';
import 'package:group_project/views/post_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key,});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print("Error initialising Firebase!");
        }
        if (snapshot.connectionState == ConnectionState.done) {
          print ("Successfully connected to Firebase");
          return MaterialApp(
              title: 'Group Project',
              theme: ThemeData(
                primarySwatch: Colors.blue,
              ),
              home: const HomePage(), //TODO change to map in final release
              routes: {
                '/dev' : (context) {
                  return const DevPage();
                },
                '/mapView': (context) {
                  return const MapView();
                },
                '/postView': (context) {
                  return const PostView();
                },
                '/addPost': (context) {
                  return const AddPost();
                },
                /*
                '/camera': (context) {
                  return const Camera(cameras: camera,);
                },*/
                //TODO: remove this page and associated files for later
                '/devTestPostList': (context) {
                  return const PostTestList();
                },
              },
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );

  }
}

class DevPage extends StatefulWidget {
  const DevPage({super.key});

  @override
  State<DevPage> createState() => _DevPageState();
}

class _DevPageState extends State<DevPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DEVPAGE'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'DEVPAGE',
            ),
            ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, "/home"),
                child: const Text("Go to home Page")
            ),
            ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, "/postView"),
                child: const Text("Go to post view")
            ),
            ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, "/addPost"),
                child: const Text("Go to add post screen")
            ),
            ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, "/devTestPostList"),
                child: const Text("Go to post test list")
            ),
            ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, "/camera"),
                child: const Text("Go to post test list")
            ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
