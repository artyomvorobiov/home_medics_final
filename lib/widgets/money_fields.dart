import 'package:flutter/material.dart';

class MoneyChoose extends StatelessWidget {
  TextEditingController _textEditingController = TextEditingController();
  TextEditingController _textEditingController2 = TextEditingController();
  int minPrice;
  int maxPrice;
  MoneyChoose({this.minPrice, this.maxPrice});
  @override
  Widget build(BuildContext context) {
    _textEditingController.text = minPrice.toString();
    _textEditingController2.text = maxPrice.toString();
    // print('WE BUILD POPUP');
    final deviceSize = MediaQuery.of(context).size;
    return Stack(
      children: <Widget>[
        // градиент на весь экран авторизации
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.9),
                Theme.of(context).colorScheme.secondary.withOpacity(0.9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0, 1],
            ),
          ),
        ),
        SingleChildScrollView(
          child: Container(
            height: deviceSize.height,
            width: deviceSize.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 60,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Image.asset('assets/images/palm-tree.png',
                            fit: BoxFit.fill,
                            height: 40,
                            width: 60,
                            scale: 0.8),
                      ),
                    ],
                  ),
                ),
                AlertDialog(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  title: Text(
                    "Выберите стоимость",
                    style: TextStyle(
                      fontSize: 22,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  content: new Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          maxLines: null,
                          style:
                              TextStyle(color: Theme.of(context).primaryColor),
                          decoration: InputDecoration(
                            labelText: "Введите минимальную цену",
                            labelStyle: TextStyle(
                                color: Theme.of(context).primaryColor),
                          ),
                          textInputAction: TextInputAction.next,
                          controller: _textEditingController,
                          onFieldSubmitted: (value) {},
                          validator: ((value) =>
                              value.isEmpty ? 'Please provide a name' : null),
                        ),
                      ),
                      Container(
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          maxLines: null,
                          style:
                              TextStyle(color: Theme.of(context).primaryColor),
                          decoration: InputDecoration(
                            labelText: "Введите максимальную цену",
                            labelStyle: TextStyle(
                                color: Theme.of(context).primaryColor),
                          ),
                          textInputAction: TextInputAction.next,
                          controller: _textEditingController2,
                          onFieldSubmitted: (value) {},
                          validator: ((value) =>
                              value.isEmpty ? 'Please provide a name' : null),
                        ),
                      ),
                    ],
                  ),
                  actions: <Widget>[
                    Column(
                      children: [
                        TextButton(
                          onPressed: () {
                            List<String> prices = ['0', '100000'];
                            Navigator.of(context).pop(prices);
                          },
                          style: TextButton.styleFrom(
                              foregroundColor: Theme.of(context).primaryColor),
                          child: Text(
                            'Сброс',
                            style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () {
                                List<String> prices = [
                                  minPrice.toString(),
                                  maxPrice.toString()
                                ];
                                Navigator.of(context).pop(prices);
                              },
                              style: TextButton.styleFrom(
                                  foregroundColor:
                                      Theme.of(context).primaryColor),
                              child: Text(
                                'Отменить',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(left: 50),
                              child: TextButton(
                                onPressed: () {
                                  List<String> prices = [
                                    _textEditingController.text,
                                    _textEditingController2.text
                                  ];
                                  Navigator.of(context).pop(prices);
                                },
                                style: TextButton.styleFrom(
                                    foregroundColor:
                                        Theme.of(context).primaryColor),
                                child: Text(
                                  'Применить',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
    //  return buildPopupDialog(context);
    // return Placeholder();
  }
}
