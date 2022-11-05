import 'dart:math';

import 'package:example/common.dart';

@lazySingleton
class DashboardShellController extends BdayaCombinedController {
  final AuthService authService;
  final random = Random();

  DashboardShellController(this.authService);

  String generateRandomOrderId() => List.generate(
        16,
        (index) => (random.nextInt(9) + 1).toString(),
      ).join();

  Future<void> doLogout() async {
    try {
      isLoading.$ = true;
      await authService.logout();
    } catch (e, st) {
      logger.severe('Error while logging out', e, st);
    } finally {
      isLoading.$ = false;
    }
  }
}
