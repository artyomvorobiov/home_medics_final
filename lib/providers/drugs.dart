import 'dart:convert';

import '../models/http_exception.dart';
import 'drug.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '/providers/address.dart';
import 'profiles.dart';

class Drugs with ChangeNotifier {
  List<Drug> _drugs = [];
  final String authToken;
  final String userId;
  String _selectedAddress;

  String get selectedAddress => _selectedAddress;

  Drugs(this.authToken, this.userId, this._drugs);
  void setSelectedAddress(String address) {
    _selectedAddress = address;
    notifyListeners();
  }

  List<Drug> get drugs {
    // if (_showFavoritesOnly) {
    //   return _items.where((prodItem) => prodItem.isFavorite).toList();
    // }
    return [..._drugs];
  }

  List<Drug> get favoriteEvents {
    return _drugs.where((drug) => drug.isFavorite).toList();
  }

  List<Drug> get visibleEvents {
    return _drugs
        .where((drug) => (drug.show || drug.profileId == Profiles.curProfileId))
        .toList();
  }

  Drug findById(String id) {
    return _drugs.firstWhere((drug) => drug.id == id);
  }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   // notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   // notifyListeners();
  // }

  bool setFavoriteStatus(Map<String, dynamic> favEvents, String prodId) {
    print('prodId ${prodId}');
    //print('res ${favEvents[prodId]}');
    if (favEvents == null) {
      return false;
    }
    if (favEvents[prodId] == null) {
      print('Come null');
      return false;
    }
    return favEvents[prodId];
  }

  Future<void> fetchAndSetEvents([bool filterByUser = false]) async {
    var test = Profiles.curProfile.familyId;
    var test2 = Profiles.curProfile.address.title;
    final filterString = filterByUser
        ? 'orderBy="address/title"&equalTo="$test2"'
        : 'orderBy="familyID"&equalTo="$test"';
    // print("FILTER $filterString");
    var url =
        'https://medics-ca0f9-default-rtdb.europe-west1.firebasedatabase.app/drugs.json?auth=$authToken&$filterString';
    try {
      final response = await http.get(Uri.parse(url));
      var extractedData;

      print("RESPONSE ${response.body}");
      if (response.body.isEmpty) {
        print("object");
        extractedData = null;
        return;
      }

      var obj = json.decode(response.body);
      if (obj == '') {
        obj = null;
        return;
      }
      extractedData = obj as Map<String, dynamic>;

      url =
          'https://medics-ca0f9-default-rtdb.europe-west1.firebasedatabase.app/userFavoritesEvents/$userId.json?auth=$authToken';
      final favoriteResponse = await http.get(Uri.parse(url));
      final favEvents = json.decode(favoriteResponse.body);
      print('favoriteEvents ${favEvents}');

      final List<Drug> loadedProducts = [];

      // print("DATA $extractedData");

      // print('curTime ${curTime}');
      // if (curTime.isBefore(DateTime.now())) {
      //   return Divider();
      // }
      extractedData.forEach(
        (prodId, prodData) {
          print("DATA $prodId $prodData");
          final productAddress = prodData['address']['title'] as String;

          if ((_selectedAddress == null || productAddress == selectedAddress)) {
            loadedProducts.add(
              Drug(
                id: prodId,
                dateTime: prodData['dateTime'],
                dayTillExp: prodData['dayTillExp'],
                description: prodData['description'],
                name: prodData['name'],
                price: prodData['price'],
                //  imagePath: prodData['imageUrl'],
                address: Address(
                  id: prodData['address']['id'],
                  title: prodData['address']['title'],
                ),
                extraInformation: prodData['extraInformation'],
                isFavorite: setFavoriteStatus(favEvents, prodId),
                // categories: prodData['categories'],
                creatorId: prodData['creatorId'],
                profileId: prodData['profileId'],
                familyID: prodData['familyID'],
                show: prodData['show'],
                comments: prodData['comments'],
                commentators: prodData['commentators'],
              ),
            );
          }
        },
      );
      _drugs = loadedProducts;
      notifyListeners();
    } catch (error) {
      print("ERROR EVENTS");
      throw (error);
    }
  }

  Future<void> updateDrugsFamilyId(String newFamilyId) async {
    final url =
        'https://medics-ca0f9-default-rtdb.europe-west1.firebasedatabase.app/drugs.json?auth=$authToken';

    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      for (final prodId in extractedData.keys) {
        final prodData = extractedData[prodId];
        final currentFamilyId = prodData['familyID'];
        final creatorId = prodData['creatorId'];
        print("profileId $creatorId");
        print("userId $userId");
        if (creatorId == userId) {
          final updateUrl =
              'https://medics-ca0f9-default-rtdb.europe-west1.firebasedatabase.app/drugs/$prodId.json?auth=$authToken';

          await http.patch(
            Uri.parse(updateUrl),
            body: json.encode({'familyID': newFamilyId}),
          );
        }
      }
      notifyListeners();
    } catch (error) {
      print("ERROR updating drugs' familyId: $error");
      throw error;
    }
  }

  Future<List<String>> getAvailableAddresses(String familyId) async {
    final url =
        'https://medics-ca0f9-default-rtdb.europe-west1.firebasedatabase.app/drugs.json?auth=$authToken&orderBy="familyID"&equalTo="$familyId"';

    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      final Set<String> addresses = {};

      extractedData.forEach((prodId, prodData) {
        addresses.add(prodData['address']['title'] as String);
      });

      return addresses.toList();
    } catch (error) {
      print("ERROR fetching addresses: $error");
      throw error;
    }
  }

  Future<void> addEvent(Drug drug) async {
    // print("HFKJFHJKF ${event.imagePath}");
    final url =
        'https://medics-ca0f9-default-rtdb.europe-west1.firebasedatabase.app/drugs.json?auth=$authToken';
    List<String> newCommentators = ['-NW236pZBxgrc8GPbsL0'];
    List<String> newComments = ['fake'];
    drug.comments = newComments;
    drug.commentators = newCommentators;
    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode({
          'name': drug.name,
          'description': drug.description,
          'price': drug.price,
          // 'imageUrl': event.imagePath,
          'address': {
            'title': drug.address.title,
            'id': drug.address.id,
          },
          'extraInformation': drug.extraInformation,
          'dateTime': drug.dateTime,
          'dayTillExp': drug.dayTillExp,
          'creatorId': userId,
          'profileId': Profiles.curProfileId,
          'familyID': Profiles.curProfile.familyId,
          'show': drug.show,
          // 'categories': drug.categories,
          'comments': drug.comments,
          'commentators': drug.commentators,
        }),
      );

      final newDrug = Drug(
        name: drug.name,
        description: drug.description,
        price: drug.price,
        //  imagePath: event.imagePath,
        address: drug.address,
        extraInformation: drug.extraInformation,
        dateTime: drug.dateTime,
        dayTillExp: drug.dayTillExp,
        // categories: drug.categories,
        creatorId: drug.creatorId,
        profileId: drug.profileId,
        show: drug.show,
        familyID: drug.familyID,
        id: json.decode(response.body)['name'],
        comments: drug.comments,
        commentators: drug.commentators,
      );
      _drugs.add(newDrug);
      notifyListeners();
    } catch (error) {
      print("ERROR $error");
      throw error;
    }
  }

  Future<void> updateEvent(String id, Drug newDrug) async {
    // print("UPDATE_PHOTO ${newEvent.imagePath}");
    final prodIndex = _drugs.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url =
          'https://medics-ca0f9-default-rtdb.europe-west1.firebasedatabase.app/drugs/$id.json?auth=$authToken';
      await http.patch(
        Uri.parse(url),
        body: json.encode(
          {
            'name': newDrug.name,
            'description': newDrug.description,
            // 'imageUrl': newEvent.imagePath,
            'address': {
              'title': newDrug.address.title,
              'id': newDrug.address.id,
            },
            'extraInformation': newDrug.extraInformation,
            'dateTime': newDrug.dateTime,
            'dayTillExp': newDrug.dayTillExp,
            'price': newDrug.price,
            // 'categories': newDrug.categories,
            'familyID': newDrug.familyID,
            'show': newDrug.show,
            'comments': newDrug.comments,
            'commentators': newDrug.commentators,
          },
        ),
      );
      _drugs[prodIndex] = newDrug;
      notifyListeners();
    } else {
      // print('...');
    }
  }

  Future<void> deleteEvent(String id) async {
    final url =
        'https://medics-ca0f9-default-rtdb.europe-west1.firebasedatabase.app/drugs/$id.json?auth=$authToken';
    // final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    // var existingProduct = _items[existingProductIndex];
    // _items.removeAt(existingProductIndex);
    final response = await http.delete(Uri.parse(url));
    if (response.statusCode >= 400) {
      // _items.insert(existingProductIndex, existingProduct);
      // notifyListeners();
      throw HttpException('Could not delete product.');
    }
    notifyListeners();
    // existingProduct = null;
  }
}
