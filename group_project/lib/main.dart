import 'package:flutter/material.dart';

import 'package:group_project/constants.dart';
import 'package:group_project/posts/add_post.dart';
import 'package:group_project/views/map_view.dart';
import 'package:group_project/views/post_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Group Project',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const DevPage(
            title: 'DEVPAGE'
        ), //TODO change to map in final release
        routes: {
          '/mapView': (context) {
            return const MapView();
          },
          '/postView': (context) {
            return const PostView();
          },
          '/addPost': (context) {
            return const AddPost();
          },
        });
  }
}

class DevPage extends StatefulWidget {
  const DevPage({super.key, required this.title});

  final String title;

  @override
  State<DevPage> createState() => _DevPageState();
}

class _DevPageState extends State<DevPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'DEVPAGE',
            ),
            ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, "/mapView"),
                child: const Text("Go to map view")
            ),
            ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, "/postView"),
                child: const Text("Go to post view")
            ),
            ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, "/addPost"),
                child: const Text("Go to add post screen")
            ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
