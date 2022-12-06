import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:group_project/camera/camera.dart';
import 'package:group_project/constants.dart';
import 'package:group_project/models/db_utils.dart';
import 'package:group_project/views/add_post.dart';
import 'package:group_project/views/home_page.dart';
import 'package:group_project/views/map_view.dart';
import 'package:group_project/views/post_view.dart';

import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_i18n/flutter_i18n_delegate.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key,});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print("Error initialising Firebase!");
        }
        if (snapshot.connectionState == ConnectionState.done) {
          print ("Successfully connected to Firebase");
          return MaterialApp(
              title: 'Group Project',
              theme: ThemeData(
                primarySwatch: Colors.blue,
              ),
              home: const HomePage(), //TODO change to map in final release
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
              },
              localizationsDelegates: [
                FlutterI18nDelegate(
                  missingTranslationHandler: (key,locale){
                    print("MISSING KEY: $key, Language Code: ${locale!.languageCode}");
                  },
                  translationLoader: FileTranslationLoader(
                      useCountryCode: true,
                      fallbackFile: 'en_US',
                      basePath: 'assets/i18n'
                  ),
                ),
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en', 'US'),
                Locale('en', 'UK'),
                Locale('fr', 'FR'),
              ],
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );

  }
}