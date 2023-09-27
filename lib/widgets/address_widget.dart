import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:nope/providers/profile.dart';
import '../providers/address.dart';
import '../providers/drug.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_api_headers/google_api_headers.dart';
import '/screens/search_places_screen.dart';

class AddressWidget extends StatefulWidget {
  Profile curEvent;
  Map<String, dynamic> redactedEvent;
  AddressWidget(this.curEvent, this.redactedEvent);

  @override
  State<AddressWidget> createState() => _AddressWidgetState();
}

class _AddressWidgetState extends State<AddressWidget> {
  final Mode _mode = Mode.overlay;

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
  }

  Future<Address> displayPrediction(
      Prediction p, ScaffoldState currentState) async {
    GoogleMapsPlaces places = GoogleMapsPlaces(
        apiKey: kGoogleApiKey,
        apiHeaders: await const GoogleApiHeaders().getHeaders());

    PlacesDetailsResponse detail = await places.getDetailsByPlaceId(p.placeId);
    Address address =
        Address(id: p.placeId, title: detail.result.formattedAddress);
    return address;
  }

  Future<Address> _handlePressButton() async {
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

    return displayPrediction(p, homeScaffoldKey.currentState);
  }

  void setAddress() async {
    Address address = await _handlePressButton();
    Address newAddress = Address(title: address.title, id: address.id);
    widget.redactedEvent['address'] = newAddress;

    setState(() {
      widget.curEvent.address = newAddress;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: TextButton(
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            widget.curEvent.address == null ||
                    widget.curEvent.address.title == ''
                ? 'Адрес'
                : widget.curEvent.address.title,
            style:
                TextStyle(fontSize: 15, color: Theme.of(context).primaryColor),
          ),
        ),
        style: TextButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          padding: EdgeInsets.only(right: 170),
        ),
        onPressed: setAddress,
      ),
    );
  }
}
