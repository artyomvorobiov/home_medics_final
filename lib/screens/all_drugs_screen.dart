import 'package:nope/screens/drugs_screen.dart';

import '/providers/address.dart';
import 'package:provider/provider.dart';

import '../providers/drugs.dart';
import '../widgets/drugs_grid.dart';
import 'creating_drug_screen.dart';
import 'package:flutter/material.dart';
import '../providers/drug.dart';

class AllDrugs extends StatefulWidget {
  static const routeName = '/drugs';
  // const AllDrugs({Key key}) : super(key: key);

  @override
  State<AllDrugs> createState() => _AllDrugsState();
}

class _AllDrugsState extends State<AllDrugs> {
  Map<String, dynamic> categoriesForEventsScreen = {
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
  void createFunc() async {
    await Navigator.of(context).pushNamed(
      CreatingEventScreen.routeName,
      arguments: Drug(
        id: null,
        dateTime: null,
        description: '',
        price: '',
        name: '',
        address: Address(),
        extraInformation: '',
        creatorId: '',
        // categories: {
        //   'Спорт': false,
        //   'Развлечения': false,
        //   'Вечеринки': false,
        //   'Прогулка': false,
        //   'Искусство': false,
        //   'Обучение': false,
        //   'Концерт': false,
        //   'Настольные игры': false,
        //   'Гастрономия': false,
        // },
      ),
    );
    setState(() {
      Provider.of<Drugs>(context, listen: false).fetchAndSetEvents(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Navigator.of(context).pop();
    // Provider.of<Drugs>(context, listen: false).fetchAndSetEvents(false);
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        body: EventsGrid(
          categoriesForEventsScreen,
          1,
        ));
  }
}
