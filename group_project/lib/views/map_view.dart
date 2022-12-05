import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
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
  final mapController = MapController();
  bool init = false;

  final PostModel _postModel = PostModel();
  final SavedModel _savedModel = SavedModel();

  Future<void> _showPost(Post post) async {
    await Navigator.pushNamed(context, "/postView", arguments: post);
    setState(() {

    });
  }

  void _centerOverUser() async {
    Position pos = await Geolocator.getCurrentPosition();
    mapController.move(LatLng(pos.latitude, pos.longitude), mapController.zoom);
  }

  void _createPost() {
    Navigator.pushNamed(context, "/addPost");
  }

  @override
  Widget build(BuildContext context) {
    Geolocator.isLocationServiceEnabled().then((value) => null);
    Geolocator.requestPermission().then((value) => null);
    Geolocator.checkPermission().then((LocationPermission permission) {
      //print("Check Location Permission: $permission");
    });

    //Get current gps position for map initialization
    if (!init) {
      Geolocator.getCurrentPosition().then((value) {
        mapController.move(
            LatLng(value.latitude, value.longitude), mapController.zoom);
      });
      init = true;
    }

    Future<List<Post>> _getAllVisiblePosts() async {
      List<Post> allPosts = await _postModel.getAllPostsList();

      for (int i = 0; i < allPosts.length; ++i) {
        if (await _savedModel.isPostHidden(null, allPosts[i].reference!.id)) {
          //allPosts.removeAt(i);
        }
      }

      return allPosts;
    }

    return Scaffold(
        appBar:
            AppBar(), //Note: The back button is automatically added by Navigator.push()
        body: Stack(
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
                      minZoom: 5,
                      maxZoom: 18,
                      zoom: 13,
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
                }))
          ],
        ),
        floatingActionButton: Wrap(children: [
          FloatingActionButton(
            heroTag: "center",
            onPressed: _centerOverUser,
            child: Icon(Icons.gps_fixed_rounded),
          ),
          FloatingActionButton(
              heroTag: "add", onPressed: _createPost, child: Icon(Icons.add))
        ]));
  }
}
