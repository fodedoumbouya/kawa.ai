//
//  Generated code. Do not modify.
//  source: project.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use subscribeRequestDescriptor instead')
const SubscribeRequest$json = {
  '1': 'SubscribeRequest',
  '2': [
    {'1': 'client_id', '3': 2, '4': 1, '5': 9, '10': 'clientId'},
  ],
};

/// Descriptor for `SubscribeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List subscribeRequestDescriptor = $convert.base64Decode(
    'ChBTdWJzY3JpYmVSZXF1ZXN0EhsKCWNsaWVudF9pZBgCIAEoCVIIY2xpZW50SWQ=');

@$core.Deprecated('Use unsubscribeRequestDescriptor instead')
const UnsubscribeRequest$json = {
  '1': 'UnsubscribeRequest',
  '2': [
    {'1': 'client_id', '3': 2, '4': 1, '5': 9, '10': 'clientId'},
  ],
};

/// Descriptor for `UnsubscribeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List unsubscribeRequestDescriptor = $convert.base64Decode(
    'ChJVbnN1YnNjcmliZVJlcXVlc3QSGwoJY2xpZW50X2lkGAIgASgJUghjbGllbnRJZA==');

@$core.Deprecated('Use unsubscribeResponseDescriptor instead')
const UnsubscribeResponse$json = {
  '1': 'UnsubscribeResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `UnsubscribeResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List unsubscribeResponseDescriptor = $convert.base64Decode(
    'ChNVbnN1YnNjcmliZVJlc3BvbnNlEhgKB3N1Y2Nlc3MYASABKAhSB3N1Y2Nlc3MSGAoHbWVzc2'
    'FnZRgCIAEoCVIHbWVzc2FnZQ==');

@$core.Deprecated('Use projectStatusUpdateDescriptor instead')
const ProjectStatusUpdate$json = {
  '1': 'ProjectStatusUpdate',
  '2': [
    {'1': 'client_id', '3': 1, '4': 1, '5': 9, '10': 'clientId'},
    {'1': 'status', '3': 2, '4': 1, '5': 9, '10': 'status'},
    {'1': 'timestamp', '3': 3, '4': 1, '5': 3, '10': 'timestamp'},
    {'1': 'metadata', '3': 4, '4': 3, '5': 11, '6': '.project.ProjectStatusUpdate.MetadataEntry', '10': 'metadata'},
  ],
  '3': [ProjectStatusUpdate_MetadataEntry$json],
};

@$core.Deprecated('Use projectStatusUpdateDescriptor instead')
const ProjectStatusUpdate_MetadataEntry$json = {
  '1': 'MetadataEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `ProjectStatusUpdate`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List projectStatusUpdateDescriptor = $convert.base64Decode(
    'ChNQcm9qZWN0U3RhdHVzVXBkYXRlEhsKCWNsaWVudF9pZBgBIAEoCVIIY2xpZW50SWQSFgoGc3'
    'RhdHVzGAIgASgJUgZzdGF0dXMSHAoJdGltZXN0YW1wGAMgASgDUgl0aW1lc3RhbXASRgoIbWV0'
    'YWRhdGEYBCADKAsyKi5wcm9qZWN0LlByb2plY3RTdGF0dXNVcGRhdGUuTWV0YWRhdGFFbnRyeV'
    'IIbWV0YWRhdGEaOwoNTWV0YWRhdGFFbnRyeRIQCgNrZXkYASABKAlSA2tleRIUCgV2YWx1ZRgC'
    'IAEoCVIFdmFsdWU6AjgB');

@$core.Deprecated('Use broadcastResponseDescriptor instead')
const BroadcastResponse$json = {
  '1': 'BroadcastResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'subscribers_notified', '3': 2, '4': 1, '5': 5, '10': 'subscribersNotified'},
    {'1': 'message', '3': 3, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `BroadcastResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List broadcastResponseDescriptor = $convert.base64Decode(
    'ChFCcm9hZGNhc3RSZXNwb25zZRIYCgdzdWNjZXNzGAEgASgIUgdzdWNjZXNzEjEKFHN1YnNjcm'
    'liZXJzX25vdGlmaWVkGAIgASgFUhNzdWJzY3JpYmVyc05vdGlmaWVkEhgKB21lc3NhZ2UYAyAB'
    'KAlSB21lc3NhZ2U=');

