//@GeneratedMicroModule;BdayaFlutterCommonPackageModule;package:bdaya_flutter_common/src/get_it_config.module.dart
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unnecessary_lambdas
// ignore_for_file: lines_longer_than_80_chars
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i2;

import 'package:bdaya_flutter_common/src/services/app_theme_service.dart'
    as _i3;
import 'package:bdaya_flutter_common/src/services/go_router_refresh_service.dart'
    as _i4;
import 'package:injectable/injectable.dart' as _i1;

class BdayaFlutterCommonPackageModule extends _i1.MicroPackageModule {
  // initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i2.FutureOr<void> init(_i1.GetItHelper gh) {
    gh.lazySingleton<_i3.BdayaAppThemeServiceBase>(
        () => _i3.BdayaLocalAppThemeService());
    gh.lazySingleton<_i4.GoRouterRefreshService>(
      () => _i4.GoRouterRefreshService(),
      dispose: (i) => i.dispose(),
    );
  }
}
