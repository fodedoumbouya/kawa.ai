import 'package:kawa_web/common/dataPersitence/dataPersistence.dart';
import 'package:kawa_web/common/utils/constant.dart';
import 'package:kawa_web/model/chatMessage.dart';
import 'package:kawa_web/model/generated/project.dart';
import 'package:kawa_web/model/generated/user.dart';
import 'package:kawa_web/widgets/coreToast.dart';
import 'package:pocketbase/pocketbase.dart';

class UserManagement {
  // singleton
  static final UserManagement _instance = UserManagement._internal();
  factory UserManagement() => _instance;
  UserManagement._internal();

  static final _pb = PocketBase('http://${KConstant.serverHost}');

  static Future<UserModel> getUser() async {
    final resp = await _pb.collection('users').getOne("");
    return UserModelMapper.fromMap(resp.data);
  }

  static Future<UserModel?> loginUser(
      {required String email, required String password}) async {
    try {
      final resp =
          await _pb.collection('users').authWithPassword(email, password);
      final data = resp.record.data;
      data["tokenKey"] = resp.token;
      if (data["settings"] == null || data["settings"].toString().isEmpty) {
        data["settings"] = null;
      }
      final userm = UserModelMapper.fromMap(data);
      return userm;
    } catch (e) {
      CoreToast.showError((e as ClientException).response["message"]);
      return null;
    }
  }

  static Future<bool> signUpUser(
      {required String email,
      required String password,
      required String passwordConfirm}) async {
    try {
      await _pb.collection('users').create(body: {
        "email": email,
        "password": password,
        "passwordConfirm": passwordConfirm,
      });
      return true;
    } catch (e) {
      CoreToast.showError(
          (e as ClientException).response["data"]["password"]["message"]);
      return false;
    }
  }

  static Future<List<Project>> getProjects() async {
    final resp = await _pb.collection('projects').getFullList(
          filter: "user.id = '${DataPersistence.getAccount()?.id}'",
          sort: "-created",
        );
    return resp.map((e) => ProjectMapper.fromMap(e.data)).toList();
  }

  static Future<Project> getProject(String id) async {
    final resp = await _pb.collection('projects').getOne(id);
    return ProjectMapper.fromMap(resp.data);
  }

  static Future<String?> getProjectHost(String id) async {
    try {
      final resp = await _pb
          .collection('project_address')
          .getFirstListItem("project.id = '$id'");

      if (resp.data["url"] == null || resp.data["url"].toString().isEmpty) {
        return null;
      }

      return resp.data["url"];
    } catch (e) {
      return null;
    }
  }

  // subscribe to messages collection with chat id
  static Future<bool> subscribeToMessages(
      String projectId, void Function(RecordSubscriptionEvent) callback) async {
    final resp = await _pb.collection("chat").getFirstListItem(
          "project = '$projectId'",
        );
    final chatId = resp.data["id"];
    if (chatId == null || chatId.toString().isEmpty) {
      return false;
    }

    _pb.collection('message').subscribe("*", callback, query: {
      "filter": "chat = '$chatId'",
    });
    return true;

    //
  }

  // getAllMessages with projectId
  static Future<List<ChatMessage>> getAllMessages(String projectId) async {
    final resp = await _pb.collection("chat").getFirstListItem(
          "project = '$projectId'",
        );
    final chatId = resp.data["id"];
    if (chatId == null || chatId.toString().isEmpty) {
      return [];
    }
    final respMsg = await _pb.collection('message').getFullList(
          filter: "chat = '$chatId'",
          sort: "created",
        );
    return respMsg
        .map((e) => ChatMessage(
              id: e.data["id"],
              text: e.data["content"],
              isUser: e.data["role"] == "user",
              created: DateTime.parse(e.data["created"]),
              updated: DateTime.parse(e.data["updated"]),
            ))
        .toList();
  }
}
