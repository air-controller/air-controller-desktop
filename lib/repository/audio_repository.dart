import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../model/audio_item.dart';
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
}
