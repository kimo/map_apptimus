#  Simple map integrated application with map_apptimus

  ```dart
  import 'package:map_apptimus/map_apptimus.dart';

 MapScreen(
  searchfunction : true,
  straightDistance : true,
  routeDistance : true,
  showRoute : true;
        userkey: 'your_api_key',
      ),
  ```

#  Simple google_search function used in your application with map_apptimus
```dart
import 'package:map_apptimus/map_apptimus.dart';
SearchService searchservice = SearchService();
 ### you can make your search function as your wish 

 searchservice.searchbar( searchController,
      onItemClicked, userkey)
in here  ```dart
TextEditingController searchController,
      Function(String) onItemClicked,
       String userkey ='your_api_key'
```

```