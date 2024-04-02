import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:googlemap_integration/getLocationPage.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class SearchPlaces extends StatefulWidget {
  const SearchPlaces({super.key});

  @override
  State<SearchPlaces> createState() => _SearchPlacesState();
}

class _SearchPlacesState extends State<SearchPlaces> {
  final _controller = TextEditingController();
  var uuid = const Uuid();
  String _sessionToken = '1234567890';
  List<dynamic> _placeList = [];

  @override
  void initState() {
    _controller.addListener(() {
      _onchange();
    });

    super.initState();
  }

  _onchange() {
    if (_sessionToken == null) {
      setState(() {
        _sessionToken = uuid.v4();
      });
    }
    getSuggestion(_controller.text);
  }

  getSuggestion(String input) async {
    String kPLACES_API_KEY = "AIzaSyDQ2c_pOSOFYSjxGMwkFvCVWKjYOM9siow";
    String type = '(regions)';

    try {
      String baseURL = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
      String request = '$baseURL?input=$input&key=$kPLACES_API_KEY&sessiontoken=$_sessionToken';
      var response = await http.get(Uri.parse(request));
      var data = json.decode(response.body);
      print('mydata');
      print(data.toString());
      if (response.statusCode == 200) {
        setState(() {
          _placeList = jsonDecode(response.body.toString())['predictions'];
        });
      } else {
        throw Exception('Failed to load predictions');
      }
    } catch (e) {
      // toastMessage('success');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Search Places',
        ),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Search Location',
              focusColor: Colors.grey,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                onPressed: () {
                  _controller.clear();
                  print("uuid is ===> ${uuid.v4()}");
                },
                icon: const Icon(Icons.clear),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _placeList.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () async {
                    List<Location> locationsCor = await locationFromAddress(
                      _placeList[index]['description'],
                    );
                    print(locationsCor.last.latitude);
                    print(locationsCor.last.longitude);

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GetLocationPage(
                            lat: locationsCor.last.latitude,
                            long: locationsCor.last.longitude,
                          ),
                        ));
                  },
                  child: ListTile(
                    title: Text(
                      _placeList[index]['description'],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
