import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../model/video_item.dart';
import '../../repository/aircontroller_client.dart';
import '../../repository/file_repository.dart';
import '../../repository/video_repository.dart';

part 'all_videos_state.dart';

part 'all_videos_event.dart';

class AllVideosBloc extends Bloc<AllVideosEvent, AllVideosState> {
  final FileRepository _fileRepository;
  final VideoRepository _videoRepository;

  AllVideosBloc(
      {required FileRepository fileRepository, required VideoRepository videoRepository})
      : _fileRepository = fileRepository,
        _videoRepository = videoRepository,
        super(AllVideosState()) {
    on<AllVideosSubscriptionRequested>(_onSubscriptionRequested);
    on<AllVideosCheckedChanged>(_onCheckedChanged);
    on<AllVideosKeyStatusChanged>(_onKeyStatusChanged);
    on<AllVideosClearChecked>(_onClearChecked);
    on<AllVideosCheckAll>(_onCheckAll);
    on<AllVideosOpenMenuStatusChanged>(_onOpenMenuStatusChanged);
    on<AllVideosDeleteSubmitted>(_onDeleteSubmitted);
    on<AllVideosCopySubmitted>(_onCopySubmitted);
    on<AllVideosCopyStatusChanged>(_onCopyStatusChanged);
    on<AllVideosCancelCopy>(_onCancelCopy);
  }

  void _onSubscriptionRequested(
      AllVideosSubscriptionRequested event,
      Emitter<AllVideosState> emit) async {
    emit(state.copyWith(status: AllVideosStatus.loading));

    try {
      List<VideoItem> videos = await _videoRepository.getAllVideos();

      emit(state.copyWith(
        status: AllVideosStatus.success,
        videos: videos
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AllVideosStatus.failure,
        failureReason: (e as BusinessError).message
      ));
    }
  }

  void _onCheckedChanged(
      AllVideosCheckedChanged event,
      Emitter<AllVideosState> emit) {
    List<VideoItem> allVideos = state.videos;
    List<VideoItem> checkedVideos = [...state.checkedVideos];
    VideoItem image = event.video;

    AllVideosBoardKeyStatus keyStatus = state.keyStatus;

    if (!checkedVideos.contains(image)) {
      if (keyStatus == AllVideosBoardKeyStatus.ctrlDown) {
        checkedVideos.add(image);
      } else if (keyStatus == AllVideosBoardKeyStatus.shiftDown) {
        if (checkedVideos.length == 0) {
          checkedVideos.add(image);
        } else if (checkedVideos.length == 1) {
          int index = allVideos.indexOf(checkedVideos[0]);

          int current = allVideos.indexOf(image);

          if (current > index) {
            checkedVideos = allVideos.sublist(index, current + 1);
          } else {
            checkedVideos = allVideos.sublist(current, index + 1);
          }
        } else {
          int maxIndex = 0;
          int minIndex = 0;

          for (int i = 0; i < checkedVideos.length; i++) {
            VideoItem current = checkedVideos[i];
            int index = allVideos.indexOf(current);
            if (index < 0) {
              continue;
            }

            if (index > maxIndex) {
              maxIndex = index;
            }

            if (index < minIndex) {
              minIndex = index;
            }
          }

          int current = allVideos.indexOf(image);

          if (current >= minIndex && current <= maxIndex) {
            checkedVideos = allVideos.sublist(current, maxIndex + 1);
          } else if (current < minIndex) {
            checkedVideos = allVideos.sublist(current, maxIndex + 1);
          } else if (current > maxIndex) {
            checkedVideos = allVideos.sublist(minIndex, current + 1);
          }
        }
      } else {
        checkedVideos.clear();
        checkedVideos.add(image);
      }
    } else {
      if (keyStatus == AllVideosBoardKeyStatus.ctrlDown) {
        checkedVideos.remove(image);
      } else if (keyStatus == AllVideosBoardKeyStatus.shiftDown) {
        checkedVideos.remove(image);
      } else {
        checkedVideos.clear();
        checkedVideos.add(image);
      }
    }

    emit(state.copyWith(checkedVideos: checkedVideos));
  }

  void _onKeyStatusChanged(
      AllVideosKeyStatusChanged event,
      Emitter<AllVideosState> emit) {
    emit(state.copyWith(keyStatus: event.keyStatus));
  }

  void _onClearChecked(
      AllVideosClearChecked event,
      Emitter<AllVideosState> emit) {
    emit(state.copyWith(checkedVideos: []));
  }

  void _onCheckAll(
      AllVideosCheckAll event,
      Emitter<AllVideosState> emit) {
    emit(state.copyWith(checkedVideos: state.videos));
  }

  void _onOpenMenuStatusChanged(
      AllVideosOpenMenuStatusChanged event,
      Emitter<AllVideosState> emit) {
    emit(state.copyWith(openMenuStatus: event.status));
  }

  void _onDeleteSubmitted(
      AllVideosDeleteSubmitted event,
      Emitter<AllVideosState> emit) async {
    emit(state.copyWith(
        deleteStatus: AllVideosDeleteStatusUnit(status: AllVideosDeleteStatus.loading))
    );

    try {
      await _fileRepository.deleteFiles(event.videos.map((video) => video.path).toList());

      List<VideoItem> videos = [...state.videos];
      List<VideoItem> checkedVideos = [...state.checkedVideos];

      videos.removeWhere((video) => event.videos.contains(video));
      checkedVideos.removeWhere((video) => event.videos.contains(video));

      emit(state.copyWith(
        deleteStatus: AllVideosDeleteStatusUnit(
            status: AllVideosDeleteStatus.success,
          videos: event.videos
        ),
        videos: videos,
        checkedVideos: checkedVideos
      ));
    } catch (e) {
      emit(state.copyWith(
          deleteStatus: AllVideosDeleteStatusUnit(
              status: AllVideosDeleteStatus.failure,
            failureReason: (e as BusinessError).message
          )
      ));
    }
  }

  void _onCopySubmitted(
      AllVideosCopySubmitted event,
      Emitter<AllVideosState> emit) async {
    emit(state.copyWith(copyStatus: AllVideosCopyStatusUnit(status: AllVideosCopyStatus.start)));

    _fileRepository.copyFilesTo(
        paths: event.videos.map((video) => video.path).toList(),
        dir: event.dir,
        onProgress: (fileName, current, total) {
          add(AllVideosCopyStatusChanged(AllVideosCopyStatusUnit(
              status: AllVideosCopyStatus.copying,
              fileName: fileName,
              current: current,
              total: total
          )));
        },
        onDone: (fileName) {
          add(AllVideosCopyStatusChanged(AllVideosCopyStatusUnit(
              status: AllVideosCopyStatus.success,
              fileName: fileName
          )));

        },
        onError: (String error) {
          add(AllVideosCopyStatusChanged(AllVideosCopyStatusUnit(
              status: AllVideosCopyStatus.failure,
              error: error
          )));
        }
    );
  }

  void _onCopyStatusChanged(
      AllVideosCopyStatusChanged event,
      Emitter<AllVideosState> emit) {
    emit(state.copyWith(
      copyStatus: event.status
    ));
  }

  void _onCancelCopy(
      AllVideosCancelCopy event,
      Emitter<AllVideosState> emit) {
    _fileRepository.cancelCopy();
  }
}
