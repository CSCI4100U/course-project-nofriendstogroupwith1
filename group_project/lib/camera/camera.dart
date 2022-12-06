import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'dart:async';

import 'package:group_project/posts/add_post.dart';

class Camera extends StatefulWidget {
  const Camera({Key? key, required this.cameras}) : super(key: key);
  final List<CameraDescription> cameras;

  @override
  State<Camera> createState() => _CameraState();
}

class _CameraState extends State<Camera> {

  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  int cameraNumber = 0;

  @override
  void initState(){
    super.initState();

    //To display the output from the camera,
    //create a camera controller
    _controller = CameraController(
        //a specific camera from the list of available ones
        widget.cameras[cameraNumber],
        ResolutionPreset.max,
        enableAudio: false,
    );

    //initialize the controller, this returns a future
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose(){
    //dispose of the controller when one disposes the widget
    _controller.dispose();
    super.dispose();
  }

  Widget _buildCameraScreen() {
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // If the Future is complete, display the preview.

          final double statusBarHeight = MediaQuery.of(context).padding.top;

          return Expanded(
            child: Stack(
              alignment: Alignment.topLeft,
              children: [
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: statusBarHeight),
                    child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          CameraPreview(_controller),
                          SizedBox(
                            height: 100,
                            child: ElevatedButton(
                                onPressed: () async {
                                  //try / catch taking the picture
                                  try{
                                    //check that the camera is initialized
                                    await _initializeControllerFuture;

                                    //take the picture and get an 'image'
                                    //of where it is saved on the device
                                    final image = await _controller.takePicture();

                                    if(!mounted) return;

                                    //if the picture was taken, display on a new screen
                                    Navigator.of(context).pop(image.path);

                                  } catch(e){
                                    print(e);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                    shape: const CircleBorder(),
                                    fixedSize: const Size(60, 60),
                                    backgroundColor: const Color.fromARGB(30, 255, 255, 255)
                                ),
                                child: const Icon(Icons.camera, size: 30,)
                            ),
                          ),
                        ],
                      ),
                  ),
                ),
                /*
                AppBar(
                  title: const Text("Take a picture!"),
                  backgroundColor: Colors.transparent,
                  actions: [
                    IconButton(onPressed: () {
                      //'hacky' way to toggle between exactly 2 cameras
                      cameraNumber = 1-cameraNumber;
                      onNewCameraSelected(widget.cameras[cameraNumber]);
                    }, icon: const Icon(Icons.sync))
                  ],
                )*/
                Container(
                  padding: EdgeInsets.only(top: statusBarHeight),
                  decoration: const BoxDecoration(color: Color.fromARGB(50, 0, 0, 0)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          onPressed: (){
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.arrow_back, color: Colors.white,)
                      ),
                      const Text("Take a photo!", style: TextStyle(color: Colors.white)),
                      IconButton(
                          onPressed: (){
                            //'hacky' way to toggle between exactly 2 cameras
                            cameraNumber = 1-cameraNumber;
                            onNewCameraSelected(widget.cameras[cameraNumber]);
                            },
                          icon: const Icon(Icons.sync, color: Colors.white,)
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          // Otherwise, display a loading indicator.
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Column(
          children: [_buildCameraScreen()],
        ),
      ),
    );
    /*return Scaffold(
      appBar: AppBar(title: const Text("Take a Picture"),
        actions: [
          IconButton(
              onPressed: (){
                //'hacky' way to toggle between exactly 2 cameras
                cameraNumber = 1-cameraNumber;
                onNewCameraSelected(widget.cameras[cameraNumber]);
              },
              icon: Icon(Icons.camera)
          ),
        ],
      ),
      //use a futurebuilder so that the screen doesnt show anything
      //until the camera is initialized
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot){
          if (snapshot.connectionState == ConnectionState.done){
            //if the future is complete, show the preview
            return CameraPreview(_controller);
          } else{
            return const Center(child: CircularProgressIndicator(),);
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.camera_alt),
        onPressed: () async {
          //try / catch taking the picture
          try{
            //check that the camera is initialized
            await _initializeControllerFuture;

            //take the picture and get an 'image'
            //of where it is saved on the device
            final image = await _controller.takePicture();

            if(!mounted) return;

            //if the picture was taken, display on a new screen
            Navigator.of(context).pop(image.path);

          } catch(e){
            print(e);
          }
        },
      ),
    );*/
  }
  void onNewCameraSelected (CameraDescription cameraDescription) async {
    final previousCameraController = _controller;
    //instantiate a new camera controller
    final CameraController cameraController = CameraController(
        cameraDescription,
        ResolutionPreset.high,
        imageFormatGroup: ImageFormatGroup.jpeg
    );

    //dispose of the previous controller
    await previousCameraController.dispose();
    if (mounted) {
      setState(() {
        _controller = cameraController;
      });
    }

    //when the mounted state changes, update the UI
    cameraController.addListener(() {
      if (mounted) setState(() {

      });
    });

    try{
      await cameraController.initialize();
    } catch(e){
      print (e);
    }
  }
}