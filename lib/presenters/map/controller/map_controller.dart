// ignore_for_file: avoid_print

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:math' as math;

class MapPageController {
  static Future<Position> getCurrentLocation() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );
  }

  Future<List<Location>> searchLocation(String locationName) async {
    return await locationFromAddress(locationName);
  }

  Future<PolylineResult> getRoute(
      LatLng currentPosition, LatLng centerPosition, String userkey) async {
    PolylinePoints polylinePoints = PolylinePoints();
    return await polylinePoints.getRouteBetweenCoordinates(
      userkey,
      PointLatLng(currentPosition.latitude, currentPosition.longitude),
      PointLatLng(centerPosition.latitude, centerPosition.longitude),
      travelMode: TravelMode.driving,
    );
  }

  double calculateDistance(List<LatLng> points) {
    double totalDistance = 0.0;
    for (int i = 0; i < points.length - 1; i++) {
      totalDistance += Geolocator.distanceBetween(
        points[i].latitude,
        points[i].longitude,
        points[i + 1].latitude,
        points[i + 1].longitude,
      );
    }
    return totalDistance;
  }

  Future<void> requestLocationPermission(Function() onPermissionGranted) async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      onPermissionGranted();
    } else {
      print('Location permission denied');
    }
  }

  Future<void> getCurrentLocationAndSetState(
      Function(Position) setStateFunction) async {
    try {
      Position position = await getCurrentLocation();
      setStateFunction(position);
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  static void addMarker(Set<Marker> markers, LatLng location) {
    markers.add(
      Marker(
        markerId: MarkerId(location.toString()),
        position: location,
        infoWindow: const InfoWindow(
          title: 'Searched Location',
          snippet: 'This is the location you searched before',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );
  }

  Future<void> searchLocations(
    String locationName,
    Set<Marker> markers,
    LatLng? currentPosition,
    GoogleMapController mapController,
    Function(double) updateStraightDistance,
    Function(LatLng) updateCenterPosition,
  ) async {
    try {
      List<Location> locations = await searchLocation(locationName);
      markers.clear(); // Clear existing markers

      if (locations.isNotEmpty) {
        for (Location location in locations) {
          LatLng searchedLocation =
              LatLng(location.latitude, location.longitude);
          MapPageController.addMarker(markers, searchedLocation);

          // Calculate straight-line distance
          if (currentPosition != null) {
            double straightLineDistance =
                _distanceBetweenLatLng(currentPosition, searchedLocation);
            print(
                'Straight-line distance to $locationName: ${straightLineDistance.toStringAsFixed(2)} meters');
            updateStraightDistance(straightLineDistance);
          }
        }
        Location firstLocation = locations.first;
        LatLng searchedLocation =
            LatLng(firstLocation.latitude, firstLocation.longitude);
        updateCenterPosition(searchedLocation);
        mapController
            .animateCamera(CameraUpdate.newLatLngZoom(searchedLocation, 15));
        MapPageController.addMarker(markers, searchedLocation);
      }
    } catch (e) {
      print('Error searching location: $e');
    }
  }

  static double _distanceBetweenLatLng(LatLng point1, LatLng point2) {
    const double earthRadius = 6371000; // meters

    double lat1Radians = math.pi * point1.latitude / 180;
    double lat2Radians = math.pi * point2.latitude / 180;
    double deltaLatRadians =
        math.pi * (point2.latitude - point1.latitude) / 180;
    double deltaLngRadians =
        math.pi * (point2.longitude - point1.longitude) / 180;

    double a = math.sin(deltaLatRadians / 2) * math.sin(deltaLatRadians / 2) +
        math.cos(lat1Radians) *
            math.cos(lat2Radians) *
            math.sin(deltaLngRadians / 2) *
            math.sin(deltaLngRadians / 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }
}
