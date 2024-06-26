// ignore_for_file: avoid_unnecessary_containers

import 'package:flutter/material.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';

class SearchService {
  /// Returns a search bar widget.
  ///
  /// The [searchController] is the controller for the search text field.
  /// The [onItemClicked] function is called when an item is clicked in the search results.
  /// The [userkey] is the Google Maps API key.
  static Container searchbar(TextEditingController searchController,
      Function(String) onItemClicked, String userkey) {
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
        googleAPIKey: userkey,
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
          onItemClicked(prediction.description ?? '');
        },
        seperatedBuilder: const Divider(),
      ),
    );
  }
}
