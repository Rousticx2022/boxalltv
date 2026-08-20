/*
Developed By: Shader Bytes
Developer and ui Designer: Pradeepta Bhattacharya
*/

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'utils/routes.dart';
import 'utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // await FirebaseAppCheck.instance.activate();
  await GetStorage.init();
  // Stripe.publishableKey = "pk_test_51M3gUjIhDgpGtBPfRgwYU91sQOF6ttkhns16Al7NptgBDA2uiq4zsB3ZPpjg8voUwnlAQooUW5LzpoTF8bI8fMkL006QJorOv6";

  Stripe.publishableKey = const String.fromEnvironment('STRIPE_KEY');
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: SystemUiOverlay.values);
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  MobileAds.instance.initialize();
  runApp(const App());
}

// - GET MATERIAL APP WIDGET
class App extends StatefulWidget {
  const App({super.key});

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(builder: (context, orientation, screenType) {
      return GetMaterialApp(
        title: "Box All TV",
        darkTheme: customAppTheme,
        onInit: () async {
          NoScreenshot.instance.screenshotOff();
        },
        themeMode: ThemeMode.dark,
        defaultTransition: Transition.cupertino,
        debugShowCheckedModeBanner: false,
        initialRoute: "/",
        getPages: Pages.allRoutes,
      );
    });
  }
}
