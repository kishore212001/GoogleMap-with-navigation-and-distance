import 'dart:async';
import 'dart:convert' as convert;
import 'dart:convert';
//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

//import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
//import 'package:location/location.dart';
import 'package:gmap/location_services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import 'package:provider/provider.dart';

import 'location_services.dart'; // Import your LocationService class here

class MapSample extends StatefulWidget {
  const MapSample({Key? key}) : super(key: key);

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller = Completer();

  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  final Set<Polygon> _polygons = Set<Polygon>();
  final Set<Polyline> _polylines = <Polyline>{};
  List<LatLng> polygonLatLngs = <LatLng>[];
  // late LatLng _initialCameraPosition = LatLng(0, 0);
  String distance = "Current Location";

  int _polygonIdCounter = 1;
  int _polylineIdCounter = 1;
  // BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;

  @override
  void initState() {
    super.initState();
    LocationService locationService =
        Provider.of<LocationService>(context, listen: false);

    locationService.addCustomIcon(); // Unused, consider removing
    locationService.init(); // Unused, consider removing
  }

  void _setPolygon() {
    _polygons.clear();
    final String polygonIdVal = 'polygon_$_polygonIdCounter';
    _polygonIdCounter++;

    _polygons.add(
      Polygon(
        polygonId: PolygonId(polygonIdVal),
        points: polygonLatLngs,
        strokeWidth: 2,
        fillColor: Colors.transparent,
      ),
    );
  }

  void _setPolyline(List<PointLatLng> points) {
    _polylines.clear();
    final String polylineIdVal = 'polyline_$_polylineIdCounter';
    _polylineIdCounter++;

    _polylines.add(
      Polyline(
        polylineId: PolylineId(polylineIdVal),
        width: 2,
        color: Colors.blue,
        points: points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    LocationService locationService =
        Provider.of<LocationService>(context, listen: true);
    return Scaffold(
        appBar: AppBar(
          title: const Text('Google Maps'),
        ),
        body: locationService.initialCameraPosition != const LatLng(0, 0)
            ? Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _originController,
                              decoration: const InputDecoration(
                                hintText: 'Origin',
                              ),
                              onChanged: (value) {
                                print(value);
                              },
                            ),
                            TextFormField(
                              controller: _destinationController,
                              decoration: const InputDecoration(
                                hintText: 'Destination',
                              ),
                              onChanged: (value) {
                                print(value);
                              },
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          var directions = await locationService.getDirections(
                            _originController.text,
                            _destinationController.text,
                          );
                          _goToPlace(
                            directions['start_location']['lat'],
                            directions['start_location']['lng'],
                            directions['bounds_ne'],
                            directions['bounds_sw'],
                          );
                          await calculateDistance(
                            _originController.text,
                            _destinationController.text,
                          );
                          _setPolyline(directions['polyline_decoded']);
                        },
                        icon: const Icon(Icons.search),
                      ),
                    ],
                  ),
                  Expanded(
                    child: GoogleMap(
                      mapType: MapType.normal,
                      polygons: _polygons,
                      polylines: _polylines,
                      myLocationButtonEnabled: true,
                      myLocationEnabled: true,
                      initialCameraPosition: CameraPosition(
                        target: locationService.initialCameraPosition,
                        zoom: 20.0,
                      ),
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                      },
                      markers: locationService.markers,
                      onTap: (point) {
                        setState(() {
                          polygonLatLngs.add(point);
                          _setPolygon();
                        });
                      },
                    ),
                  ),
                  Text(distance),
                ],
              )
            : const Center(child: CircularProgressIndicator()));
  }

  Widget _buildMap(LocationService locationService) {
    Provider.of<LocationService>(context, listen: true);
    return locationService.initialCameraPosition == const LatLng(0, 0)
        ? Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _originController,
                          decoration: const InputDecoration(
                            hintText: 'Origin',
                          ),
                          onChanged: (value) {
                            print(value);
                          },
                        ),
                        TextFormField(
                          controller: _destinationController,
                          decoration: const InputDecoration(
                            hintText: 'Destination',
                          ),
                          onChanged: (value) {
                            print(value);
                          },
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      var directions = await locationService.getDirections(
                        _originController.text,
                        _destinationController.text,
                      );
                      _goToPlace(
                        directions['start_location']['lat'],
                        directions['start_location']['lng'],
                        directions['bounds_ne'],
                        directions['bounds_sw'],
                      );
                      await calculateDistance(
                        _originController.text,
                        _destinationController.text,
                      );
                      _setPolyline(directions['polyline_decoded']);
                    },
                    icon: const Icon(Icons.search),
                  ),
                ],
              ),
              Expanded(
                child: GoogleMap(
                  mapType: MapType.normal,
                  polygons: _polygons,
                  polylines: _polylines,
                  initialCameraPosition: CameraPosition(
                    target: locationService.initialCameraPosition,
                    zoom: 20.0,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                  markers: locationService.markers,
                  onTap: (point) {
                    setState(() {
                      polygonLatLngs.add(point);
                      _setPolygon();
                    });
                  },
                ),
              ),
              Text(distance),
            ],
          )
        : const Center(child: CircularProgressIndicator());
  }

  Future<void> _goToPlace(
    double lat,
    double lng,
    Map<String, dynamic> boundsNe,
    Map<String, dynamic> boundsSw,
  ) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: 12),
      ),
    );

    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(boundsSw['lat'], boundsSw['lng']),
          northeast: LatLng(boundsNe['lat'], boundsNe['lng']),
        ),
        25,
      ),
    );
    Provider.of<LocationService>(context, listen: false)
        .setMarker(LatLng(lat, lng));
    //setMarker(LatLng(lat, lng), distance);
  }

  /*
  Future<void> _goToPlace(
      double lat,
      double lng,
      Map<String, dynamic> boundsNe,
      Map<String, dynamic> boundsSw,
      //  LatLng initialCameraPosition,
      ) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: 12),
      ),
    );

    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(boundsSw['lat'], boundsSw['lng']),
          northeast: LatLng(boundsNe['lat'], boundsNe['lng']),
        ),
        25,
      ),
    );

    Provider.of<LocationService>(context, listen: false)
        .setMarker(_initialCameraPosition);
  }


   */

  Future<void> calculateDistance(String origin, String destination) async {
    const String apiKey = "";
    var response = await http.get(
      Uri.parse(
        "https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=$apiKey",
      ),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var distanceText = data['routes'][0]['legs'][0]['distance']['text'];

      setState(() {
        distance = 'Distance: $distanceText';
      });
    }
  }
}
