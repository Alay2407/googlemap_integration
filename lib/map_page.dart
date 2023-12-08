import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const CameraPosition _kGoogle = CameraPosition(target: LatLng(21.1702, 72.8311), zoom: 5.0, tilt: 0, bearing: 0);
  final Completer<GoogleMapController> _controller = Completer();

  final List<Marker> _marker = [];
  final List<Marker> _list = [
    const Marker(
      markerId: MarkerId('1'),
      infoWindow: InfoWindow(title: 'This is your 1st location'),
      position: LatLng(21.1702, 72.8311),
    ),
    const Marker(
      markerId: MarkerId('2'),
      infoWindow: InfoWindow(title: 'This is your 2st location'),
      position: LatLng(21.7051, 72.9959),
    ),
    const Marker(
        markerId: MarkerId('5'),
        position: LatLng(21.42796133580664, 79.885749655962),
        infoWindow: InfoWindow(
          title: 'Location 4',
        )),
    const Marker(
        markerId: MarkerId('6'),
        position: LatLng(20.42796133580664, 73.885749655962),
        infoWindow: InfoWindow(
          title: 'Location 5',
        )),
    const Marker(
        markerId: MarkerId('7'),
        position: LatLng(
          37.0902,
          95.7129,
        ),
        infoWindow: InfoWindow(
          title: 'Location 7',
        )),
  ];

  @override
  void initState() {
    _marker.addAll(_list);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Center(
            child: Text(
              'Map View',
            ),
          ),
        ),
        body: GoogleMap(
          markers: Set.of(_list),
          initialCameraPosition: _kGoogle,
          mapType: MapType.normal,
          // compassEnabled: true,
          // myLocationEnabled: true,
          onMapCreated: (controller) {
            _controller.complete(controller);
          },
          myLocationEnabled: false,
          zoomControlsEnabled: true,
          zoomGesturesEnabled: true,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.location_on_outlined),
          onPressed: () async {
            GoogleMapController controller = await _controller.future;
            controller.animateCamera(
              CameraUpdate.newCameraPosition(
                const CameraPosition(
                    target: LatLng(
                      37.0902,
                      95.7129,
                    ),
                    zoom: 10),
              ),
            );
            setState(() {});
          },
        ),
      ),
    );
  }
}
