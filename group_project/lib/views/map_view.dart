import 'dart:math';

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
  var zoomValue = 14.0;

  static const double maxZoom = 18;
  static const double minZoom = 5;

  final PostModel _postModel = PostModel();
  final SavedModel _savedModel = SavedModel();

  Future<void> _showPost(Post post) async {
    await Navigator.pushNamed(context, "/postView", arguments: post);
    setState(() {});
  }

  void _centerOverUser() async {
    Position pos = await Geolocator.getCurrentPosition();

    //Make sure it doesn't still try to center if you've already navigated away.
    bool? done = await mapController.mapEventSink.done;
    if (done != null && done) {
      mapController.move(
          LatLng(pos.latitude, pos.longitude), mapController.zoom);
    }
  }

  @override
  void initState() {
    super.initState();
    _centerOverUser();
  }

  Future<List<Post>> _getAllVisiblePosts() async {
    List<Post> allPosts = await _postModel.getAllPostsList();

    for (int i = 0; i < allPosts.length; ++i) {
      if (await _savedModel.isPostHidden(null, allPosts[i].reference!.id)) {
        allPosts.removeAt(i);
        --i;
      }
    }

    return allPosts;
  }

  @override
  Widget build(BuildContext context) {
    Geolocator.isLocationServiceEnabled().then((value) => null);
    Geolocator.requestPermission().then((value) => null);
    Geolocator.checkPermission().then((LocationPermission permission) {
      //print("Check Location Permission: $permission");
    });

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
                  center: AppConstants.defaultLocation,
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
                        point: snapshot.data![i].location ??
                            AppConstants.defaultLocation,
                        builder: (context) => IconButton(
                            onPressed: (() => _showPost(snapshot.data![i])),
                            iconSize: 45,
                            icon: const Icon(
                              Icons.location_pin,
                              color: Colors.blue,
                            )),
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
            onPressed: _centerOverUser,
            child: const Icon(Icons.gps_fixed_rounded),
          ),
        ),

        // this button is placed on the map and allows user to zoom into the map
        Positioned(
          top: 20,
          right: 0,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(shape: const CircleBorder()),
            onPressed: () {
              zoomValue = min(zoomValue+0.2, maxZoom);
              mapController.move(AppConstants.defaultLocation, zoomValue);
            },
            child: const Icon(Icons.zoom_in),
          ),
        ),

        // this button is placed on the map and allows user to zoom out of the map
        Positioned(
          top: 20,
          right: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(shape: const CircleBorder()),
            onPressed: () {
              zoomValue = max(zoomValue-0.2, minZoom);
              mapController.move(AppConstants.defaultLocation, zoomValue);
            },
            child: const Icon(Icons.zoom_out),
          ),
        ),
      ],
    );
  }
}
