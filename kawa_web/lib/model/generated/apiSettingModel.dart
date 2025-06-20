import 'package:dart_mappable/dart_mappable.dart';

part 'apiSettingModel.mapper.dart';

@MappableClass()
class ApiSettingModel with ApiSettingModelMappable {
  final ModelType model_host;
  final List<String> model_list;
  String? model_name;
  String? api_key;
  ApiSettingModel({
    required this.model_host,
    required this.model_list,
    this.model_name,
    this.api_key,
  });
}

@MappableEnum()
enum ModelType { Gemini, Mistral }
