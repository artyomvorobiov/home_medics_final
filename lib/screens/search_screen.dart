import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../widgets/search_widget.dart';

class SearchScreen extends StatelessWidget {
  static const routeName = '/search_screen';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Поиск лекарств'),
        ),
        body: SearchMedicineWidget(),
      ),
    );
  }
}
