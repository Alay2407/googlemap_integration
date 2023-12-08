
import 'package:flutter/material.dart';
import 'package:googlemap_integration/CustomeMarkerInfoWindow.dart';
import 'package:googlemap_integration/customMarker.dart';


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
      home: CustomMarkerInfoWindowScreen(),

    );
  }
}
