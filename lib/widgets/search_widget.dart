import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class SearchMedicineWidget extends StatefulWidget {
  @override
  _SearchMedicineWidgetState createState() => _SearchMedicineWidgetState();
}

class _SearchMedicineWidgetState extends State<SearchMedicineWidget> {
  String _searchText = '';
  DatabaseReference _medicineRef;
  List<dynamic> _medicines = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          onChanged: (value) {
            setState(() {
              _searchText = value;
            });
          },
          decoration: InputDecoration(
            labelText: 'Поиск лекарств',
          ),
        ),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('лекарства')
              .where('normativedocumentation', arrayContains: _searchText)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return CircularProgressIndicator();
            }

            List<DocumentSnapshot> documents = snapshot.data.docs;
            return ListView(
              shrinkWrap: true,
              children: documents.map((document) {
                // Отображение результатов поиска
                return ListTile(
                    //  title: Text(document.data()['название']),
                    );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
