import 'package:flutter/material.dart';

class SettingField extends StatelessWidget {
  final Function function;
  final String fieldName;
  final IconData icon;

  const SettingField(this.fieldName, this.function, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 70,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
        border: Border.all(
          color: Theme.of(context).primaryColor,
        ),
      ),
      margin: EdgeInsets.only(top: 10.0),
      child: Align(
        alignment: Alignment
            .center, // Выравнивание по центру как по горизонтали, так и по вертикали
        child: InkWell(
          onTap: function,
          child: Row(
            mainAxisAlignment: MainAxisAlignment
                .start, // Выравнивание по центру по горизонтали
            children: [
              Icon(
                icon, // Иконка "Личные данные"
                size: 30.0,
                color: Theme.of(context).colorScheme.secondary,
              ),
              SizedBox(width: 5),
              Text(
                fieldName,
                style: TextStyle(
                  fontSize: 22,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
