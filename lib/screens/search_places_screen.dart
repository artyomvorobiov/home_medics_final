import 'dart:async';
import 'dart:ui';

import '/providers/profile.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';

import '../models/place.dart';
import '../providers/profiles.dart';
import '/providers/address.dart';
import '../providers/drugs.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:provider/provider.dart';
import 'package:location/location.dart' as loc;
// import 'package:marker_icon/marker_icon.dart';

import '../providers/color.dart';
import '../providers/drug.dart';

class SearchPlacesScreen extends StatefulWidget {
  bool fromDetailScreen;
  Address address;

  SearchPlacesScreen({this.fromDetailScreen = false, this.address});
  // const SearchPlacesScreen({Key key}) : super(key: key);

  @override
  State<SearchPlacesScreen> createState() => _SearchPlacesScreenState();
}

const kGoogleApiKey = 'AIzaSyBYg4SD_fvydAJIOBwZcKIVGqj_QxdFM1U';
final homeScaffoldKey = GlobalKey<ScaffoldState>();

class _SearchPlacesScreenState extends State<SearchPlacesScreen> {
  ClusterManager _manager;
  Completer<GoogleMapController> _controller = Completer();
  List<Place> items = [];
  bool loadingExistEvents = false;

  BitmapDescriptor customIcon;
  static Map<String, dynamic> categories = {
    'Спорт': false,
    'Развлечения': false,
    'Вечеринки': false,
    'Прогулка': false,
    'Искусство': false,
    'Обучение': false,
    'Концерт': false,
    'Настольные игры': false,
    'Гастрономия': false,
  };

  static const CameraPosition initialCameraPosition =
      CameraPosition(target: LatLng(55.7522, 37.6156), zoom: 14.0);

  Set<Marker> markersList = {};

  GoogleMapController googleMapController;

  final Mode _mode = Mode.overlay;

  @override
  void initState() {
    _manager = _initClusterManager();
    super.initState();
  }

  void initPlaces() {}

  ClusterManager _initClusterManager() {
    return ClusterManager<Place>(items, _updateMarkers,
        markerBuilder: _markerBuilder);
  }

  void _updateMarkers(Set<Marker> markers) {
    print('Updated ${markers.length} markers');
    setState(() {
      this.markersList = markers;
    });
  }

  @override
  Widget build(BuildContext context) {
    BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(0.1, 0.1)),
      'assets/images/product-placeholder.png',
    ).then((d) {
      customIcon = d;
    });

    for (var category in categories.keys) {
      print('MAP CATEGORY $category ${categories[category]}');
    }
    if (widget.fromDetailScreen) {
      displayPositionFromDetailScreen();
      widget.fromDetailScreen = false;
    }
    if (!loadingExistEvents) {
      items.clear();
      showExistMarkers();
      loadingExistEvents = true;
    }
    return Stack(
      children: [
        GoogleMap(
          zoomControlsEnabled: false,
          initialCameraPosition: initialCameraPosition,
          markers: markersList,
          mapType: MapType.normal,
          onMapCreated: (GoogleMapController controller) {
            googleMapController = controller;
            _controller.complete(controller);
            _manager.setMapId(controller.mapId);
          },
          onCameraMove: _manager.onCameraMove,
          onCameraIdle: _manager.updateMap,
        ),
        // ElevatedButton(
        //   onPressed: _handlePressButton,
        //   child: const Text("Search Places"),
        // ),
        Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      ),
                      border: Border.all(
                        color: Theme.of(context).primaryColor,
                      ),
                      color: Theme.of(context).colorScheme.secondary,
                      // padding: const EdgeInsets.all(10),
                    ),
                    height: 50,
                    child: IconButton(
                      icon: Icon(Icons.search),
                      color: Theme.of(context).primaryColor,
                      onPressed: _handlePressButton,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      ),
                      border: Border.all(
                        color: Theme.of(context).primaryColor,
                      ),
                      color: Theme.of(context).colorScheme.secondary,
                      // padding: const EdgeInsets.all(10),
                    ),
                    height: 50,
                    child: IconButton(
                      icon: Icon(Icons.location_on),
                      color: Theme.of(context).primaryColor,
                      onPressed: _getCurrentPosition,
                    ),
                  ),
                ],
              ),
              // Container(
              //   decoration: BoxDecoration(
              //     borderRadius: BorderRadius.all(
              //       Radius.circular(20),
              //     ),
              //     border: Border.all(
              //       color: Theme.of(context).primaryColor,
              //     ),
              //     color: Theme.of(context).colorScheme.secondary,
              //     // padding: const EdgeInsets.all(10),
              //   ),
              //   height: 50,
              //   child: IconButton(
              //       icon: Icon(Icons.filter_alt_rounded),
              //       color: Theme.of(context).primaryColor,
              //       onPressed: () {
              //         _manager.setItems(<Place>[
              //           for (int i = 0; i < 30; i++)
              //             Place(
              //                 name: 'New Place ${DateTime.now()} $i',
              //                 latLng: LatLng(48.858265 + i * 0.01, 2.350107))
              //         ]);
              //       }),
              // ),
              // Container(
              //   decoration: BoxDecoration(
              //     borderRadius: BorderRadius.all(
              //       Radius.circular(20),
              //     ),
              //     border: Border.all(
              //       color: Theme.of(context).primaryColor,
              //     ),
              //     color: Theme.of(context).colorScheme.secondary,
              //     // padding: const EdgeInsets.all(10),
              //   ),
              //   height: 50,
              //   child: IconButton(
              //     icon: Icon(Icons.filter_alt_rounded),
              //     color: Theme.of(context).primaryColor,
              //     onPressed: {} => (),
              //   ),
              // ),
            ],
          ),
        ),
      ],
    );
  }

  Future<Marker> Function(Cluster<Place>) get _markerBuilder =>
      (cluster) async {
        bool color_prem = false;
        print("MARKER_BUILDER");
        return Marker(
          markerId: MarkerId(cluster.getId()),
          position: cluster.location,
          onTap: () async {
            if (cluster.count == 1) {
              color_prem = cluster.items.first.isClosed;
              print("COLORRRRRR $color_prem");
              Navigator.of(context).pushNamed(
                '/event-detail',
                arguments: cluster.items.first.id,
              );
            } else {
              // при нажатии увеличиваем зум на пару единиц и центрируем на кластере
              googleMapController.animateCamera(
                CameraUpdate.newLatLngZoom(
                  cluster.location,
                  await googleMapController.getZoomLevel() + 2,
                ),
              );
              // googleMapController.animateCamera(
              //     CameraUpdate.newLatLngZoom(cluster.location, ));
              print('---- $cluster');
              cluster.items.forEach((p) => print(p));
            }
          },
          icon: await _getMarkerBitmap(
            cluster.isMultiple ? 125 : 75,
            Color(ColorTheme.mainFirstColor),
            color_prem,
            text: cluster.isMultiple ? cluster.count.toString() : null,
            place: cluster.items.first,
          ),
        );
      };

  Future<BitmapDescriptor> _getMarkerBitmap(
      int size, Color color, bool color_for_premium,
      {String text, Place place}) async {
    if (place != null) {
      color_for_premium = place.isClosed;
    }
    print("OBBB ${color_for_premium}");
    //   if (kIsWeb) size = (size / 2).floor();

    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint1 = Paint()..color = color;
    Paint paint2;
    Paint paint3;
    if (color_for_premium) {
      print("HERE");
      paint3 = Paint()..color = Colors.red;
      paint2 = Paint()..color = Colors.red;
    } else {
      paint3 = Paint()..color = color;
      paint2 = Paint()..color = Colors.white;
    }

    print("COLORFORPREM ${color_for_premium}");

    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.0, paint3);
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.2, paint2);
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.8, paint1);

    if (text != null) {
      TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
      painter.text = TextSpan(
        text: text,
        style: TextStyle(
            fontSize: size / 3,
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.normal),
      );
      painter.layout();
      painter.paint(
        canvas,
        Offset(size / 2 - painter.width / 2, size / 2 - painter.height / 2),
      );
    }

    final img = await pictureRecorder.endRecording().toImage(size, size);
    final data = await img.toByteData(format: ImageByteFormat.png) as ByteData;

    return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
  }

  void _getCurrentPosition() async {
    final locData = await loc.Location().getLocation();
    final lat = locData.latitude;
    final lng = locData.longitude;
    final GoogleMapController controller = await googleMapController;
    markersList.add(Marker(
        // icon: await _getMarkerBitmap(
        //     100, Color(ColorTheme.mainFirstColor), false),
        markerId: const MarkerId("0"),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(title: "Your location")));

    setState(() {});
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(lat, lng),
        zoom: 16.0,
      ),
    ));
  }

  Future<void> _handlePressButton() async {
    Prediction p = await PlacesAutocomplete.show(
        context: context,
        apiKey: kGoogleApiKey,
        onError: onError,
        mode: _mode,
        language: 'ru',
        strictbounds: false,
        types: [""],
        decoration: InputDecoration(
            hintText: 'Search',
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: Colors.white))),
        components: [
          Component(Component.country, "ru"),
        ]);

    displayPrediction(p, homeScaffoldKey.currentState);
  }

  void onError(PlacesAutocompleteResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: 'Message',
        message: response.errorMessage,
        contentType: ContentType.failure,
      ),
    ));

    // homeScaffoldKey.currentState!.showSnackBar(SnackBar(content: Text(response.errorMessage!)));
  }

  bool isAppropriate(Drug event) {
    for (String selectedFilter in categories.keys) {
      // if (event.categories[selectedFilter] == true) {
      if (categories[selectedFilter] == true) {
        return true;
        // }
      }
    }
    return false;
  }

  void showExistMarkers() async {
    Color main_color = Color(ColorTheme.mainFirstColor);
    bool color_for_premium;
    // print("SHOW EXIST MARKERS");
    await Provider.of<Drugs>(context, listen: false).fetchAndSetEvents();
    var events = Provider.of<Drugs>(context, listen: false).drugs;
    for (String key in categories.keys) {
      if (categories[key] == true) {
        events.removeWhere((element) => !isAppropriate(element));
        break;
      }
    }

    PlacesDetailsResponse detail;
    Prediction prediction;
    GoogleMapsPlaces places = GoogleMapsPlaces(
        apiKey: kGoogleApiKey,
        apiHeaders: await const GoogleApiHeaders().getHeaders());
    // events.forEach(
    //   (element) async {
    //     Profile profile = await Provider.of<Profiles>(context, listen: false)
    //         .findById(element.profileId);

    //     color_for_premium = profile.userRating == 5 ? true : false;
    //     print("CCOLORRR ${color_for_premium}, NAME ${element.description}");
    //     Address address = element.address;
    //     address = element.address;
    //     prediction = Prediction(
    //       description: address.title,
    //       id: element.id,
    //       placeId: address.id,
    //       reference: element.id,
    //       types: [element.id],
    //     );
    //     // как получить placeId из адреса? - надо сделать запрос на сервер и получить placeId
    //     // print("PREDECTION ${prediction.placeId} PLACE ID ${places == null}}");
    //     detail = await places.getDetailsByPlaceId(prediction.placeId);
    //     // print(
    //     //     "COORDINATES ${detail.result.geometry.location.lat} ${detail.result.geometry.location.lng}");
    //     double lat = detail.result.geometry.location.lat;
    //     double lng = detail.result.geometry.location.lng;
    //     items.add(
    //       Place(
    //         id: element.id,
    //         name: address.title,
    //         latLng: LatLng(lat, lng),
    //         isClosed: profile.rating == 5 ? true : false,
    //       ),
    //     );
    //     // markersList.add(
    //     //   Marker(
    //     //     icon: await _getMarkerBitmap(75, main_color, color_for_premium),
    //     //     markerId: MarkerId(detail.result.name),
    //     //     position: LatLng(detail.result.geometry.location.lat,
    //     //         detail.result.geometry.location.lng),
    //     //     // infoWindow: InfoWindow(title: detail.result.name),
    //     //     infoWindow: InfoWindow(
    //     //       title: element.address.title,
    //     //       snippet: element.description,
    //     // onTap: () {
    //     //   Navigator.of(context).pushNamed(
    //     //     '/event-detail',
    //     //     arguments: element.id,
    //     //   );
    //     // },
    //     //     ),
    //     //   ),
    //     // );
    //   },
    // );
    setState(() {
      print("COUNT IN LIST ${markersList.length}");
    });
  }

  Future<void> displayPositionFromDetailScreen() async {
    PlacesDetailsResponse detail;
    Prediction prediction;
    GoogleMapsPlaces places = GoogleMapsPlaces(
        apiKey: kGoogleApiKey,
        apiHeaders: await const GoogleApiHeaders().getHeaders());
    if (widget.address != null) {
      prediction = Prediction(
        description: widget.address.title,
        placeId: widget.address.id,
      );
      detail = await places.getDetailsByPlaceId(prediction.placeId);
      var lat = detail.result.geometry.location.lat;
      var lng = detail.result.geometry.location.lng;

      final GoogleMapController controller = await googleMapController;
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(lat, lng),
          zoom: 14.0,
        ),
      ));
    }
  }

  Future<void> displayPrediction(
      Prediction p, ScaffoldState currentState) async {
    GoogleMapsPlaces places = GoogleMapsPlaces(
        apiKey: kGoogleApiKey,
        apiHeaders: await const GoogleApiHeaders().getHeaders());

    PlacesDetailsResponse detail = await places.getDetailsByPlaceId(p.placeId);

    final lat = detail.result.geometry.location.lat;
    final lng = detail.result.geometry.location.lng;

    markersList.clear();
    markersList.add(Marker(
        icon:
            await _getMarkerBitmap(75, Color(ColorTheme.mainFirstColor), false),
        markerId: const MarkerId("0"),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(title: detail.result.name)));

    setState(() {});

    googleMapController
        .animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 14.0));
  }

  // Future<void> callPopUp() async {
  //   dynamic newCategories = await Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (BuildContext context) => PopUpDialog(
  //         oldCategories: categories,
  //       ).build(context),
  //     ),
  //   ) as Map<String, dynamic>;
  //   setFilters(newCategories);
  // }

  void setFilters(Map<String, dynamic> newCategories) {
    for (String key in newCategories.keys) {
      categories[key] = newCategories[key];
    }
    setState(() {
      // markersList.clear();
      loadingExistEvents = false;
    });
  }
}
