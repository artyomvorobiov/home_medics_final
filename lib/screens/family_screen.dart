import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/providers/profiles.dart';

class FamilyMembersScreen extends StatelessWidget {
  static const routeName = '/family-members';

  @override
  Widget build(BuildContext context) {
    final profilesProvider = Provider.of<Profiles>(context);
    final currentProfile = Profiles.curProfile;

    if (currentProfile.familyId == null || currentProfile.familyId.isEmpty) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        body: Center(
          child: Text(
            'Ваш идентификатор семьи пуст. Введите его в личных данных',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    final familyMembers = profilesProvider.profiles
        .where((profile) =>
            profile.familyId != null &&
            profile.familyId.isNotEmpty &&
            profile.familyId == currentProfile.familyId)
        .toList();

    if (familyMembers.isEmpty) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        body: Center(
          child: Text(
            'В вашей семье никто не состоит',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: ListView.separated(
        padding: EdgeInsets.only(top: 16),
        itemCount: familyMembers.length,
        separatorBuilder: (BuildContext context, int index) {
          return Divider();
        },
        itemBuilder: (ctx, index) {
          final member = familyMembers[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: Icon(
                Icons.person,
                color: Colors.white,
              ),
            ),
            title: Text(
              '${index + 1}. Никнейм: ${member.username.isNotEmpty ? member.username : "отсутствует"}',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'Имя: ${member.firstName.isNotEmpty ? member.firstName : "отсутствует"} \nФамилия: ${member.lastName.isNotEmpty ? member.lastName : "отсутствует"}',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 14,
              ),
            ),
            trailing: currentProfile.creator && member.id != currentProfile.id
                ? IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      // Вызываем метод для удаления профиля
                      profilesProvider.removeProfile(member.id);
                    },
                  )
                : null, // Отображаем кнопку удаления только для создателя
          );
        },
      ),
    );
  }
}
