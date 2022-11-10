import 'package:flutter/material.dart';

class MapView extends StatefulWidget {
  final String? title;
  const MapView({Key? key, this.title}) : super(key: key);

  @override
  State<MapView> createState() => _MapView();
}

class _MapView extends State<MapView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [
        IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_sharp)),
      ]), //TODO: Remove back button in final release
      body: Text("demo text"),
    );
  }
}
