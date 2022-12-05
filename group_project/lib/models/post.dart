import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  String? title;
  String? imageURL;
  LatLng? location;

  String? caption;

  DocumentReference? reference;
  String? documentID;

  Post({this.title, this.imageURL, this.location, this.caption, this.documentID});

  Post.fromMap(var map, {this.reference}) {
    title = map['title'];
    imageURL = map['imageURL'];
    caption = map['caption'];

    GeoPoint gp = map['location'];
    location = LatLng(gp.latitude, gp.longitude);
  }

  Map<String, Object?> toMap() {
    return {
      'title': title,
      'imageURL': imageURL,
      'location': GeoPoint(location!.latitude, location!.longitude),
      'caption': caption,
    };
  }
}