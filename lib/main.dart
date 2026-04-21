import 'dart:io';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';

import '../../flutter/packages/flutter/lib/material.dart';
import 'components/custom_toast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants/constants.dart';
import 'logic/network/request.dart';
import 'router/app_pages.dart';
import 'utils/storage_util.dart';
import 'utils/utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Utils.isDesktop) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = WindowOptions(
      minimumSize: const Size(400, 700),
      center: true,
      skipTaskbar: false,
      title: 'c001apk',
      titleBarStyle:
          Platform.isMacOS ? TitleBarStyle.hidden : TitleBarStyle.normal,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  await GStorage.init();
  HttpOverrides.global = CustomHttpOverrides();

  if (Platform.isAndroid || Platform.isIOS) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarContrastEnforced: false,
      systemStatusBarContrastEnforced: false,
      statusBarBrightness: GStorage.getBrightness(),
      systemNavigationBarIconBrightness: GStorage.getBrightness(),
    ));
  }

  Request();
  runApp(const C001APKAPP());
}

class C001APKAPP extends StatelessWidget {
  const C001APKAPP({super.key});

  @override
  Widget build(BuildContext context) {
    bool useMaterial =
        GStorage.settings.get(SettingsBoxKey.useMaterial, defaultValue: true);
    int staticColor =
        GStorage.settings.get(SettingsBoxKey.staticColor, defaultValue: 0);
    int selectedTheme =
        GStorage.settings.get(SettingsBoxKey.selectedTheme, defaultValue: 0);
    double fontScale =
        GStorage.settings.get(SettingsBoxKey.fontScale, defaultValue: 1.0);
    return DynamicColorBuilder(builder: (lightDynamic, darkDynamic) {
      ColorScheme? lightColorScheme;
      ColorScheme? darkColorScheme;
      if (lightDynamic != null && darkDynamic != null && useMaterial) {
        lightColorScheme = lightDynamic.harmonized();
        darkColorScheme = darkDynamic.harmonized();
      } else {
        lightColorScheme = ColorScheme.fromSeed(
          seedColor: Constants.seedColors[staticColor],
          brightness: Brightness.light,
        );
        darkColorScheme = ColorScheme.fromSeed(
          seedColor: Constants.seedColors[staticColor],
          brightness: Brightness.dark,
        );
      }

      return GetMaterialApp(
        title: 'c001apk',
        theme: ThemeData(
          fontFamily: 'AppFont',
          
    ),
          colorScheme: selectedTheme == 2 ? darkColorScheme : lightColorScheme,
          useMaterial3: false,
          navigationBarTheme: NavigationBarThemeData(
              surfaceTintColor: (lightDynamic != null && useMaterial)
                  ? lightColorScheme.surfaceTint
                  : lightColorScheme.surfaceContainer),
          snackBarTheme: SnackBarThemeData(
            actionTextColor: lightColorScheme.primary,
            backgroundColor: lightColorScheme.secondaryContainer,
            closeIconColor: lightColorScheme.secondary,
            contentTextStyle: TextStyle(color: lightColorScheme.secondary),
            elevation: 20,
          ),
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: <TargetPlatform, PageTransitionsBuilder>{
              TargetPlatform.android: ZoomPageTransitionsBuilder(
                allowEnterRouteSnapshotting: false,
              ),
            },
          ),
          popupMenuTheme: PopupMenuThemeData(
            surfaceTintColor: lightColorScheme.surfaceTint,
          ),
          cardTheme: CardThemeData(
            surfaceTintColor: lightColorScheme.surfaceTint,
            shadowColor: Colors.transparent,
          ),
          dialogTheme: DialogThemeData(
            surfaceTintColor: lightColorScheme.surfaceTint,
          ),
          inputDecorationTheme: InputDecorationTheme(
            fillColor: lightColorScheme.onInverseSurface,
          ),
          progressIndicatorTheme: ProgressIndicatorThemeData(
            refreshBackgroundColor: lightColorScheme.onSecondary,
          ),
        ),
        
    });
  }
}

class CustomHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..userAgent = GStorage.userAgent;
  }
}
