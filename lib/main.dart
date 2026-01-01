import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:slims/config.dart';
import 'package:slims/core/utils/shared_preference.dart';
import 'package:slims/infrastructure/theme/theme.light.dart';
import 'package:slims/infrastructure/theme/theme.dark.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'infrastructure/navigation/navigation.dart';
import 'infrastructure/navigation/routes.dart';
import 'package:cached_query_flutter/cached_query_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // init locale ID
  await initializeDateFormatting('id_ID', null);

  // Setup CachedQuery dengan storage SharedPreferences + flutter lifecycle hooks
  CachedQuery.instance.configFlutter(
    storage: SharedPreferencesStorage(),
    config: QueryConfigFlutter(
      refetchDuration: const Duration(seconds: 10),
      cacheDuration: const Duration(minutes: 10),
      storageDuration: const Duration(hours: 24),
      refetchOnResume: true,
      refetchOnConnection: true,
    ),
    observers: [], // bisa ditambah DevtoolsObserver() jika perlu
  );

  var initialRoute = await Routes.initialRoute;

  runApp(
    EnvironmentsBadge(
      child: GetMaterialApp(
        initialRoute: initialRoute,
        debugShowCheckedModeBanner: false,
        getPages: Nav.routes,
        useInheritedMediaQuery: true,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.light, // default light
        transitionDuration: const Duration(milliseconds: 400),
        builder: (context, child) {
          ScreenUtil.init(
            context,
            designSize: const Size(360, 690),
            minTextAdapt: true,
            splitScreenMode: true,
          );
          return child!;
        },
      ),
    ),
  );
}

class EnvironmentsBadge extends StatelessWidget {
  final Widget child;
  const EnvironmentsBadge({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final env = ConfigEnvironments.getEnvironments()['env'];

    return env != Environments.PRODUCTION
        ? Directionality(
            textDirection: TextDirection.ltr,
            child: Banner(
              location: BannerLocation.topStart,
              message: env == Environments.DEV ? 'DEV' : 'STAGING',
              color: env == Environments.DEV ? Colors.blue : Colors.orange,
              child: child,
            ),
          )
        : SizedBox(child: child);
  }
}
