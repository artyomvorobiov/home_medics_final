import 'dart:convert';

import '/providers/address.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter_platform_interface/src/types/location.dart';

import 'package:http/http.dart' as http;

// Map<String, bool> buttonNameContains = {
//   'Спорт': false,
//   'Развлечения': false,
//   'Вечеринки': false,
//   'Прогулка': false,
//   'Искусство': false,
//   'Обучение': false,
//   'Концерт': false,
//   'Настольные игры': false,
//   'Гастрономия': false,
// };

class Drug extends ClusterItem with ChangeNotifier {
  final String id;
  String dateTime;
  String dayTillExp;
  final String description;
  final String name;
  final String price;
  Address address;
  final String extraInformation;
  final String creatorId;
  final String profileId;
  final String familyID;
  bool isFavorite;
  bool show;
  // Map<String, dynamic> categories;
  List<dynamic> commentators;
  List<dynamic> comments;

  Drug({
    @required this.id,
    @required this.dateTime,
    @required this.dayTillExp,
    @required this.description,
    @required this.name,
    @required this.price,
    @required this.address,
    @required this.extraInformation,
    @required this.creatorId,
    @required this.profileId,
    @required this.familyID,
    @required this.show,
    this.isFavorite = false,
    // this.categories,
    this.commentators,
    this.comments,
  });

  void _setFavoriteValue(bool newValue) {
    isFavorite = newValue;
    notifyListeners();
  }

  void toggleFavoriteStatus(
      String token, String userId, String drugId, bool newIsFav) async {
    // final oldStatus = isFavorite;
    // isFavorite = !isFavorite;
    notifyListeners();
    final url =
        'https://medics-ca0f9-default-rtdb.europe-west1.firebasedatabase.app/userFavoritesEvents/$userId/$drugId.json?auth=$token';
    try {
      final response = await http.put(
        Uri.parse(url),
        body: json.encode(
          newIsFav,
        ),
      );
      if (response.statusCode >= 400) {
        _setFavoriteValue(!newIsFav);
        // _setFavoriteValue(oldStatus);
      }
    } catch (error) {
      _setFavoriteValue(!newIsFav);
    }
  }

  @override
  // TODO: implement location
  LatLng get location => throw UnimplementedError();
}
