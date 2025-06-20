import 'package:dart_mappable/dart_mappable.dart';

part 'gitResponse.mapper.dart';

// Success      bool   `json:"success"`
// 	Message      string `json:"message,omitempty"`
// 	CanBackward  bool   `json:"canBackward,omitempty"`
// 	CanForward   bool   `json:"canForward,omitempty"`
// 	CurrentState string `json:"currentState,omitempty"`

@MappableClass()
class GitResponse with GitResponseMappable {
  final bool success;
  final String? message;
  final bool? canBackward;
  final bool? canForward;
  final String? currentState;
  GitResponse({
    required this.success,
    this.message,
    this.canBackward,
    this.canForward,
    this.currentState,
  });
}
