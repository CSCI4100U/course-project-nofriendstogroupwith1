import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'constants.dart';

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
      body: Stack(
        children: [
          FlutterMap(
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
            ],
          ),
        ],
      ),
    );
  }
}
