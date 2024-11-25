// This file is automatically generated, so please do not edit it.
// @generated by `flutter_rust_bridge`@ 2.5.0.

// ignore_for_file: unused_import, unused_element, unnecessary_import, duplicate_ignore, invalid_use_of_internal_member, annotate_overrides, non_constant_identifier_names, curly_braces_in_flow_control_structures, prefer_const_literals_to_create_immutables, unused_field

// Static analysis wrongly picks the IO variant, thus ignore this
// ignore_for_file: argument_type_not_assignable

import 'app.dart';
import 'dart:async';
import 'dart:convert';
import 'frb_generated.dart';
import 'lib.dart';
import 'model/source.dart';
import 'model/video.dart';
import 'native.dart';
import 'native/db_api.dart';
import 'native/home_api.dart';
import 'native/system_api.dart';
import 'native/task_api.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated_web.dart';
import 'task.dart';
import 'task/crawler.dart';

abstract class RustLibApiImplPlatform extends BaseApiImpl<RustLibWire> {
  RustLibApiImplPlatform({
    required super.handler,
    required super.wire,
    required super.generalizedFrbRustBinding,
    required super.portManager,
  });

  CrossPlatformFinalizerArg
      get rust_arc_decrement_strong_count_HomeVideoDataPtr => wire
          .rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerHomeVideoData;

  CrossPlatformFinalizerArg
      get rust_arc_decrement_strong_count_ListenerHandlePtr => wire
          .rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerListenerHandle;

  CrossPlatformFinalizerArg get rust_arc_decrement_strong_count_MetadataPtr => wire
      .rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMetadata;

  CrossPlatformFinalizerArg get rust_arc_decrement_strong_count_PathBufPtr => wire
      .rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerPathBuf;

  CrossPlatformFinalizerArg get rust_arc_decrement_strong_count_SourcePtr => wire
      .rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerSource;

  CrossPlatformFinalizerArg get rust_arc_decrement_strong_count_TaskConfigPtr =>
      wire.rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerTaskConfig;

  CrossPlatformFinalizerArg
      get rust_arc_decrement_strong_count_TemplateVideoDataInterimPtr => wire
          .rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerTemplateVideoDataInterim;

  @protected
  AnyhowException dco_decode_AnyhowException(dynamic raw);

  @protected
  HomeVideoData
      dco_decode_Auto_Owned_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerHomeVideoData(
          dynamic raw);

  @protected
  ListenerHandle
      dco_decode_Auto_Owned_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerListenerHandle(
          dynamic raw);

  @protected
  Metadata
      dco_decode_Auto_Owned_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMetadata(
          dynamic raw);

  @protected
  PathBuf
      dco_decode_Auto_Owned_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerPathBuf(
          dynamic raw);

  @protected
  Source
      dco_decode_Auto_Owned_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerSource(
          dynamic raw);

  @protected
  TaskConfig
      dco_decode_Auto_Owned_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerTaskConfig(
          dynamic raw);

  @protected
  TemplateVideoDataInterim
      dco_decode_Auto_Owned_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerTemplateVideoDataInterim(
          dynamic raw);

  @protected
  HomeVideoData
      dco_decode_Auto_RefMut_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerHomeVideoData(
          dynamic raw);

  @protected
  HomeVideoData
      dco_decode_Auto_Ref_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerHomeVideoData(
          dynamic raw);

  @protected
  Metadata
      dco_decode_Auto_Ref_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMetadata(
          dynamic raw);

  @protected
  Source
      dco_decode_Auto_Ref_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerSource(
          dynamic raw);

  @protected
  TaskConfig
      dco_decode_Auto_Ref_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerTaskConfig(
          dynamic raw);

  @protected
  DateTime dco_decode_Chrono_Local(dynamic raw);

  @protected
  FutureOr<void> Function(String, TaskStatus)
      dco_decode_DartFn_Inputs_String_task_status_Output_unit_AnyhowException(
          dynamic raw);

  @protected
  FutureOr<void> Function()
      dco_decode_DartFn_Inputs__Output_unit_AnyhowException(dynamic raw);

  @protected
  FutureOr<void> Function(bool)
      dco_decode_DartFn_Inputs_bool_Output_unit_AnyhowException(dynamic raw);

  @protected
  FutureOr<void> Function(PoolStatus)
      dco_decode_DartFn_Inputs_pool_status_Output_unit_AnyhowException(
          dynamic raw);

  @protected
  Object dco_decode_DartOpaque(dynamic raw);

  @protected
  Map<int, String> dco_decode_Map_u_32_String(dynamic raw);

  @protected
  Map<int, Uint32List> dco_decode_Map_u_32_list_prim_u_32_strict(dynamic raw);

  @protected
  HomeVideoData
      dco_decode_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerHomeVideoData(
          dynamic raw);

  @protected
  ListenerHandle
      dco_decode_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerListenerHandle(
          dynamic raw);

  @protected
  Metadata
      dco_decode_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMetadata(
          dynamic raw);

  @protected
  PathBuf
      dco_decode_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerPathBuf(
          dynamic raw);

  @protected
  Source
      dco_decode_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerSource(
          dynamic raw);

  @protected
  TaskConfig
      dco_decode_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerTaskConfig(
          dynamic raw);

  @protected
  TemplateVideoDataInterim
      dco_decode_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerTemplateVideoDataInterim(
          dynamic raw);

  @protected
  String dco_decode_String(dynamic raw);

  @protected
  Attr dco_decode_attr(dynamic raw);

  @protected
  bool dco_decode_bool(dynamic raw);

  @protected
  int dco_decode_box_autoadd_u_32(dynamic raw);

  @protected
  BigInt dco_decode_box_autoadd_u_64(dynamic raw);

  @protected
  CrawlerTemplate dco_decode_crawler_template(dynamic raw);

  @protected
  double dco_decode_f_32(dynamic raw);

  @protected
  HomeVideo dco_decode_home_video(dynamic raw);

  @protected
  HttpConfig dco_decode_http_config(dynamic raw);

  @protected
  int dco_decode_i_32(dynamic raw);

  @protected
  PlatformInt64 dco_decode_i_64(dynamic raw);

  @protected
  PlatformInt64 dco_decode_isize(dynamic raw);

  @protected
  List<String> dco_decode_list_String(dynamic raw);

  @protected
  List<Attr> dco_decode_list_attr(dynamic raw);

  @protected
  List<CrawlerTemplate> dco_decode_list_crawler_template(dynamic raw);

  @protected
  List<HomeVideo> dco_decode_list_home_video(dynamic raw);

  @protected
  List<int> dco_decode_list_prim_u_32_loose(dynamic raw);

  @protected
  Uint32List dco_decode_list_prim_u_32_strict(dynamic raw);

  @protected
  Uint8List dco_decode_list_prim_u_8_strict(dynamic raw);

  @protected
  List<(String, TaskOperationalData)>
      dco_decode_list_record_string_task_operational_data(dynamic raw);

  @protected
  List<(int, Uint32List)> dco_decode_list_record_u_32_list_prim_u_32_strict(
      dynamic raw);

  @protected
  List<(int, String)> dco_decode_list_record_u_32_string(dynamic raw);

  @protected
  List<(int, int)> dco_decode_list_record_u_32_u_8(dynamic raw);

  @protected
  List<TaskMetadata> dco_decode_list_task_metadata(dynamic raw);

  @protected
  List<UntreatedVideo> dco_decode_list_untreated_video(dynamic raw);

  @protected
  String? dco_decode_opt_String(dynamic raw);

  @protected
  int? dco_decode_opt_box_autoadd_u_32(dynamic raw);

  @protected
  BigInt? dco_decode_opt_box_autoadd_u_64(dynamic raw);

  @protected
  PoolData dco_decode_pool_data(dynamic raw);

  @protected
  PoolStatus dco_decode_pool_status(dynamic raw);

  @protected
  (int?, int?) dco_decode_record_opt_box_autoadd_u_32_opt_box_autoadd_u_32(
      dynamic raw);

  @protected
  (BigInt?, BigInt?)
      dco_decode_record_opt_box_autoadd_u_64_opt_box_autoadd_u_64(dynamic raw);

  @protected
  (String, TaskOperationalData) dco_decode_record_string_task_operational_data(
      dynamic raw);

  @protected
  (int, Uint32List) dco_decode_record_u_32_list_prim_u_32_strict(dynamic raw);

  @protected
  (int, String) dco_decode_record_u_32_string(dynamic raw);

  @protected
  (int, int) dco_decode_record_u_32_u_8(dynamic raw);

  @protected
  TaskMetadata dco_decode_task_metadata(dynamic raw);

  @protected
  TaskOperationalData dco_decode_task_operational_data(dynamic raw);

  @protected
  TaskStatus dco_decode_task_status(dynamic raw);

  @protected
  int dco_decode_u_16(dynamic raw);

  @protected
  int dco_decode_u_32(dynamic raw);

  @protected
  BigInt dco_decode_u_64(dynamic raw);

  @protected
  int dco_decode_u_8(dynamic raw);

  @protected
  void dco_decode_unit(dynamic raw);

  @protected
  UntreatedVideo dco_decode_untreated_video(dynamic raw);

  @protected
  BigInt dco_decode_usize(dynamic raw);

  @protected
  AnyhowException sse_decode_AnyhowException(SseDeserializer deserializer);

  @protected
  HomeVideoData
      sse_decode_Auto_Owned_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerHomeVideoData(
          SseDeserializer deserializer);

  @protected
  ListenerHandle
      sse_decode_Auto_Owned_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerListenerHandle(
          SseDeserializer deserializer);

  @protected
  Metadata
      sse_decode_Auto_Owned_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMetadata(
          SseDeserializer deserializer);

  @protected
  PathBuf
      sse_decode_Auto_Owned_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerPathBuf(
          SseDeserializer deserializer);

  @protected
  Source
      sse_decode_Auto_Owned_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerSource(
          SseDeserializer deserializer);

  @protected
  TaskConfig
      sse_decode_Auto_Owned_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerTaskConfig(
          SseDeserializer deserializer);

  @protected
  TemplateVideoDataInterim
      sse_decode_Auto_Owned_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerTemplateVideoDataInterim(
          SseDeserializer deserializer);

  @protected
  HomeVideoData
      sse_decode_Auto_RefMut_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerHomeVideoData(
          SseDeserializer deserializer);

  @protected
  HomeVideoData
      sse_decode_Auto_Ref_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerHomeVideoData(
          SseDeserializer deserializer);

  @protected
  Metadata
      sse_decode_Auto_Ref_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMetadata(
          SseDeserializer deserializer);

  @protected
  Source
      sse_decode_Auto_Ref_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerSource(
          SseDeserializer deserializer);

  @protected
  TaskConfig
      sse_decode_Auto_Ref_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerTaskConfig(
          SseDeserializer deserializer);

  @protected
  DateTime sse_decode_Chrono_Local(SseDeserializer deserializer);

  @protected
  Object sse_decode_DartOpaque(SseDeserializer deserializer);

  @protected
  Map<int, String> sse_decode_Map_u_32_String(SseDeserializer deserializer);

  @protected
  Map<int, Uint32List> sse_decode_Map_u_32_list_prim_u_32_strict(
      SseDeserializer deserializer);

  @protected
  HomeVideoData
      sse_decode_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerHomeVideoData(
          SseDeserializer deserializer);

  @protected
  ListenerHandle
      sse_decode_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerListenerHandle(
          SseDeserializer deserializer);

  @protected
  Metadata
      sse_decode_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMetadata(
          SseDeserializer deserializer);

  @protected
  PathBuf
      sse_decode_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerPathBuf(
          SseDeserializer deserializer);

  @protected
  Source
      sse_decode_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerSource(
          SseDeserializer deserializer);

  @protected
  TaskConfig
      sse_decode_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerTaskConfig(
          SseDeserializer deserializer);

  @protected
  TemplateVideoDataInterim
      sse_decode_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerTemplateVideoDataInterim(
          SseDeserializer deserializer);

  @protected
  String sse_decode_String(SseDeserializer deserializer);

  @protected
  Attr sse_decode_attr(SseDeserializer deserializer);

  @protected
  bool sse_decode_bool(SseDeserializer deserializer);

  @protected
  int sse_decode_box_autoadd_u_32(SseDeserializer deserializer);

  @protected
  BigInt sse_decode_box_autoadd_u_64(SseDeserializer deserializer);

  @protected
  CrawlerTemplate sse_decode_crawler_template(SseDeserializer deserializer);

  @protected
  double sse_decode_f_32(SseDeserializer deserializer);

  @protected
  HomeVideo sse_decode_home_video(SseDeserializer deserializer);

  @protected
  HttpConfig sse_decode_http_config(SseDeserializer deserializer);

  @protected
  int sse_decode_i_32(SseDeserializer deserializer);

  @protected
  PlatformInt64 sse_decode_i_64(SseDeserializer deserializer);

  @protected
  PlatformInt64 sse_decode_isize(SseDeserializer deserializer);

  @protected
  List<String> sse_decode_list_String(SseDeserializer deserializer);

  @protected
  List<Attr> sse_decode_list_attr(SseDeserializer deserializer);

  @protected
  List<CrawlerTemplate> sse_decode_list_crawler_template(
      SseDeserializer deserializer);

  @protected
  List<HomeVideo> sse_decode_list_home_video(SseDeserializer deserializer);

  @protected
  List<int> sse_decode_list_prim_u_32_loose(SseDeserializer deserializer);

  @protected
  Uint32List sse_decode_list_prim_u_32_strict(SseDeserializer deserializer);

  @protected
  Uint8List sse_decode_list_prim_u_8_strict(SseDeserializer deserializer);

  @protected
  List<(String, TaskOperationalData)>
      sse_decode_list_record_string_task_operational_data(
          SseDeserializer deserializer);

  @protected
  List<(int, Uint32List)> sse_decode_list_record_u_32_list_prim_u_32_strict(
      SseDeserializer deserializer);

  @protected
  List<(int, String)> sse_decode_list_record_u_32_string(
      SseDeserializer deserializer);

  @protected
  List<(int, int)> sse_decode_list_record_u_32_u_8(
      SseDeserializer deserializer);

  @protected
  List<TaskMetadata> sse_decode_list_task_metadata(
      SseDeserializer deserializer);

  @protected
  List<UntreatedVideo> sse_decode_list_untreated_video(
      SseDeserializer deserializer);

  @protected
  String? sse_decode_opt_String(SseDeserializer deserializer);

  @protected
  int? sse_decode_opt_box_autoadd_u_32(SseDeserializer deserializer);

  @protected
  BigInt? sse_decode_opt_box_autoadd_u_64(SseDeserializer deserializer);

  @protected
  PoolData sse_decode_pool_data(SseDeserializer deserializer);

  @protected
  PoolStatus sse_decode_pool_status(SseDeserializer deserializer);

  @protected
  (int?, int?) sse_decode_record_opt_box_autoadd_u_32_opt_box_autoadd_u_32(
      SseDeserializer deserializer);

  @protected
  (BigInt?, BigInt?)
      sse_decode_record_opt_box_autoadd_u_64_opt_box_autoadd_u_64(
          SseDeserializer deserializer);

  @protected
  (String, TaskOperationalData) sse_decode_record_string_task_operational_data(
      SseDeserializer deserializer);

  @protected
  (int, Uint32List) sse_decode_record_u_32_list_prim_u_32_strict(
      SseDeserializer deserializer);

  @protected
  (int, String) sse_decode_record_u_32_string(SseDeserializer deserializer);

  @protected
  (int, int) sse_decode_record_u_32_u_8(SseDeserializer deserializer);

  @protected
  TaskMetadata sse_decode_task_metadata(SseDeserializer deserializer);

  @protected
  TaskOperationalData sse_decode_task_operational_data(
      SseDeserializer deserializer);

  @protected
  TaskStatus sse_decode_task_status(SseDeserializer deserializer);

  @protected
  int sse_decode_u_16(SseDeserializer deserializer);

  @protected
  int sse_decode_u_32(SseDeserializer deserializer);

  @protected
  BigInt sse_decode_u_64(SseDeserializer deserializer);

  @protected
  int sse_decode_u_8(SseDeserializer deserializer);

  @protected
  void sse_decode_unit(SseDeserializer deserializer);

  @protected
  UntreatedVideo sse_decode_untreated_video(SseDeserializer deserializer);

  @protected
  BigInt sse_decode_usize(SseDeserializer deserializer);

  @protected
  void sse_encode_AnyhowException(
      AnyhowException self, SseSerializer serializer);

  @protected
  void
      sse_encode_Auto_Owned_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerHomeVideoData(
          HomeVideoData self, SseSerializer serializer);

  @protected
  void
      sse_encode_Auto_Owned_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerListenerHandle(
          ListenerHandle self, SseSerializer serializer);

  @protected
  void
      sse_encode_Auto_Owned_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMetadata(
          Metadata self, SseSerializer serializer);

  @protected
  void
      sse_encode_Auto_Owned_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerPathBuf(
          PathBuf self, SseSerializer serializer);

  @protected
  void
      sse_encode_Auto_Owned_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerSource(
          Source self, SseSerializer serializer);

  @protected
  void
      sse_encode_Auto_Owned_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerTaskConfig(
          TaskConfig self, SseSerializer serializer);

  @protected
  void
      sse_encode_Auto_Owned_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerTemplateVideoDataInterim(
          TemplateVideoDataInterim self, SseSerializer serializer);

  @protected
  void
      sse_encode_Auto_RefMut_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerHomeVideoData(
          HomeVideoData self, SseSerializer serializer);

  @protected
  void
      sse_encode_Auto_Ref_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerHomeVideoData(
          HomeVideoData self, SseSerializer serializer);

  @protected
  void
      sse_encode_Auto_Ref_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMetadata(
          Metadata self, SseSerializer serializer);

  @protected
  void
      sse_encode_Auto_Ref_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerSource(
          Source self, SseSerializer serializer);

  @protected
  void
      sse_encode_Auto_Ref_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerTaskConfig(
          TaskConfig self, SseSerializer serializer);

  @protected
  void sse_encode_Chrono_Local(DateTime self, SseSerializer serializer);

  @protected
  void sse_encode_DartFn_Inputs_String_task_status_Output_unit_AnyhowException(
      FutureOr<void> Function(String, TaskStatus) self,
      SseSerializer serializer);

  @protected
  void sse_encode_DartFn_Inputs__Output_unit_AnyhowException(
      FutureOr<void> Function() self, SseSerializer serializer);

  @protected
  void sse_encode_DartFn_Inputs_bool_Output_unit_AnyhowException(
      FutureOr<void> Function(bool) self, SseSerializer serializer);

  @protected
  void sse_encode_DartFn_Inputs_pool_status_Output_unit_AnyhowException(
      FutureOr<void> Function(PoolStatus) self, SseSerializer serializer);

  @protected
  void sse_encode_DartOpaque(Object self, SseSerializer serializer);

  @protected
  void sse_encode_Map_u_32_String(
      Map<int, String> self, SseSerializer serializer);

  @protected
  void sse_encode_Map_u_32_list_prim_u_32_strict(
      Map<int, Uint32List> self, SseSerializer serializer);

  @protected
  void
      sse_encode_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerHomeVideoData(
          HomeVideoData self, SseSerializer serializer);

  @protected
  void
      sse_encode_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerListenerHandle(
          ListenerHandle self, SseSerializer serializer);

  @protected
  void
      sse_encode_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMetadata(
          Metadata self, SseSerializer serializer);

  @protected
  void
      sse_encode_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerPathBuf(
          PathBuf self, SseSerializer serializer);

  @protected
  void
      sse_encode_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerSource(
          Source self, SseSerializer serializer);

  @protected
  void
      sse_encode_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerTaskConfig(
          TaskConfig self, SseSerializer serializer);

  @protected
  void
      sse_encode_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerTemplateVideoDataInterim(
          TemplateVideoDataInterim self, SseSerializer serializer);

  @protected
  void sse_encode_String(String self, SseSerializer serializer);

  @protected
  void sse_encode_attr(Attr self, SseSerializer serializer);

  @protected
  void sse_encode_bool(bool self, SseSerializer serializer);

  @protected
  void sse_encode_box_autoadd_u_32(int self, SseSerializer serializer);

  @protected
  void sse_encode_box_autoadd_u_64(BigInt self, SseSerializer serializer);

  @protected
  void sse_encode_crawler_template(
      CrawlerTemplate self, SseSerializer serializer);

  @protected
  void sse_encode_f_32(double self, SseSerializer serializer);

  @protected
  void sse_encode_home_video(HomeVideo self, SseSerializer serializer);

  @protected
  void sse_encode_http_config(HttpConfig self, SseSerializer serializer);

  @protected
  void sse_encode_i_32(int self, SseSerializer serializer);

  @protected
  void sse_encode_i_64(PlatformInt64 self, SseSerializer serializer);

  @protected
  void sse_encode_isize(PlatformInt64 self, SseSerializer serializer);

  @protected
  void sse_encode_list_String(List<String> self, SseSerializer serializer);

  @protected
  void sse_encode_list_attr(List<Attr> self, SseSerializer serializer);

  @protected
  void sse_encode_list_crawler_template(
      List<CrawlerTemplate> self, SseSerializer serializer);

  @protected
  void sse_encode_list_home_video(
      List<HomeVideo> self, SseSerializer serializer);

  @protected
  void sse_encode_list_prim_u_32_loose(
      List<int> self, SseSerializer serializer);

  @protected
  void sse_encode_list_prim_u_32_strict(
      Uint32List self, SseSerializer serializer);

  @protected
  void sse_encode_list_prim_u_8_strict(
      Uint8List self, SseSerializer serializer);

  @protected
  void sse_encode_list_record_string_task_operational_data(
      List<(String, TaskOperationalData)> self, SseSerializer serializer);

  @protected
  void sse_encode_list_record_u_32_list_prim_u_32_strict(
      List<(int, Uint32List)> self, SseSerializer serializer);

  @protected
  void sse_encode_list_record_u_32_string(
      List<(int, String)> self, SseSerializer serializer);

  @protected
  void sse_encode_list_record_u_32_u_8(
      List<(int, int)> self, SseSerializer serializer);

  @protected
  void sse_encode_list_task_metadata(
      List<TaskMetadata> self, SseSerializer serializer);

  @protected
  void sse_encode_list_untreated_video(
      List<UntreatedVideo> self, SseSerializer serializer);

  @protected
  void sse_encode_opt_String(String? self, SseSerializer serializer);

  @protected
  void sse_encode_opt_box_autoadd_u_32(int? self, SseSerializer serializer);

  @protected
  void sse_encode_opt_box_autoadd_u_64(BigInt? self, SseSerializer serializer);

  @protected
  void sse_encode_pool_data(PoolData self, SseSerializer serializer);

  @protected
  void sse_encode_pool_status(PoolStatus self, SseSerializer serializer);

  @protected
  void sse_encode_record_opt_box_autoadd_u_32_opt_box_autoadd_u_32(
      (int?, int?) self, SseSerializer serializer);

  @protected
  void sse_encode_record_opt_box_autoadd_u_64_opt_box_autoadd_u_64(
      (BigInt?, BigInt?) self, SseSerializer serializer);

  @protected
  void sse_encode_record_string_task_operational_data(
      (String, TaskOperationalData) self, SseSerializer serializer);

  @protected
  void sse_encode_record_u_32_list_prim_u_32_strict(
      (int, Uint32List) self, SseSerializer serializer);

  @protected
  void sse_encode_record_u_32_string(
      (int, String) self, SseSerializer serializer);

  @protected
  void sse_encode_record_u_32_u_8((int, int) self, SseSerializer serializer);

  @protected
  void sse_encode_task_metadata(TaskMetadata self, SseSerializer serializer);

  @protected
  void sse_encode_task_operational_data(
      TaskOperationalData self, SseSerializer serializer);

  @protected
  void sse_encode_task_status(TaskStatus self, SseSerializer serializer);

  @protected
  void sse_encode_u_16(int self, SseSerializer serializer);

  @protected
  void sse_encode_u_32(int self, SseSerializer serializer);

  @protected
  void sse_encode_u_64(BigInt self, SseSerializer serializer);

  @protected
  void sse_encode_u_8(int self, SseSerializer serializer);

  @protected
  void sse_encode_unit(void self, SseSerializer serializer);

  @protected
  void sse_encode_untreated_video(
      UntreatedVideo self, SseSerializer serializer);

  @protected
  void sse_encode_usize(BigInt self, SseSerializer serializer);
}

// Section: wire_class

class RustLibWire implements BaseWire {
  RustLibWire.fromExternalLibrary(ExternalLibrary lib);

  void rust_arc_increment_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerHomeVideoData(
          int ptr) =>
      wasmModule
          .rust_arc_increment_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerHomeVideoData(
              ptr);

  void rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerHomeVideoData(
          int ptr) =>
      wasmModule
          .rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerHomeVideoData(
              ptr);

  void rust_arc_increment_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerListenerHandle(
          int ptr) =>
      wasmModule
          .rust_arc_increment_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerListenerHandle(
              ptr);

  void rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerListenerHandle(
          int ptr) =>
      wasmModule
          .rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerListenerHandle(
              ptr);

  void rust_arc_increment_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMetadata(
          int ptr) =>
      wasmModule
          .rust_arc_increment_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMetadata(
              ptr);

  void rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMetadata(
          int ptr) =>
      wasmModule
          .rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMetadata(
              ptr);

  void rust_arc_increment_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerPathBuf(
          int ptr) =>
      wasmModule
          .rust_arc_increment_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerPathBuf(
              ptr);

  void rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerPathBuf(
          int ptr) =>
      wasmModule
          .rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerPathBuf(
              ptr);

  void rust_arc_increment_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerSource(
          int ptr) =>
      wasmModule
          .rust_arc_increment_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerSource(
              ptr);

  void rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerSource(
          int ptr) =>
      wasmModule
          .rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerSource(
              ptr);

  void rust_arc_increment_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerTaskConfig(
          int ptr) =>
      wasmModule
          .rust_arc_increment_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerTaskConfig(
              ptr);

  void rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerTaskConfig(
          int ptr) =>
      wasmModule
          .rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerTaskConfig(
              ptr);

  void rust_arc_increment_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerTemplateVideoDataInterim(
          int ptr) =>
      wasmModule
          .rust_arc_increment_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerTemplateVideoDataInterim(
              ptr);

  void rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerTemplateVideoDataInterim(
          int ptr) =>
      wasmModule
          .rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerTemplateVideoDataInterim(
              ptr);
}

@JS('wasm_bindgen')
external RustLibWasmModule get wasmModule;

@JS()
@anonymous
extension type RustLibWasmModule._(JSObject _) implements JSObject {
  external void
      rust_arc_increment_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerHomeVideoData(
          int ptr);

  external void
      rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerHomeVideoData(
          int ptr);

  external void
      rust_arc_increment_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerListenerHandle(
          int ptr);

  external void
      rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerListenerHandle(
          int ptr);

  external void
      rust_arc_increment_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMetadata(
          int ptr);

  external void
      rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMetadata(
          int ptr);

  external void
      rust_arc_increment_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerPathBuf(
          int ptr);

  external void
      rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerPathBuf(
          int ptr);

  external void
      rust_arc_increment_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerSource(
          int ptr);

  external void
      rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerSource(
          int ptr);

  external void
      rust_arc_increment_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerTaskConfig(
          int ptr);

  external void
      rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerTaskConfig(
          int ptr);

  external void
      rust_arc_increment_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerTemplateVideoDataInterim(
          int ptr);

  external void
      rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerTemplateVideoDataInterim(
          int ptr);
}
