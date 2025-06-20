//
//  Generated code. Do not modify.
//  source: project.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'project.pb.dart' as $0;

export 'project.pb.dart';

@$pb.GrpcServiceName('project.ProjectStatusService')
class ProjectStatusServiceClient extends $grpc.Client {
  static final _$subscribeToProject = $grpc.ClientMethod<$0.SubscribeRequest, $0.ProjectStatusUpdate>(
      '/project.ProjectStatusService/SubscribeToProject',
      ($0.SubscribeRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.ProjectStatusUpdate.fromBuffer(value));
  static final _$unsubscribeFromProject = $grpc.ClientMethod<$0.UnsubscribeRequest, $0.UnsubscribeResponse>(
      '/project.ProjectStatusService/UnsubscribeFromProject',
      ($0.UnsubscribeRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.UnsubscribeResponse.fromBuffer(value));
  static final _$broadcastStatus = $grpc.ClientMethod<$0.ProjectStatusUpdate, $0.BroadcastResponse>(
      '/project.ProjectStatusService/BroadcastStatus',
      ($0.ProjectStatusUpdate value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.BroadcastResponse.fromBuffer(value));

  ProjectStatusServiceClient(super.channel,
      {super.options,
      super.interceptors});

  $grpc.ResponseStream<$0.ProjectStatusUpdate> subscribeToProject($0.SubscribeRequest request, {$grpc.CallOptions? options}) {
    return $createStreamingCall(_$subscribeToProject, $async.Stream.fromIterable([request]), options: options);
  }

  $grpc.ResponseFuture<$0.UnsubscribeResponse> unsubscribeFromProject($0.UnsubscribeRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$unsubscribeFromProject, request, options: options);
  }

  $grpc.ResponseFuture<$0.BroadcastResponse> broadcastStatus($0.ProjectStatusUpdate request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$broadcastStatus, request, options: options);
  }
}

@$pb.GrpcServiceName('project.ProjectStatusService')
abstract class ProjectStatusServiceBase extends $grpc.Service {
  $core.String get $name => 'project.ProjectStatusService';

  ProjectStatusServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.SubscribeRequest, $0.ProjectStatusUpdate>(
        'SubscribeToProject',
        subscribeToProject_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.SubscribeRequest.fromBuffer(value),
        ($0.ProjectStatusUpdate value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UnsubscribeRequest, $0.UnsubscribeResponse>(
        'UnsubscribeFromProject',
        unsubscribeFromProject_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.UnsubscribeRequest.fromBuffer(value),
        ($0.UnsubscribeResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ProjectStatusUpdate, $0.BroadcastResponse>(
        'BroadcastStatus',
        broadcastStatus_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ProjectStatusUpdate.fromBuffer(value),
        ($0.BroadcastResponse value) => value.writeToBuffer()));
  }

  $async.Stream<$0.ProjectStatusUpdate> subscribeToProject_Pre($grpc.ServiceCall $call, $async.Future<$0.SubscribeRequest> $request) async* {
    yield* subscribeToProject($call, await $request);
  }

  $async.Future<$0.UnsubscribeResponse> unsubscribeFromProject_Pre($grpc.ServiceCall $call, $async.Future<$0.UnsubscribeRequest> $request) async {
    return unsubscribeFromProject($call, await $request);
  }

  $async.Future<$0.BroadcastResponse> broadcastStatus_Pre($grpc.ServiceCall $call, $async.Future<$0.ProjectStatusUpdate> $request) async {
    return broadcastStatus($call, await $request);
  }

  $async.Stream<$0.ProjectStatusUpdate> subscribeToProject($grpc.ServiceCall call, $0.SubscribeRequest request);
  $async.Future<$0.UnsubscribeResponse> unsubscribeFromProject($grpc.ServiceCall call, $0.UnsubscribeRequest request);
  $async.Future<$0.BroadcastResponse> broadcastStatus($grpc.ServiceCall call, $0.ProjectStatusUpdate request);
}
