import 'dart:async';

import 'package:get/get.dart';

import '../../models/user.dart';
import '../../repositories/app_config_repo.dart';
import '../base/all.dart';

const _boxName = 'app_controller';
const _lastLoggedUserKey = 'logged_user';
const _isLoggedKey = 'is_logged';
const _isSeenIntroKey = 'is_seen_intro';

class AppController extends BaseController {
  @override
  String get boxName => _boxName;

  XinEnvData? apiXIN;

  @override
  void onInit() {
    _setupRestoreState();
    // _getBaseApi();
    super.onInit();
  }

  final restoreStateCompleter = Completer<void>();

  Future<void> _getBaseApi() async {
    apiXIN = await Get.find<AppConfigRepository>().fetchXinEnvData();
  }

  Future<void> _setupRestoreState() async {
    try {
      await hydrate<User, Map<String, dynamic>>(
        _lastLoggedUser,
        key: _lastLoggedUserKey,
        encoder: (value) => value?.toJson(),
        decoder: (value) =>
            value != null ? User.fromJson(value, store: false) : null,
      ).then((value) => setLoggedUser(value));

      await hydrate(_isSeenIntro, key: _isSeenIntroKey)
          .then((value) => setSeenIntro(value ?? false));

      await hydrate(_isLogged, key: _isLoggedKey)
          .then((value) => setLogged(value ?? false));
    } finally {
      restoreStateCompleter.complete();
    }
  }

  final Rx<User?> _lastLoggedUser = Rx<User?>(null);
  void setLoggedUser(User? value) => _lastLoggedUser.value = value;

  User? get lastLoggedUser => _lastLoggedUser.value;
  Rx<User?> get lastLoggedUserRx => _lastLoggedUser;

  final _isSeenIntro = false.obs;
  void setSeenIntro(bool value) => _isSeenIntro.value = value;
  bool get isSeenIntro => _isSeenIntro.value;

  final _isLogged = false.obs;
  void setLogged(bool value) => _isLogged.value = value;
  bool get isLogged => _isLogged.value;
}
