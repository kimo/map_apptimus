# Map Apptimus

Map Apptimus is a Flutter package for integrating maps and search functionality into your Flutter applications.

## Getting Started

### Prerequisites

Before using this package, you need to obtain a Google API key from the Google Cloud Console for map integration.

### Installation

Add the following dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  map_apptimus: ^0.0.1
```


# Android Configuration

In your android/app/build.gradle, make sure you have the following configurations:


```gradle
android {
    ...
    compileSdkVersion 33
    defaultConfig {
        ...
        minSdkVersion 21
        ...
    }
    ...
}
```

## Add the following permissions to your AndroidManifest.xml:

```dart
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```
## Also, add your Google API key to the AndroidManifest.xml:

```dart
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="Your_api_key" />
```
# Usage

## Simple Map Integrated Application

```dart
import 'package:map_apptimus/map_apptimus.dart';

MapScreen(
  searchfunction: true,
  straightDistance: true,
  routeDistance: true,
  showRoute: true,
  userkey: 'your_api_key',
),
```
## Simple Google Search Function

```dart
import 'package:map_apptimus/map_apptimus.dart';

SearchService searchservice = SearchService();
searchservice.searchbar(
  searchController,
  onItemClicked,
  userkey: 'your_api_key',
);
```
# License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/ApptimusMobile/map_apptimus.git/LICENSE) file for details.