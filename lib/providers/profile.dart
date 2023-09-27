import 'package:flutter/material.dart';
import 'package:nope/providers/address.dart';

class Profile {
  final String id;
  final String firstName;
  final String lastName;
  final String username;
  String familyId;
  final String email;
  final String age;
  final String male;
  Address address;
  bool creator;
  int rating;
  int countOfEvents = 0;

  Profile({
    @required this.id,
    @required this.firstName,
    @required this.lastName,
    @required this.username,
    @required this.familyId,
    @required this.email,
    @required this.age,
    @required this.male,
    @required this.address,
    @required this.creator,
    @required this.countOfEvents,
    @required this.rating,
  });

  int get userRating {
    return rating;
  }
}
