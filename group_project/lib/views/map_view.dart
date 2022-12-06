import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:group_project/models/post.dart';
import 'package:group_project/models/post_model.dart';
import 'package:group_project/constants.dart';
import 'package:geolocator/geolocator.dart';
import 'package:group_project/models/saved_model.dart';
import 'package:latlong2/latlong.dart';

class MapView extends StatefulWidget {
  const MapView({Key? key}) : super(key: key);

  @override
  State<MapView> createState() => _MapView();
}

class _MapView extends State<MapView> {
  late List<Post> posts;
  final MapController mapController = MapController();
  var zoomValue = 16.0;

  static const double maxZoom = 18;
  static const double minZoom = 5;

  final PostModel _postModel = PostModel();
  final SavedModel _savedModel = SavedModel();

  Future<void> _showPost(Post post) async {
    bool? hideFromMap =
        await Navigator.pushNamed(context, "/postView", arguments: post)
            as bool;
    if (hideFromMap != null && hideFromMap) {
      //Instantly remove a hidden post from the map while waiting for the updated list.
      posts.remove(post);
    }
    setState(() {});
  }

  Position? streamedPosition;
  void updatePosition(Position? position) {
    streamedPosition = position;
  }

  StreamSubscription? subscription;

  @override
  void initState() {
    super.initState();

    Geolocator.isLocationServiceEnabled().then((value) {
      Geolocator.requestPermission().then((value) {
        Geolocator.checkPermission().then((value) {
          subscription ??=
              Geolocator.getPositionStream().listen(updatePosition);
        });
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (subscription != null) {
      subscription!.cancel();
      subscription = null;
    }
  }

  void _centerOverUser() {
    //Try using streamedPosition
    if (streamedPosition != null) {
      mapController.move(
          LatLng(streamedPosition!.latitude, streamedPosition!.longitude),
          mapController.zoom);
      ScaffoldMessenger.of(context)
          .clearSnackBars(); //Clear existing snackbars so this one feels snappier.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
          "Map Centered",
          style: TextStyle(fontSize: 14),
        )),
      );
      //Otherwise fall back to asking for a current location.
    }
  }

  late Position currentPosition;

  Future<List<Post>> _getAllVisiblePosts() async {
    await Geolocator.isLocationServiceEnabled();
    await Geolocator.requestPermission();
    await Geolocator.checkPermission();

    subscription ??= Geolocator.getPositionStream().listen(updatePosition);

    currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);

    List<Post> allPosts = await _postModel.getAllPostsList();

    for (int i = 0; i < allPosts.length; ++i) {
      if (await _savedModel.isPostHidden(null, allPosts[i].reference!.id)) {
        allPosts.removeAt(i);
        --i;
      }
    }

    posts = allPosts;
    return allPosts;
  }

  Widget _buildMarker(Post post) {
    return GestureDetector(
      onTap: () {
        _showPost(post);
      },
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            border: Border.all(color: Colors.blue, width: 4)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            post.imageURL!,
            fit: BoxFit.fill,
            errorBuilder: (context, error, stackTrace) => (Container()),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FutureBuilder(
            future: _getAllVisiblePosts(),
            builder: ((context, snapshot) {
              if (!snapshot.hasData) {
                //Loading screen
                return Container(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        CircularProgressIndicator(),
                        Text("Loading Posts")
                      ],
                    ));
              }

              //Main screen
              return FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  minZoom: minZoom,
                  maxZoom: maxZoom,
                  zoom: zoomValue,
                  center: LatLng(
                      currentPosition!.latitude, currentPosition!.longitude),
                ),
                layers: [
                  TileLayerOptions(
                    urlTemplate:
                        "https://api.mapbox.com/styles/v1/alexnayl/{mapStyleId}/tiles/256/{z}/{x}/{y}@2x?access_token={accessToken}",
                    additionalOptions: {
                      'mapStyleId': AppConstants.mapBoxStyleId,
                      'accessToken': AppConstants.mapBoxAccessToken,
                    },
                  ),
                  MarkerLayerOptions(rotate: true, markers: [
                    //post icons
                    for (int i = 0; i < snapshot.data!.length; i++)
                      Marker(
                        height: 60,
                        width: 60,
                        point: snapshot.data![i].location ??
                            AppConstants.defaultLocation,
                        builder: (context) => _buildMarker(snapshot.data![i]),
                        /*builder: (context) => IconButton(
                            onPressed: (() => _showPost(snapshot.data![i])),
                            iconSize: 45,
                            icon: const Icon(
                              Icons.location_pin,
                              color: Colors.blue,
                            )),*/
                      )
                  ])
                ],
              );
            })),
        Positioned(
          bottom: 20,
          right: 20,
          height: 60,
          width: 60,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(shape: const CircleBorder()),
            onPressed: () {
              _centerOverUser();
            },
            child: const Icon(Icons.gps_fixed_rounded),
          ),
        ),

        // this button is placed on the map and allows user to zoom into the map
        Positioned(
          bottom: 150,
          right: 0,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(shape: const CircleBorder()),
            onPressed: () {
              zoomValue = mapController.zoom;
              zoomValue = min(zoomValue += 0.2, maxZoom);
              mapController.move(mapController.center, zoomValue);
            },
            child: const Icon(Icons.zoom_in),
          ),
        ),

        // this button is placed on the map and allows user to zoom out of the map
        Positioned(
          bottom: 100,
          right: 0,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(shape: const CircleBorder()),
            onPressed: () {
              zoomValue = mapController.zoom;
              zoomValue = max(zoomValue -= 0.2, minZoom);
              mapController.move(mapController.center, zoomValue);
            },
            child: const Icon(Icons.zoom_out),
          ),
        ),
      ],
    );
  }
}
