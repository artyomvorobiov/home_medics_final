import '/providers/address.dart';
import 'package:provider/provider.dart';

import '../providers/drugs.dart';
import '../widgets/drugs_grid.dart';
import 'creating_drug_screen.dart';
import 'package:flutter/material.dart';
import '../providers/drug.dart';

class EventsScreen extends StatefulWidget {
  static const routeName = '/events';
  const EventsScreen({Key key}) : super(key: key);

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
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
      Provider.of<Drugs>(context, listen: false).fetchAndSetEvents(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: Row(
            children: <Widget>[
              Text('Мои лекарства', style: TextStyle(color: Colors.black)),
            ],
          )),
      body: EventsGrid(null, 2),
    );
  }
}
