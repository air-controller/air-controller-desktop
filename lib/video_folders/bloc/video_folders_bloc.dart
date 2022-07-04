import 'dart:io';
import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../model/video_folder_item.dart';
import '../../model/video_item.dart';
import '../../repository/aircontroller_client.dart';
import '../../repository/file_repository.dart';
import '../../repository/video_repository.dart';

part 'video_folders_event.dart';

part 'video_folders_state.dart';

class VideoFoldersBloc extends Bloc<VideoFoldersEvent, VideoFoldersState> {
  final VideoRepository _videoRepository;
  final FileRepository _fileRepository;

  VideoFoldersBloc(
      {required VideoRepository videoRepository,
      required FileRepository fileRepository})
      : _videoRepository = videoRepository,
        _fileRepository = fileRepository,
        super(VideoFoldersState()) {
    on<VideoFoldersSubscriptionRequested>(_onSubscriptionRequested);
    on<VideoFoldersOpenStatusChanged>(_onOpenFolderStatusChanged);
    on<VideoFoldersCheckedChanged>(_onVideoFoldersCheckedChanged);
    on<VideoFoldersKeyStatusChanged>(_onKeyStatusChanged);
    on<VideoFoldersCheckAll>(_onCheckAll);
    on<VideoFoldersClearAll>(_onClearAll);
    on<VideoFoldersVideosCheckedChanged>(_onVideosCheckedChanged);
    on<VideoFoldersMenuStatusChanged>(_onMenuStatusChanged);
    on<VideoFoldersDeleteSubmitted>(_onDeleteFoldersSubmitted);
    on<VideoFoldersCopySubmitted>(_onCopySubmitted);
    on<VideoFoldersCopyStatusChanged>(_onCopyStatusChanged);
    on<VideoFoldersCancelCopy>(_onCancelCopy);
    on<VideoFoldersVideosCopySubmitted>(_onCopyVideosSubmitted);
    on<VideoFoldersDeleteVideosSubmitted>(_onDeleteVideosSubmitted);
    on<VideoFoldersUploadVideos>(_onUploadVideos);
    on<VideoFoldersUploadStatusChanged>(_onUploadStatusChanged);
  }

  void _onSubscriptionRequested(VideoFoldersSubscriptionRequested event,
      Emitter<VideoFoldersState> emit) async {
    emit(state.copyWith(status: VideoFoldersStatus.loading));

    try {
      List<VideoFolderItem> videoFolders =
          await _videoRepository.getAllVideoFolders();
      emit(state.copyWith(
          status: VideoFoldersStatus.success, videoFolders: videoFolders));
    } catch (e) {
      emit(state.copyWith(
          status: VideoFoldersStatus.failure,
          failureReason: (e as BusinessError).message));
    }
  }

  void _onOpenFolderStatusChanged(VideoFoldersOpenStatusChanged event,
      Emitter<VideoFoldersState> emit) async {
    emit(state.copyWith(videoFolderOpenStatus: event.status));

    if (event.status.isOpened) {
      emit(state.copyWith(
          loadVideosInFolderStatus: state.loadVideosInFolderStatus
              .copyWith(status: VideoFoldersStatus.loading)));

      try {
        List<VideoItem> videos =
            await _videoRepository.getVideosInFolder(event.status.current!.id);
        emit(state.copyWith(
            loadVideosInFolderStatus: state.loadVideosInFolderStatus
                .copyWith(status: VideoFoldersStatus.success, videos: videos)));
      } catch (e) {
        emit(state.copyWith(
            loadVideosInFolderStatus: state.loadVideosInFolderStatus.copyWith(
                status: VideoFoldersStatus.failure,
                error: (e as BusinessError).message)));
      }
    } else {
      emit(state.copyWith(
          loadVideosInFolderStatus:
              state.loadVideosInFolderStatus.copyWith(checkedVideos: [])));
    }
  }

  void _onVideoFoldersCheckedChanged(
      VideoFoldersCheckedChanged event, Emitter<VideoFoldersState> emit) {
    List<VideoFolderItem> videoFolders = state.videoFolders;
    List<VideoFolderItem> checkedVideoFolders = [...state.checkedVideoFolders];
    VideoFolderItem folder = event.videoFolder;

    VideoFoldersBoardKeyStatus keyStatus = state.keyStatus;

    if (!checkedVideoFolders.contains(folder)) {
      if (keyStatus == VideoFoldersBoardKeyStatus.ctrlDown) {
        checkedVideoFolders.add(folder);
      } else if (keyStatus == VideoFoldersBoardKeyStatus.shiftDown) {
        if (checkedVideoFolders.length == 0) {
          checkedVideoFolders.add(folder);
        } else if (checkedVideoFolders.length == 1) {
          int index = checkedVideoFolders.indexOf(checkedVideoFolders[0]);

          int current = videoFolders.indexOf(folder);

          if (current > index) {
            checkedVideoFolders = videoFolders.sublist(index, current + 1);
          } else {
            checkedVideoFolders = videoFolders.sublist(index, current + 1);
          }
        } else {
          int maxIndex = 0;
          int minIndex = 0;

          for (int i = 0; i < checkedVideoFolders.length; i++) {
            VideoFolderItem current = checkedVideoFolders[i];
            int index = videoFolders.indexOf(current);
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

          int current = videoFolders.indexOf(folder);

          if (current >= minIndex && current <= maxIndex) {
            checkedVideoFolders = videoFolders.sublist(current, maxIndex + 1);
          } else if (current < minIndex) {
            checkedVideoFolders = videoFolders.sublist(current, maxIndex + 1);
          } else if (current > maxIndex) {
            checkedVideoFolders = videoFolders.sublist(minIndex, current + 1);
          }
        }
      } else {
        checkedVideoFolders.clear();
        checkedVideoFolders.add(folder);
      }
    } else {
      if (keyStatus == VideoFoldersBoardKeyStatus.ctrlDown) {
        checkedVideoFolders.remove(folder);
      } else if (keyStatus == VideoFoldersBoardKeyStatus.shiftDown) {
        checkedVideoFolders.remove(folder);
      }
    }

    emit(state.copyWith(checkedVideoFolders: checkedVideoFolders));
  }

  void _onKeyStatusChanged(
      VideoFoldersKeyStatusChanged event, Emitter<VideoFoldersState> emit) {
    emit(state.copyWith(keyStatus: event.keyStatus));
  }

  void _onCheckAll(
      VideoFoldersCheckAll event, Emitter<VideoFoldersState> emit) {
    bool isFolderOpened = state.videoFolderOpenStatus.isOpened;
    if (isFolderOpened) {
      emit(state.copyWith(
          loadVideosInFolderStatus: state.loadVideosInFolderStatus.copyWith(
              checkedVideos: [...state.loadVideosInFolderStatus.videos])));
    } else {
      emit(state.copyWith(checkedVideoFolders: [...state.videoFolders]));
    }
  }

  void _onClearAll(
      VideoFoldersClearAll event, Emitter<VideoFoldersState> emit) {
    bool isFolderOpened = state.videoFolderOpenStatus.isOpened;
    if (isFolderOpened) {
      emit(state.copyWith(
          loadVideosInFolderStatus:
              state.loadVideosInFolderStatus.copyWith(checkedVideos: [])));
    } else {
      emit(state.copyWith(checkedVideoFolders: []));
    }
  }

  void _onVideosCheckedChanged(
      VideoFoldersVideosCheckedChanged event, Emitter<VideoFoldersState> emit) {
    List<VideoItem> videos = state.loadVideosInFolderStatus.videos;
    List<VideoItem> checkedVideos = [
      ...state.loadVideosInFolderStatus.checkedVideos
    ];
    VideoItem video = event.video;

    VideoFoldersBoardKeyStatus keyStatus = state.keyStatus;

    if (!checkedVideos.contains(video)) {
      if (keyStatus == VideoFoldersBoardKeyStatus.ctrlDown) {
        checkedVideos.add(video);
      } else if (keyStatus == VideoFoldersBoardKeyStatus.shiftDown) {
        if (checkedVideos.length == 0) {
          checkedVideos.add(video);
        } else if (checkedVideos.length == 1) {
          int index = checkedVideos.indexOf(checkedVideos[0]);

          int current = videos.indexOf(video);

          if (current > index) {
            checkedVideos = videos.sublist(index, current + 1);
          } else {
            checkedVideos = videos.sublist(index, current + 1);
          }
        } else {
          int maxIndex = 0;
          int minIndex = 0;

          for (int i = 0; i < checkedVideos.length; i++) {
            VideoItem current = checkedVideos[i];
            int index = videos.indexOf(current);
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

          int current = videos.indexOf(video);

          if (current >= minIndex && current <= maxIndex) {
            checkedVideos = videos.sublist(current, maxIndex + 1);
          } else if (current < minIndex) {
            checkedVideos = videos.sublist(current, maxIndex + 1);
          } else if (current > maxIndex) {
            checkedVideos = videos.sublist(minIndex, current + 1);
          }
        }
      } else {
        checkedVideos.clear();
        checkedVideos.add(video);
      }
    } else {
      if (keyStatus == VideoFoldersBoardKeyStatus.ctrlDown) {
        checkedVideos.remove(video);
      } else if (keyStatus == VideoFoldersBoardKeyStatus.shiftDown) {
        checkedVideos.remove(video);
      }
    }

    emit(state.copyWith(
        loadVideosInFolderStatus: state.loadVideosInFolderStatus
            .copyWith(checkedVideos: checkedVideos)));
  }

  void _onMenuStatusChanged(
      VideoFoldersMenuStatusChanged event, Emitter<VideoFoldersState> emit) {
    emit(state.copyWith(openMenuStatus: event.status));
  }

  void _onDeleteFoldersSubmitted(VideoFoldersDeleteSubmitted event,
      Emitter<VideoFoldersState> emit) async {
    emit(state.copyWith(deleteStatus: VideoFoldersDeleteStatus.loading));

    try {
      await _fileRepository.deleteFiles(
          event.videoFolders.map((folder) => folder.path).toList());

      List<VideoFolderItem> videoFolders = [...state.videoFolders];
      List<VideoFolderItem> checkedVideoFolders = [
        ...state.checkedVideoFolders
      ];

      videoFolders.removeWhere((folder) => event.videoFolders.contains(folder));
      checkedVideoFolders
          .removeWhere((folder) => event.videoFolders.contains(folder));

      emit(state.copyWith(
          deleteStatus: VideoFoldersDeleteStatus.success,
          videoFolders: videoFolders,
          checkedVideoFolders: checkedVideoFolders));
    } catch (e) {
      emit(state.copyWith(
          deleteStatus: VideoFoldersDeleteStatus.failure,
          failureReason: (e as BusinessError).message));
    }
  }

  void _onCopySubmitted(
      VideoFoldersCopySubmitted event, Emitter<VideoFoldersState> emit) {
    emit(state.copyWith(
        copyStatus: VideoFoldersCopyStatusUnit(
            fileType: VideoFoldersFileType.folder,
            status: VideoFoldersCopyStatus.start)));

    String? fileName = null;

    if (event.folders.length == 1) {
      fileName = "${event.folders.single.name}.zip";
    }

    _fileRepository.copyFilesTo(
        fileName: fileName,
        paths: event.folders.map((folder) => folder.path).toList(),
        dir: event.dir,
        onProgress: (fileName, current, total) {
          add(VideoFoldersCopyStatusChanged(VideoFoldersCopyStatusUnit(
              fileType: VideoFoldersFileType.folder,
              status: VideoFoldersCopyStatus.copying,
              fileName: fileName,
              current: current,
              total: total)));
        },
        onDone: (fileName) {
          add(VideoFoldersCopyStatusChanged(VideoFoldersCopyStatusUnit(
              fileType: VideoFoldersFileType.folder,
              status: VideoFoldersCopyStatus.success,
              fileName: fileName)));
        },
        onError: (String error) {
          add(VideoFoldersCopyStatusChanged(VideoFoldersCopyStatusUnit(
              fileType: VideoFoldersFileType.folder,
              status: VideoFoldersCopyStatus.failure,
              error: error)));
        });
  }

  void _onCopyStatusChanged(
      VideoFoldersCopyStatusChanged event, Emitter<VideoFoldersState> emit) {
    emit(state.copyWith(copyStatus: event.status));
  }

  void _onCancelCopy(
      VideoFoldersCancelCopy event, Emitter<VideoFoldersState> emit) {
    _fileRepository.cancelCopy();
  }

  void _onCopyVideosSubmitted(
      VideoFoldersVideosCopySubmitted event, Emitter<VideoFoldersState> emit) {
    emit(state.copyWith(
        copyStatus: VideoFoldersCopyStatusUnit(
            fileType: VideoFoldersFileType.folder,
            status: VideoFoldersCopyStatus.start)));

    _fileRepository.copyFilesTo(
        paths: event.videos.map((folder) => folder.path).toList(),
        dir: event.dir,
        onProgress: (fileName, current, total) {
          add(VideoFoldersCopyStatusChanged(VideoFoldersCopyStatusUnit(
              fileType: VideoFoldersFileType.video,
              status: VideoFoldersCopyStatus.copying,
              fileName: fileName,
              current: current,
              total: total)));
        },
        onDone: (fileName) {
          add(VideoFoldersCopyStatusChanged(VideoFoldersCopyStatusUnit(
              fileType: VideoFoldersFileType.video,
              status: VideoFoldersCopyStatus.success,
              fileName: fileName)));
        },
        onError: (String error) {
          add(VideoFoldersCopyStatusChanged(VideoFoldersCopyStatusUnit(
              fileType: VideoFoldersFileType.video,
              status: VideoFoldersCopyStatus.failure,
              error: error)));
        });
  }

  void _onDeleteVideosSubmitted(VideoFoldersDeleteVideosSubmitted event,
      Emitter<VideoFoldersState> emit) async {
    emit(state.copyWith(deleteStatus: VideoFoldersDeleteStatus.loading));

    try {
      await _fileRepository
          .deleteFiles(event.videos.map((folder) => folder.path).toList());

      List<VideoItem> videos = [...state.loadVideosInFolderStatus.videos];
      List<VideoItem> checkedVideos = [
        ...state.loadVideosInFolderStatus.checkedVideos
      ];

      videos.removeWhere((video) => event.videos.contains(video));
      checkedVideos.removeWhere((video) => event.videos.contains(video));

      emit(state.copyWith(
          deleteStatus: VideoFoldersDeleteStatus.success,
          loadVideosInFolderStatus: state.loadVideosInFolderStatus
              .copyWith(videos: videos, checkedVideos: checkedVideos)));
    } catch (e) {
      emit(state.copyWith(
          deleteStatus: VideoFoldersDeleteStatus.failure,
          failureReason: (e as BusinessError).message));
    }
  }

  void _onUploadVideos(
      VideoFoldersUploadVideos event, Emitter<VideoFoldersState> emit) {
    emit(state.copyWith(
        uploadStatus: VideoFoldersUploadStatusUnit(
            status: VideoFoldersUploadStatus.start)));

    _videoRepository.uploadVideos(
        videos: event.videos,
        folder: event.folder?.path,
        onError: (msg) {
          add(VideoFoldersUploadStatusChanged(
              status: VideoFoldersUploadStatusUnit(
                  status: VideoFoldersUploadStatus.failure,
                  failureReason: msg)));
        },
        onSuccess: () {
          add(VideoFoldersUploadStatusChanged(
              status: VideoFoldersUploadStatusUnit(
                  status: VideoFoldersUploadStatus.success),
              folder: event.folder,
              addedVideoCount: event.videos.length));
        },
        onUploading: (sent, total) {
          add(VideoFoldersUploadStatusChanged(
              status: VideoFoldersUploadStatusUnit(
                  status: VideoFoldersUploadStatus.uploading,
                  current: sent,
                  total: total)));
        });
  }

  void _onUploadStatusChanged(VideoFoldersUploadStatusChanged event,
      Emitter<VideoFoldersState> emit) async {
    emit(state.copyWith(uploadStatus: event.status));

    if (event.status.status == VideoFoldersUploadStatus.success) {
      final isOpened = state.videoFolderOpenStatus.isOpened;
      if (isOpened) {
        final currentFolder = state.videoFolderOpenStatus.current;
        if (currentFolder != null) {
          final videos =
              await _videoRepository.getVideosInFolder(currentFolder.id);
          emit(state.copyWith(
              loadVideosInFolderStatus:
                  state.loadVideosInFolderStatus.copyWith(videos: videos)));
        }
      } else {
        final videoFolders = await _videoRepository.getAllVideoFolders();
        emit(state.copyWith(videoFolders: videoFolders));
      }
    }
  }
}
