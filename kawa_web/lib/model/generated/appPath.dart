import 'package:dart_mappable/dart_mappable.dart';

part 'appPath.mapper.dart';

@MappableClass()
class AppPath with AppPathMappable {
  final String id;
  final String name;
  final String path;
  bool isSelected;
  String? imgPath;
  String? initPrompt;
  AppPath({
    required this.id,
    required this.name,
    required this.path,
    this.isSelected = false,
    this.imgPath,
    this.initPrompt,
  });
}
