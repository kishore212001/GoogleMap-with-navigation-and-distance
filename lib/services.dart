import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Services with ChangeNotifier{
  final Completer<GoogleMapController> _controller =
  Completer<GoogleMapController>();
//---------------------TEXTEDITING CONTROLLER------------------------//

  TextEditingController _searchController = TextEditingController();
//-------------------------GOOGLEPLEX---------------------------------//
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  Set<Marker>_marker = Set<Marker>();
  Set<Polygon>_polygon = Set<Polygon>();
  List<LatLng> polygonLatLngs  = <LatLng>[];
  int _polygonIdCounter = 1;

  Future<void> _goToPlace(Map<String, dynamic>place) async {
    final double lat = place ['geometry']['location']['lat'];
    final double lng = place ['geometry']['location']['lng'];

    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat,lng),zoom: 12)
    ));
  }
}