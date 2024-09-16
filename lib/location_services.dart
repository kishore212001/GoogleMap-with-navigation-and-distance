import 'dart:async';
import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:gmap/HomePage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'package:flutter/foundation.dart';
import 'package:location/location.dart';

class LocationService with ChangeNotifier {
  final String key = '';
  String distance = '';
  // final Completer<GoogleMapController> googleMapController = Completer();
  CameraPosition? cameraPosition;
  Location? _location;
  LocationData? currentLocation;
  LatLng initialCameraPosition = LatLng(0, 0);
  final Set<Marker> markers = Set<Marker>();
  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;

  Future<void> addCustomIcon() async {
    markers.clear();
    final icon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      "assets/Marker.png",
    );
    markerIcon = icon;
    notifyListeners();
  }

  void setMarker(
    LatLng point,
  ) {
    markers.clear();
    markers.add(
      Marker(
        markerId: const MarkerId('marker'),
        position: point,
        icon: markerIcon,
        infoWindow: InfoWindow(
          title: distance,
        ),
      ),
    );
    notifyListeners();
  }

  init() async {
    _location = Location();
    cameraPosition = const CameraPosition(
        target: LatLng(
            0, 0), // this is just the example lat and lng for initializing
        zoom: 15);
    _initLocation();
  }

  _initLocation() {
    _location?.getLocation().then((location) {
      currentLocation = location;
      initialCameraPosition = LatLng(
        currentLocation?.latitude ?? 0,
        currentLocation?.longitude ?? 0,
      );
      setMarker(initialCameraPosition);
      notifyListeners();
    });
  }

  Future<String> getPlaceId(String input) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=$input&inputtype=textquery&key=$key';

    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var placeId = json['candidates'][0]['place_id'] as String;

    return placeId;
  }

  Future<Map<String, dynamic>> getPlace(String input) async {
    final placeId = await getPlaceId(input);

    final String url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$key';

    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var results = json['result'] as Map<String, dynamic>;

    print(results);
    return results;
  }

  Future<Map<String, dynamic>> getDirections(
      String origin, String destination) async {
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=$key';

    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var results = {
      'bounds_ne': json['routes'][0]['bounds']['northeast'],
      'bounds_sw': json['routes'][0]['bounds']['southwest'],
      'start_location': json['routes'][0]['legs'][0]['start_location'],
      'end_location': json['routes'][0]['legs'][0]['end_location'],
      'polyline': json['routes'][0]['overview_polyline']['points'],
      'polyline_decoded': PolylinePoints()
          .decodePolyline(json['routes'][0]['overview_polyline']['points']),
    };

    print(results);

    notifyListeners(); // Notify listeners of changes
    return results;
  }
}
