import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:group_project/models/post.dart';
import 'package:group_project/models/post_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:group_project/constants.dart';

class MapView extends StatefulWidget {
  const MapView({Key? key}) : super(key: key);

  @override
  State<MapView> createState() => _MapView();
}

class _MapView extends State<MapView> {
  late List<Post> posts;

  void _showPost(DocumentReference reference) {
    //TODO move to post_view
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(), //Note: The back button is automatically added by Navigator.push()
      body: Stack(
        children: [
          FutureBuilder(
              future: PostModel().getAllPostsList(),
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

                //Main screeen
                return FlutterMap(
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
                          height: 80,
                          width: 80,
                          point: snapshot.data![i].location ??
                              AppConstants.defaultLocation,
                          builder: (context) => IconButton(
                              onPressed: (() =>
                                  _showPost(snapshot.data![i].reference!)),
                              icon: Icon(
                                Icons.location_pin,
                                color: Colors.blue,
                                size: 45,
                              )),
                        )
                    ])
                  ],
                );
              }))
        ],
      ),
    );
  }
}
