// ignore_for_file: public_member_api_docs, sort_constructors_first, must_be_immutable
// ignore_for_file: avoid_print, file_names

import 'package:example/screen/controller/map_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';

class MapScreen extends StatefulWidget {
  String userkey;
  bool? searchfunction = false;
  bool? straightDistance = false;
  bool? routeDistance = false;
  bool? showRoute = false;
  bool? saveLocation = false;
  MapScreen({
    super.key,
    required this.userkey,
    this.searchfunction,
    this.straightDistance,
    this.routeDistance,
    this.showRoute,
    this.saveLocation,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late LatLng centerPosition = const LatLng(9.7637672, 80.0293589);
  LatLng? mapCenterPosition;
  LatLng? _currentPosition;
  late List<LatLng> _polylineCoordinates = [];
  late final List<LatLng> _polygonCoordinates = [
    const LatLng(
        6.9731, 79.9718), // Sample polygon coordinates, modify as needed
    const LatLng(6.9732, 79.9719),
    const LatLng(6.9733, 79.9720),
    // Add more vertices as needed
  ];
  late GoogleMapController _mapController;
  TextEditingController searchController = TextEditingController();
  Set<Marker> markers = {};
  late double distance = 0.0;
  late double straightdistance = 0.0;
  MapPageController mapPageController = MapPageController();

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _requestLocationPermission() async {
    mapPageController.requestLocationPermission(_getLiveLocation);
  }

  Future<void> _getLiveLocation() async {
    mapPageController.getCurrentLocationAndSetState((position) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
    });
  }

  Future<void> _searchLocation(String locationName) async {
    await mapPageController.searchLocations(
      locationName,
      markers,
      _currentPosition,
      _mapController,
      (double straightLineDistance) {
        setState(() {
          straightdistance = straightLineDistance;
        });
      },
      (LatLng searchedLocation) {
        setState(() {
          centerPosition = searchedLocation;
        });
      },
    );
  }

  _saveLocation() {
    // Save location to database or any other storage
    Marker marker = Marker(
      markerId: const MarkerId('savedLocation'),
      position: centerPosition,
      infoWindow: const InfoWindow(
        title: 'Saved Location',
        snippet: 'This is the location you saved',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
    );
    setState(() {
      markers.add(marker);
    });
  }

  Future<void> _getRoute() async {
    if (_currentPosition != null) {
      try {
        PolylineResult result = await mapPageController.getRoute(
            _currentPosition!, centerPosition, widget.userkey);

        if (result.points.isNotEmpty) {
          setState(() {
            _polylineCoordinates = result.points
                .map((point) => LatLng(point.latitude, point.longitude))
                .toList();
          });
          distance =
              mapPageController.calculateDistance(_polylineCoordinates) / 1000;
          print('Distance: $distance kilometers');
        }
      } catch (e) {
        print('Error getting route: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map with Search Function'),
      ),
      body: _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  onCameraMove: (position) {
                    mapCenterPosition = position.target;
                    print('Center Position: $mapCenterPosition');
                  },
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition!,
                    zoom: 15,
                  ),
                  markers: markers,
                  polylines: {
                    if (_polylineCoordinates.isNotEmpty)
                      Polyline(
                        polylineId: const PolylineId("poly"),
                        color: Colors.black,
                        points: _polylineCoordinates,
                        width: 5,
                      ),
                  },
                  polygons: {
                    Polygon(
                      polygonId: const PolygonId("polygon"),
                      points: _polygonCoordinates,
                      fillColor: Colors.green.withOpacity(0.5),
                      strokeColor: Colors.green,
                      strokeWidth: 2,
                    ),
                  },
                ),
                if (widget.searchfunction == true) ...[
                  for (int i = 0; i < _polylineCoordinates.length - 1; i++)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Column(
                        children: [
                          if (widget.straightDistance == true)
                            Text(
                              'Straight Distance: ${straightdistance.toStringAsFixed(2)} m',
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          if (widget.routeDistance == true)
                            Text(
                              'Distance: ${distance.toStringAsFixed(2)} km',
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ),
                  if (widget.saveLocation == true)
                    Positioned(
                        bottom: 20,
                        right: 20,
                        left: 20,
                        child: ElevatedButton(
                            onPressed: _saveLocation,
                            child: const Text('Save Location'))),
                  if (widget.showRoute == true)
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: ElevatedButton(
                        onPressed: _getRoute,
                        child: const Text('Show Route'),
                      ),
                    ),
                  Positioned(
                    top: 60,
                    left: 10,
                    right: 10,
                    child: searchbar(),
                  ),
                  const Center(
                    child: IconButton(
                      icon: Icon(
                        Icons.person_pin_circle,
                        size: 60,
                      ),
                      onPressed: null,
                    ),
                  )
                ]
              ],
            ),
    );
  }

  Container searchbar() {
    return Container(
      child: GooglePlaceAutoCompleteTextField(
        boxDecoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        textEditingController: searchController,
        googleAPIKey: widget.userkey,
        inputDecoration: const InputDecoration(
          hintText: 'Search location',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20),
        ),
        debounceTime: 400,
        isLatLngRequired: true,
        getPlaceDetailWithLatLng: (Prediction prediction) {
          // Handle place details here if needed
          print('Place Details: ${prediction.lat}, ${prediction.lng}');
        },
        itemClick: (Prediction prediction) {
          // Handle item click here
          _searchLocation(prediction.description ?? '');
        },
        seperatedBuilder: const Divider(),
      ),
    );
  }
}
