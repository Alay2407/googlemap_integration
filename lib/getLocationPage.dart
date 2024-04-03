import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:googlemap_integration/permission_manager.dart';
import 'package:googlemap_integration/searchPlaces.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as permission;

import 'enum.dart';

class GetLocationPage extends StatefulWidget {
  double? lat;
  double? long;
  GetLocationPage({this.lat, this.long});

  @override
  State<GetLocationPage> createState() => _GetLocationPageState();
}

class _GetLocationPageState extends State<GetLocationPage> with WidgetsBindingObserver {
  LocationData? currentLocation;
  permission.PermissionStatus? _permissionStatus;
  LatLng _initialPosition = LatLng(0, 0);
  String address = '';
  late Location location;
  final Completer<GoogleMapController> _controller = Completer();
  Future<Position> _getUserCurrentLocation() async {
    await Geolocator.requestPermission().then((value) {
    }).onError((error, stackTrace) {
      print(error.toString());
    });

    return await Geolocator.getCurrentPosition();
  }

  final List<Marker> _markers = <Marker>[];
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(21.1702, 72.8311),
    zoom: 8 ,
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

  Geolocator geolocator = Geolocator();

  // ///This is for permission handler for check permission:
  // Future<void> _checkLocationPermission() async {
  //   permission.PermissionStatus status = await permission.Permission.location.status;
  //   print("Permission status is ==> $status");
  //   setState(() {
  //     _permissionStatus = status;
  //   });
  //   if (!_permissionStatus.isGranted) {
  //
  //     await _requestLocationPermission();
  //   } else {
  //     _getCurrentLocation();
  //   }
  // }
  // Future<Position> _requestLocationPermission() async {
  //   print("Inside location permission");
  //   permission.PermissionStatus status = await permission.Permission.location.request();
  //   print("Inside location && status is===>  $status");
  //
  //   setState(() {
  //     _permissionStatus = status;
  //   });
  //   if (_permissionStatus.isGranted) {
  //     _getCurrentLocation();
  //   }
  //   return Geolocator.getCurrentPosition();
  // }
  // void _getCurrentLocation() {
  //   print("Inside get current location");
  //
  //   // Retrieve current location and update _initialPosition
  //   // You can use Geolocator or any other method to get the current location
  //   // For this example, we'll set an initial position to (0, 0)
  //   setState(() {
  //     _initialPosition = LatLng(0, 0);
  //   });
  // }

  Future<void> _checkLocationPermission() async {
    permission.PermissionStatus status = await permission.Permission.location.status;
    setState(() {
      _permissionStatus = status;
    });
    if (_permissionStatus == PermissionStatus.denied || _permissionStatus == PermissionStatus.deniedForever) {
      _requestLocationPermission();
    }
  }

  Future<void> _requestLocationPermission() async {
    permission.PermissionStatus status = await permission.Permission.location.request();
    setState(() {
      _permissionStatus = status;
    });
  }

  void _openAppSettings() {
    permission.openAppSettings();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    ///This is a permission handler for checking permission first:
    RequestPermissionManager(PermissionType.whenInUseLocation).onPermissionDenied(() {
      // Handle permission denied for location
      print('Location permission denied');
      setState(() {
        _permissionStatus = permission.PermissionStatus.denied;
      });
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>PermissionDeniedWidget(openAppSettings: _openAppSettings),));
    }).onPermissionGranted(() {
      // Handle permission granted for location.
      setState(() {
        _permissionStatus = permission.PermissionStatus.granted;
      });
      print('Location permission granted');
    }).onPermissionPermanentlyDenied(() {
      // Handle permission permanently denied for location
      print('Location permission permanently denied');
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>PermissionDeniedWidget(openAppSettings: _openAppSettings),));
      setState(() {
        _permissionStatus = permission.PermissionStatus.permanentlyDenied;
      });
    }).execute();

    // _checkLocationPermission();
    location = Location();

    ///This for listen on Location change
    // location.onLocationChanged.listen((LocationData cLoc) {
    //   // cLoc contains the lat and long of the
    //   // current user's position in real time,
    //   // so we're holding on to it
    //   currentLocation = cLoc;
    //   print("Current location is === >${currentLocation}");
    // });
    super.initState();
    _markers.addAll(list);

    // loadData();
    // locationFuc();
    ///This for after couple of minutes it will again call this function for current location
    // Timer.periodic(const Duration(seconds: 10), (Timer timer) {
    //   locationFuc();
    // });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissionStatus();
      print("Widget binding state is ==> Resumed");
    } else {
      print("Widget binding state is ==> ${state.toString()}");
    }
  }

  Future<void> _checkPermissionStatus() async {
    final status = await permission.Permission.location.status;

    if (status != _permissionStatus) {
      setState(() {
        _permissionStatus = status;
      });
      if (status.isDenied) {
        print('Location permission is denied.===>');
      } else if (status.isGranted) {
        print('Location permission is granted.===>');
      } else if (status.isPermanentlyDenied) {
        print('Location permission is permanently denied. Redirect to settings.===> ');
      } else {
        // Handle other cases
        print('Location permission status: $status');
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  //
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
  //
  // locationFuc(){
  //   _getUserCurrentLocation().then((value) async {
  //     print('latitide is==> ${value.latitude} && longtitude is ${value.longitude}');
  //     _markers.add(Marker(markerId: const MarkerId('3'), position: LatLng(widget.lat!, widget.long!), infoWindow: InfoWindow(title: address)));
  //     final GoogleMapController controller = await _controller.future;
  //
  //     CameraPosition _kGooglePlex = CameraPosition(
  //       target: LatLng(widget.lat!, widget.long!),
  //       zoom: 15,
  //     );
  //
  //     controller.animateCamera(CameraUpdate.newCameraPosition(_kGooglePlex));
  //
  //     List<geocoding.Placemark> placemarks = await geocoding.placemarkFromCoordinates(widget.lat!, widget.long!);
  //     final add = placemarks.first;
  //     address = add.locality.toString() + " " + add.administrativeArea.toString() + " " + add.subAdministrativeArea.toString() + " " + add.country.toString();
  //
  //     setState(() {
  //       print(address);
  //     });
  //   });
  // }

  MapType _currentMapType = MapType.normal;

  Future<void> _toggleMapType() async {
    MapType? newMapType = await showModalBottomSheet<MapType>(
      context: context,
      builder: (context) {
        return Container(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.map),
                title: Text('Normal'),
                onTap: () {
                  Navigator.pop(context, MapType.normal);
                },
              ),
              ListTile(
                leading: Icon(Icons.satellite),
                title: Text('Satelite'),
                onTap: () {
                  Navigator.pop(context, MapType.satellite);
                },
              ),
              ListTile(
                leading: Icon(Icons.map_outlined),
                title: Text('Hybrid'),
                onTap: () {
                  Navigator.pop(context, MapType.hybrid);
                },
              ),
            ],
          ),
        );
      },
    );
    if (newMapType != null) {
      setState(() {
        _currentMapType = newMapType;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleMapType,
        child: Icon(Icons.map),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      appBar: AppBar(
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchPlaces(),
                ),
              );
            },
            child: const Icon(
              Icons.search,
            ),
          )
        ],
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
        title: const Text('Flutter Google Map'),
      ),
      body: _permissionStatus == permission.PermissionStatus.granted
          ? SafeArea(
              child: Stack(
                children: [
                  GoogleMap(
                    myLocationButtonEnabled: true,
                    zoomControlsEnabled: true,
                    compassEnabled: true,
              myLocationEnabled: true,
                    // initialCameraPosition: _kGooglePlex,
                    initialCameraPosition: CameraPosition(target: _initialPosition),
                    // mapType: MapType.hybrid,
                    mapType: _currentMapType,
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                    },
                    tiltGesturesEnabled: false,
              onLongPress: (latlang) {
                _addMarkerLongPressed(latlang); //we will call this function when pressed on t
                // he map
              },
              onTap: (LatLng latLng) {
                // Clear markers when tapping on the map
                setState(
                  () {
                    markers.clear();
                  },
                );
              },
              // markers: Set<Marker>.of(_markers),
              // markers: Set<Marker>.of(markers.values),
              markers: markers.values.toSet(),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  color: Colors.blue,
                  child: TextButton(
                    onPressed: () {
                      _getUserCurrentLocation().then((value) async {
                        print('latitide is==> ${value.latitude} && longtitude is ${value.longitude}');
                        _markers.add(Marker(markerId: const MarkerId('3'), position: LatLng(value.latitude, value.longitude), infoWindow: InfoWindow(title: address)));
                        final GoogleMapController controller = await _controller.future;

                        CameraPosition _kGooglePlex = CameraPosition(
                          target: LatLng(value.latitude, value.longitude),
                          zoom: 19,
                        );

                        controller.animateCamera(CameraUpdate.newCameraPosition(_kGooglePlex));

                        List<geocoding.Placemark> placemarks = await geocoding.placemarkFromCoordinates(value.latitude, value.longitude);

                        final add = placemarks.first;
                        address = add.locality.toString() + " " + add.administrativeArea.toString() + " " + add.subAdministrativeArea.toString() + " " + add.country.toString();

                        setState(() {});
                      });
                    },
                    child: const Text(
                      'Get current loction',
                      style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
            Center(
              child: StreamBuilder<LocationData>(
                  stream: location.onLocationChanged,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    LocationData? data = snapshot.data;
                    return Text(
                      "Lat is ==> ${data!.latitude} &&\n Long is ==> ${data.longitude} ",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    );
                  }),
            ),
          ],
        ),
            )
          : const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Location permission denied.'),
                  ElevatedButton(
                    onPressed: permission.openAppSettings,
                    child: Text('Open Settings'),
                  ),
                ],
              ),
            ),
    );
  }

  Future _addMarkerLongPressed(LatLng latlang) async {
    List<geocoding.Placemark> placemarks = await geocoding.placemarkFromCoordinates(latlang.latitude, latlang.longitude);

    final add = placemarks.first;
    address = "${add.street}" "${add.administrativeArea} " " ${add.subLocality} " " ${add.thoroughfare} ${add.locality} " " ${add.subThoroughfare} " " ${add.subAdministrativeArea} ${add.country}";
    setState(() {
      MarkerId markerId = const MarkerId("RANDOM_ID");
      Marker marker = Marker(
        markerId: markerId,
        draggable: true,
        position: latlang,
        //With this parameter you automatically obtain latitude and longitude
        infoWindow: InfoWindow(
          title: "${latlang.latitude},${latlang.longitude}",
          snippet: address,
        ),
        icon: BitmapDescriptor.defaultMarker,
      );

      markers[markerId] = marker;
    });

    //This is optional, it will zoom when the marker has been created
    GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(latlang, 16.0));
  }
}