import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../model/audio_item.dart';
import '../model/response_entity.dart';
import 'aircontroller_client.dart';

class AudioRepository {
  final AirControllerClient client;

  AudioRepository({required AirControllerClient client}) : this.client = client;

  Future<List<AudioItem>> getAllAudios() => client.getAllAudios();

  CancelToken uploadAudios(
          {required List<File> audios,
          Function()? onSuccess,
          Function(int, int)? onUploading,
          Function(String? error)? onError,
          VoidCallback? onCancel}) =>
      client.uploadAudios(
          audios: audios,
          onSuccess: onSuccess,
          onUploading: onUploading,
          onError: onError,
          onCancel: onCancel);

  Future<Uint8List> readAsBytes(List<AudioItem> audios) async {
    final ids = audios.map((audio) => audio.id).toList();
    String idsStr = Uri.encodeComponent(jsonEncode(ids));

    String api = "/audio/download?ids=$idsStr";
    return await this.client.readAsBytes(api);
  }

  Future<ResponseEntity> deleteAudios(List<String> ids) async {
    return await this.client.deleteAudios(ids);
  }

  Future<void> copyAudiosTo(
      {required List<AudioItem> audios,
      required String dir,
      Function(String fileName)? onDone,
      Function(String fileName, int current, int total)? onProgress,
      Function(String error)? onError,
      String? fileName = null}) async {
    return this.client.copyAudiosTo(
        audios: audios,
        dir: dir,
        onDone: onDone,
        onProgress: onProgress,
        onError: onError,
        fileName: fileName);
  }
}
