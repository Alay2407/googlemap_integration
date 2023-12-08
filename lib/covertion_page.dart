import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

class ConvetionPage extends StatefulWidget {
  const ConvetionPage({super.key});

  @override
  State<ConvetionPage> createState() => _ConvetionPageState();
}

class _ConvetionPageState extends State<ConvetionPage> {
   String address ='';
   String cordinates ='';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () async {
                List<Location> locationsCor = await locationFromAddress(
                  "Gronausestraat 710, Enschede",
                );

                List<Placemark> placemarks = await placemarkFromCoordinates(
                  52.2165157,
                  6.9437819,
                );
                setState(() {
                  cordinates = locationsCor.first.longitude.toString();
                  address = placemarks.first.subLocality.toString();
                });
              },
              child: const Text(
                'Convert',
              ),
            ),
            Text(cordinates),
            Text(address)
          ],
        ),
      ),
    );
  }
}
