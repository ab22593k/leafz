import 'dart:io';

import 'package:leafz/generated/app_localizations.dart';
import 'package:leafz/router/router_config.dart';
import 'package:leafz/ui/core/app_theme.dart';
import 'package:leafz/ui/core/theme_transition.dart';
import 'package:leafz/ui/core/providers/theme_notifier.dart';
import 'package:leafz/ui/core/providers/locale_notifier.dart';
import 'package:leafz/ui/features/background/background_layers.dart';
import 'package:leafz/ui/core/layout/background_layer_layout.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  void initState() {
    if (!kIsWeb && Platform.isMacOS) {
      DesktopWindow.getWindowSize()
          .then((size) {
            DesktopWindow.setMinWindowSize(
              Size(size.height * 0.5, size.height),
            );
          })
          .onError((error, stackTrace) {
            DesktopWindow.setMinWindowSize(const Size(600, 1000));
          });
    }
    super.initState();
  }

  bool _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      for (BackgroundLayerType layerType in BackgroundLayers.types) {
        precacheImage(
          Image.asset('assets/images/background/${layerType.name}.png').image,
          context,
        );
      }
      precacheImage(
        Image.asset('assets/images/solved/solved.jpg').image,
        context,
      );
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final localeState = ref.watch(localeProvider);
    final themeState = ref.watch(themeProvider);
    final localeKey = localeState.locale?.languageCode ?? 'system';

    return DynamicColorBuilder(
      builder: (dynamicLight, dynamicDark) {
        final lightTheme = AppTheme.light(dynamicLight: dynamicLight);
        final darkTheme = AppTheme.dark(dynamicDark: dynamicDark);

        return ThemeTransitionBuilder(
          lightTheme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeState.mode,
          builder: (context, animatedTheme) {
            // No app-wide SafeArea: it would inset the entire tree, leaving
            // the status-bar and gesture-bar strips unpainted and zeroing the
            // padding every screen-level inset consumer reads. Scaffold, the
            // app bar and the bottom bar own their own insets.
            return MaterialApp.router(
              key: ValueKey(localeKey),
              debugShowCheckedModeBanner: false,
              title: 'Leafz',
              theme: animatedTheme,
              darkTheme: animatedTheme,
              themeMode: themeState.mode,
              routerConfig: AppRouter.router,
              locale: localeState.locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
            );
          },
        );
      },
    );
  }
}
