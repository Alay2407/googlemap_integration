import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GetLocationPage extends StatefulWidget {
  const GetLocationPage({super.key});

  @override
  State<GetLocationPage> createState() => _GetLocationPageState();
}

class _GetLocationPageState extends State<GetLocationPage> {
  String address = '';

  final Completer<GoogleMapController> _controller = Completer();

  Future<Position> _getUserCurrentLocation() async {
    await Geolocator.requestPermission().then((value) {}).onError((error, stackTrace) {
      print(error.toString());
    });

    return await Geolocator.getCurrentPosition();
  }

  final List<Marker> _markers = <Marker>[];

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(21.1702, 72.8311),
    zoom: 14,
  );

  List<Marker> list = const [
    Marker(
      markerId: MarkerId('1'),
      position: LatLng(21.1702,72.8311),
      infoWindow: InfoWindow(
        title: 'some Info ',
      ),
    ),
  ];

  @override
  void initState() {

    super.initState();
    _markers.addAll(list);
    // loadData();
  }

  // loadData() {
  //   _getUserCurrentLocation().then((value) async {
  //     _markers.add(Marker(markerId: const MarkerId('3'), position: LatLng(value.latitude, value.longitude), infoWindow: InfoWindow(title: address)));
  //
  //     final GoogleMapController controller = await _controller.future;
  //     CameraPosition _kGooglePlex = CameraPosition(
  //       target: LatLng(value.latitude, value.longitude),
  //       zoom: 14,
  //     );
  //     controller.animateCamera(CameraUpdate.newCameraPosition(_kGooglePlex));
  //     setState(() {});
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
        title: const Text('Flutter Google Map'),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              myLocationEnabled: true,
              initialCameraPosition: _kGooglePlex,
              mapType: MapType.normal,
              markers: Set<Marker>.of(_markers),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    _getUserCurrentLocation().then((value) async {
                      _markers.add(Marker(markerId: const MarkerId('3'), position: LatLng(value.latitude, value.longitude), infoWindow: InfoWindow(title: address)));
                      final GoogleMapController controller = await _controller.future;

                      CameraPosition _kGooglePlex = CameraPosition(
                        target: LatLng(value.latitude, value.longitude),
                        zoom: 8,
                      );
                      controller.animateCamera(CameraUpdate.newCameraPosition(_kGooglePlex));

                      List<Placemark> placemarks = await placemarkFromCoordinates(value.latitude, value.longitude);

                      final add = placemarks.first;
                      address = add.locality.toString() + " " + add.administrativeArea.toString() + " " + add.subAdministrativeArea.toString() + " " + add.country.toString();

                      setState(() {});
                    });
                  },
                  child: const Text(
                    'Get current loction',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
