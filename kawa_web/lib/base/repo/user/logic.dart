import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kawa_web/base/baseStateNotifier.dart';
import 'package:kawa_web/common/dataPersitence/dataPersistence.dart';
import 'package:kawa_web/model/generated/user.dart';

final userProvider = StateNotifierProvider<UserNotifier, UserModel?>((_) {
  return UserNotifier();
});

class UserNotifier extends BaseStateNotifier<UserModel?> {
  UserNotifier() : super(DataPersistence.getAccount());

  UserModel? get getUser => state;

  setUser(UserModel? newUser) {
    if (newUser != null) {
      state = newUser;
      DataPersistence.saveAccount(newUser);
    } else {
      state = null;
      DataPersistence.deleteAccount();
    }
  }

  deleteUser() {
    state = null;
    DataPersistence.deleteAccount();
  }
}
