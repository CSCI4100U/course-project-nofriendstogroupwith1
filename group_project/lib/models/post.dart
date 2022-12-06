import 'dart:math';

import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'settings_model.dart';

class Post {
  String? title;
  String? imageURL;
  LatLng? location;

  String? caption;

  int? dateTime;

  DocumentReference? reference;
  String? documentID;

  DateTime GetTimeAsDateTime() {
    return DateTime.fromMillisecondsSinceEpoch(dateTime!);
  }

  Future<String> GetTimeAsString() async {
    bool twelveHour = await SettingsModel().getBoolSetting(SettingsModel.setting12Hour)??false;
    DateTime timeStamp = DateTime.fromMillisecondsSinceEpoch(dateTime!);
    DateTime now = DateTime.now();

    int hour = timeStamp.hour;
    String ampm = "";
    if (twelveHour) {
      if (hour>12) {
        hour-=12;
        ampm="pm";
      } else {
        ampm="am";
      }
    }

    String minuteText = timeStamp.minute.toString();
    if (minuteText.length==1) {
      minuteText += "0";
    }
    //If a different year, provide full date
    if (now.year!=timeStamp.year) {

      return "${timeStamp.year}-${timeStamp.month}-${timeStamp.day} $hour:$minuteText$ampm";
    }
    //If same day, provide hours since
    else if (now.month==timeStamp.month && now.day==timeStamp.day) {
      int minutesPast = (now.hour*60+now.minute)-(timeStamp.hour*60+timeStamp.minute);
      int hoursPast = minutesPast~/60;
      minutesPast%=60;
      if (hoursPast==0) {
        return "$minutesPast minutes ago.";
      }
      return "$hoursPast hours, $minutesPast minutes ago.";
    }
    //Otherwise show month-day hour:minute
    return "${timeStamp.month}-${timeStamp.day} $hour:$minuteText$ampm";
  }

  Post({this.title, this.imageURL, this.location, this.caption, this.dateTime, this.documentID});

  Post.fromMap(var map, {this.reference}) {
    title = map['title'];
    imageURL = map['imageURL'];
    caption = map['caption'];
    
    dateTime = map['dateTime'];
    print("Test");

    GeoPoint gp = map['location'];
    location = LatLng(gp.latitude, gp.longitude);
  }

  Map<String, Object?> toMap() {
    return {
      'title': title,
      'imageURL': imageURL,
      'location': GeoPoint(location!.latitude, location!.longitude),
      'dateTime': dateTime,
      'caption': caption,
    };
  }
}