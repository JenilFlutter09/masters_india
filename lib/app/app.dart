import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app_pages.dart';
import 'app_theme.dart';

class MastersIndiaApp extends StatelessWidget {
  const MastersIndiaApp({required this.initialRoute, super.key});

  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MastersIndia Coil Operations',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: initialRoute,
      getPages: AppPages.pages,
      defaultTransition: Transition.cupertino,
    );
  }
}
