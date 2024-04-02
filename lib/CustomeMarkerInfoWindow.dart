import 'dart:ui' as ui;

import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomMarkerInfoWindowScreen extends StatefulWidget {
  const CustomMarkerInfoWindowScreen({super.key});

  @override
  State<CustomMarkerInfoWindowScreen> createState() => _CustomMarkerInfoWindowScreenState();
}

class _CustomMarkerInfoWindowScreenState extends State<CustomMarkerInfoWindowScreen> {
  final CustomInfoWindowController _customInfoWindowController = CustomInfoWindowController();
  final List<LatLng> _latlngs = [
    const LatLng(26.907524, 75.739639),
    const LatLng(24.879999, 74.629997),
    const LatLng(28.679079, 77.069710),
  ];
  final LatLng _latLng = const LatLng(23.0225, 72.5714);
  final double _zoom = 6.0;
  final Set<Marker> _markers = {};
  List<String> images = [
    'images/car.png',
    'images/motorcycle.png',
    'images/motorcycle.png',
  ];
  Uint8List? markerImage;
  //
  // Future<Uint8List> getBytesFromAsset(String path, int width) async {
  //   ByteData data = await rootBundle.load(path);
  //   ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
  //   ui.FrameInfo fi = await codec.getNextFrame();
  //   return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  // }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {
    for (int i = 0; i <= _latlngs.length; i++) {
      // print('name' + images[i].toString());
      // final Uint8List markerIcon = await getBytesFromAsset(
      //   images[i].toString(),
      //   100,
      // );
      _markers.add(
        Marker(
          markerId: MarkerId(
            i.toString(),
          ),
          position: _latlngs[i],
          // icon: BitmapDescriptor.fromBytes(markerIcon),
          icon: BitmapDescriptor.defaultMarker,
          onTap: () {
            _customInfoWindowController.addInfoWindow!(
              Column(
                children: [
                  Container(
                    width: 300,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 300,
                          height: 100,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(
                                'https://media.tacdn.com/media/attractions-splice-spp-674x446/0b/2d/01/6e.jpg',
                              ),
                              fit: BoxFit.fitWidth,
                              filterQuality: FilterQuality.high,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                            color: Colors.red,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 10, left: 10, right: 10),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 100,
                                child: Text(
                                  'Jaipur',
                                  maxLines: 1,
                                  overflow: TextOverflow.fade,
                                  softWrap: false,
                                ),
                              ),
                              Spacer(),
                              Text(
                                '.3 mi.',
                                // widget.data!.date!,
                              )
                            ],
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 10, left: 10, right: 10),
                          child: Text(
                            'Help me finish these tacos! I got a platter from Costco and it’s too much.',
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              _latlngs[i],
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Stack(
          children: [
            GoogleMap(
              markers: _markers,
              ///For Initial camera position
              initialCameraPosition: CameraPosition(
                target: _latLng,
                zoom: _zoom,
              ),

              ///When map is loaded at that time view
              onMapCreated: (GoogleMapController controller) async {
                _customInfoWindowController.googleMapController = controller;
              },


              ///During moving camera view
              onCameraMove: (position) {
                _customInfoWindowController.onCameraMove!();
              },
              onTap: (argument) {
                _customInfoWindowController.hideInfoWindow!();
              },
            ),
            CustomInfoWindow(
              controller: _customInfoWindowController,
              height: 200,
              width: 300,
              offset: 35,
            ),
          ],
        )
      ]),
    );
  }
}
