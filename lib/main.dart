
import 'package:flutter/material.dart';
import 'package:googlemap_integration/CustomeMarkerInfoWindow.dart';
import 'package:googlemap_integration/covertion_page.dart';
import 'package:googlemap_integration/customMarker.dart';
import 'package:googlemap_integration/getLocationPage.dart';
import 'package:googlemap_integration/map_page.dart';
import 'package:googlemap_integration/searchPlaces.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Map view',
      theme: ThemeData(primarySwatch: Colors.green),
      home:
      const GetLocationPage(),

    );
  }
}
