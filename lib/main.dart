import 'package:nope/screens/all_drugs_screen.dart';
import 'package:nope/screens/family_screen.dart';

import '/screens/comments_screen.dart';

import '/providers/color.dart';
import '/screens/auth_screen.dart';
import '/screens/main_screen.dart';
import '/screens/personal_profile.dart';
import '/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'providers/drug.dart';
import 'providers/drugs.dart';
import 'providers/profiles.dart';
import 'screens/creating_drug_screen.dart';
import 'screens/drug_detail_screen.dart';
import 'screens/drugs_screen.dart';
import 'screens/personal_info_screen.dart';
import 'screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './providers/screen_number.dart';
import './screens/search_screen.dart';

import './providers/auth.dart';
import 'screens/favorite_drugs_screen.dart';

// void main() => runApp(MyApp());
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

const MaterialColor kPrimaryColor = const MaterialColor(
  0xFF40E0D0,
  const <int, Color>{
    50: const Color(0xFF40E0D0),
  },
);

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    int firstColor = ColorTheme.mainFirstColor;
    int secondColor = ColorTheme.mainSecColor;
    // print("COLORS: $firstColor $secondColor");
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Auth(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Drug(id: "fff"),
        ),
        ChangeNotifierProvider(
          create: (ctx) => ScreenNumber(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => ColorTheme(),
        ),
        ChangeNotifierProxyProvider<Auth, Drugs>(
          create: null,
          update: (ctx, auth, previousProducts) => Drugs(
            auth.token,
            auth.userId,
            previousProducts == null ? [] : previousProducts.drugs,
          ),
        ),
        ChangeNotifierProxyProvider<Auth, Profiles>(
          create: null,
          update: (ctx, auth, previousProfiles) => Profiles(
            auth.token,
            auth.userId,
            previousProfiles == null ? [] : previousProfiles.profiles,
          ),
        ),
      ],
      child: Consumer<ColorTheme>(
        builder: (ctx, color, _) => func(),
      ),
    );
  }

  Widget func() {
    // print("CONSUMER");
    return Consumer<Auth>(
      builder: (ctx, auth, _) => GetMaterialApp(
        title: 'Palm',
        theme: ThemeData(
          primaryColor: MaterialColor(
            ColorTheme.mainFirstColor,
            <int, Color>{
              50: Color(ColorTheme.mainFirstColor),
            },
          ),
          colorScheme: ColorScheme.fromSwatch().copyWith(
              secondary: MaterialColor(
            ColorTheme.mainSecColor,
            <int, Color>{
              50: Color(ColorTheme.mainSecColor),
            },
          )),
          fontFamily: 'Lato',
          pageTransitionsTheme: PageTransitionsTheme(
            builders: {
              // TargetPlatform.android: CustomPageTransitionBuilder(),
              // TargetPlatform.iOS: CustomPageTransitionBuilder(),
            },
          ),
        ),
        home:
            // MapScreen(),
            auth.isAuth
                ? MainScreen()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (ctx, authResultSnapshot) =>
                        authResultSnapshot.connectionState ==
                                ConnectionState.waiting
                            ? SplashScreen()
                            : AuthScreen(),
                  ),
        routes: {
          PersonalInfoScreen.routeName: (ctx) => PersonalInfoScreen(),
          SettingsScreen.routeName: (ctx) => SettingsScreen(),
          EventsScreen.routeName: (ctx) => EventsScreen(),
          AllDrugs.routeName: (ctx) => AllDrugs(),
          CreatingEventScreen.routeName: (ctx) => CreatingEventScreen(),
          EventDetailScreen.routeName: (ctx) => EventDetailScreen(),
          MainScreen.routeName: (ctx) => MainScreen(),
          FavoriteEventsScreen.routeName: (ctx) => FavoriteEventsScreen(),
          PersonalProfileScreen.routeName: (ctx) => PersonalProfileScreen(),
          CommentsScreen.routeName: (ctx) => CommentsScreen(),
          SearchScreen.routeName: (ctx) => SearchScreen(),
          FamilyMembersScreen.routeName: (ctx) => FamilyMembersScreen(),
        },
      ),
    );
  }
}
