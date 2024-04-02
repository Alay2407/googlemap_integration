

-Google Map Api Key
    -AIzaSyCLXYGKBylq5OjWSDI3YA884MJ7ih5_eW0


-Google Place Api Key
    -AIzaSyDQ2c_pOSOFYSjxGMwkFvCVWKjYOM9siow




    location.onLocationChanged.listen((LocationData cLoc) {
            // cLoc contains the lat and long of the
            // current user's position in real time,
            // so we're holding on to it
            currentLocation = cLoc;
            print("Current location is === >${currentLocation}");
          });