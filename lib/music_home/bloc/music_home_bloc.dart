import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../model/audio_item.dart';
import '../../repository/aircontroller_client.dart';
import '../../repository/audio_repository.dart';
import '../../repository/file_repository.dart';

part 'music_home_event.dart';
part 'music_home_state.dart';

class MusicHomeBloc extends Bloc<MusicHomeEvent, MusicHomeState> {
  final AudioRepository audioRepository;
  final FileRepository fileRepository;

  MusicHomeBloc({required this.audioRepository, required this.fileRepository})
      : super(MusicHomeState()) {
    on<MusicHomeSubscriptionRequested>(_onSubscriptionRequested);
    on<MusicHomeCheckedChanged>(_onCheckedChanged);
    on<MusicHomeKeyStatusChanged>(_onKeyStatusChanged);
    on<MusicHomeCheckAll>(_onCheckAll);
    on<MusicHomeClearChecked>(_onClearAllChecked);
    on<MusicHomeMenuStatusChanged>(_onMenuStatusChanged);
    on<MusicHomeDeleteSubmitted>(_onDeleteSubmitted);
    on<MusicHomeCopyMusicsSubmitted>(_onCopyMusicsSubmitted);
    on<MusicHomeCopyStatusChanged>(_onCopyMusicsStatusChanged);
    on<MusicHomeCancelCopySubmitted>(_onCancelCopy);
    on<MusicHomeSortInfoChanged>(_onSortInfoChanged);
    on<MusicHomeUploadAudios>(_onUploadAudios);
    on<MusicHomeUploadStatusChanged>(_onUploadStatusChanged);
  }

  void _onSubscriptionRequested(MusicHomeSubscriptionRequested event,
      Emitter<MusicHomeState> emit) async {
    emit(state.copyWith(status: MusicHomeStatus.loading));

    try {
      List<AudioItem> musics = await audioRepository.getAllAudios();
      emit(state.copyWith(status: MusicHomeStatus.success, musics: musics));
    } catch (e) {
      emit(state.copyWith(
          status: MusicHomeStatus.failure,
          failureReason: (e as BusinessError).message));
    }
  }

  void _onCheckedChanged(
      MusicHomeCheckedChanged event, Emitter<MusicHomeState> emit) {
    List<AudioItem> allMusics = [...state.musics];
    List<AudioItem> checkedMusics = [...state.checkedMusics];
    AudioItem music = event.music;

    MusicHomeBoardKeyStatus keyStatus = state.keyStatus;

    if (!checkedMusics.contains(music)) {
      if (keyStatus == MusicHomeBoardKeyStatus.ctrlDown) {
        checkedMusics.add(music);
      } else if (keyStatus == MusicHomeBoardKeyStatus.shiftDown) {
        if (checkedMusics.length == 0) {
          checkedMusics.add(music);
        } else if (checkedMusics.length == 1) {
          int index = allMusics.indexOf(checkedMusics[0]);

          int current = allMusics.indexOf(music);

          if (current > index) {
            checkedMusics = allMusics.sublist(index, current + 1);
          } else {
            checkedMusics = allMusics.sublist(current, index + 1);
          }
        } else {
          int maxIndex = 0;
          int minIndex = 0;

          for (int i = 0; i < checkedMusics.length; i++) {
            AudioItem current = checkedMusics[i];
            int index = allMusics.indexOf(current);
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

          int current = allMusics.indexOf(music);

          if (current >= minIndex && current <= maxIndex) {
            checkedMusics = allMusics.sublist(current, maxIndex + 1);
          } else if (current < minIndex) {
            checkedMusics = allMusics.sublist(current, maxIndex + 1);
          } else if (current > maxIndex) {
            checkedMusics = allMusics.sublist(minIndex, current + 1);
          }
        }
      } else {
        checkedMusics.clear();
        checkedMusics.add(music);
      }
    } else {
      if (keyStatus == MusicHomeBoardKeyStatus.ctrlDown) {
        checkedMusics.remove(music);
      } else if (keyStatus == MusicHomeBoardKeyStatus.shiftDown) {
        checkedMusics.remove(music);
      } else {
        checkedMusics.clear();
        checkedMusics.add(music);
      }
    }

    log("checkedMusics size: ${checkedMusics.length}");

    emit(state.copyWith(checkedMusics: checkedMusics));
  }

  void _onKeyStatusChanged(
      MusicHomeKeyStatusChanged event, Emitter<MusicHomeState> emit) {
    emit(state.copyWith(keyStatus: event.keyStatus));
  }

  void _onCheckAll(MusicHomeCheckAll event, Emitter<MusicHomeState> emit) {
    List<AudioItem> allMusics = state.musics;
    emit(state.copyWith(checkedMusics: allMusics));
  }

  void _onClearAllChecked(
      MusicHomeClearChecked event, Emitter<MusicHomeState> emit) {
    emit(state.copyWith(checkedMusics: []));
  }

  void _onMenuStatusChanged(
      MusicHomeMenuStatusChanged event, Emitter<MusicHomeState> emit) {
    emit(state.copyWith(openMenuStatus: event.status));
  }

  void _onDeleteSubmitted(
      MusicHomeDeleteSubmitted event, Emitter<MusicHomeState> emit) async {
    emit(state.copyWith(
        deleteStatus:
            MusicHomeDeleteStatusUnit(status: MusicHomeDeleteStatus.loading)));

    try {
      await fileRepository
          .deleteFiles(event.musics.map((music) => music.path).toList());

      List<AudioItem> musics = [...state.musics];
      List<AudioItem> checkedMusics = [...state.checkedMusics];

      musics.removeWhere((audio) => event.musics.contains(audio));
      checkedMusics.removeWhere((audio) => event.musics.contains(audio));

      emit(state.copyWith(
          musics: musics,
          checkedMusics: checkedMusics,
          deleteStatus: MusicHomeDeleteStatusUnit(
              status: MusicHomeDeleteStatus.success, musics: event.musics)));
    } catch (e) {
      emit(state.copyWith(
          deleteStatus: MusicHomeDeleteStatusUnit(
              status: MusicHomeDeleteStatus.failure,
              failureReason: (e as BusinessError).message)));
    }
  }

  void _onCopyMusicsSubmitted(
      MusicHomeCopyMusicsSubmitted event, Emitter<MusicHomeState> emit) {
    emit(state.copyWith(
        copyStatus:
            MusicHomeCopyStatusUnit(status: MusicHomeCopyStatus.start)));

    fileRepository.copyFilesTo(
        paths: event.musics.map((music) => music.path).toList(),
        dir: event.dir,
        onProgress: (fileName, current, total) {
          add(MusicHomeCopyStatusChanged(MusicHomeCopyStatusUnit(
              status: MusicHomeCopyStatus.copying,
              fileName: fileName,
              current: current,
              total: total)));
        },
        onDone: (fileName) {
          add(MusicHomeCopyStatusChanged(MusicHomeCopyStatusUnit(
              status: MusicHomeCopyStatus.success, fileName: fileName)));
        },
        onError: (String error) {
          add(MusicHomeCopyStatusChanged(MusicHomeCopyStatusUnit(
              status: MusicHomeCopyStatus.failure, error: error)));
        });
  }

  void _onCopyMusicsStatusChanged(
      MusicHomeCopyStatusChanged event, Emitter<MusicHomeState> emit) {
    emit(state.copyWith(copyStatus: event.status));
  }

  void _onCancelCopy(
      MusicHomeCancelCopySubmitted event, Emitter<MusicHomeState> emit) {
    fileRepository.cancelCopy();
  }

  void _onSortInfoChanged(
      MusicHomeSortInfoChanged event, Emitter<MusicHomeState> emit) {
    if (state.sortColumn == event.sortColumn &&
        state.sortDirection == event.sortDirection) {
      return;
    }

    List<AudioItem> musics = [...state.musics];

    if (event.sortColumn == MusicHomeSortColumn.folder) {
      musics.sort((itemA, itemB) {
        String folderA = itemA.folder;
        String folderB = itemB.folder;

        int lastIndexA = folderA.lastIndexOf("/");

        if (lastIndexA != -1) {
          folderA = folderA.substring(lastIndexA + 1);
        }

        int lastIndexB = folderB.lastIndexOf("/");

        if (lastIndexB != -1) {
          folderB = folderB.substring(lastIndexB + 1);
        }

        if (event.sortDirection == MusicHomeSortDirection.ascending) {
          return folderA.toLowerCase().compareTo(folderB.toLowerCase());
        } else {
          return folderB.toLowerCase().compareTo(folderA.toLowerCase());
        }
      });

      emit(state.copyWith(
          sortColumn: event.sortColumn,
          sortDirection: event.sortDirection,
          musics: musics));
    }

    if (event.sortColumn == MusicHomeSortColumn.name) {
      musics.sort((itemA, itemB) {
        if (event.sortDirection == MusicHomeSortDirection.ascending) {
          return itemA.name.toLowerCase().compareTo(itemB.name.toLowerCase());
        } else {
          return itemB.name.toLowerCase().compareTo(itemA.name.toLowerCase());
        }
      });
      emit(state.copyWith(
          sortColumn: event.sortColumn,
          sortDirection: event.sortDirection,
          musics: musics));
    }

    if (event.sortColumn == MusicHomeSortColumn.duration) {
      musics.sort((itemA, itemB) {
        if (event.sortDirection == MusicHomeSortDirection.ascending) {
          return itemA.duration.compareTo(itemB.duration);
        } else {
          return itemB.duration.compareTo(itemA.duration);
        }
      });
      emit(state.copyWith(
          sortColumn: event.sortColumn,
          sortDirection: event.sortDirection,
          musics: musics));
    }

    if (event.sortColumn == MusicHomeSortColumn.size) {
      musics.sort((itemA, itemB) {
        if (event.sortDirection == MusicHomeSortDirection.ascending) {
          return itemA.size.compareTo(itemB.size);
        } else {
          return itemB.size.compareTo(itemA.size);
        }
      });
      emit(state.copyWith(
          sortColumn: event.sortColumn,
          sortDirection: event.sortDirection,
          musics: musics));
    }

    if (event.sortColumn == MusicHomeSortColumn.modifyTime) {
      musics.sort((itemA, itemB) {
        if (event.sortDirection == MusicHomeSortDirection.ascending) {
          return itemA.modifyDate.compareTo(itemB.modifyDate);
        } else {
          return itemB.modifyDate.compareTo(itemA.modifyDate);
        }
      });
      emit(state.copyWith(
          sortColumn: event.sortColumn,
          sortDirection: event.sortDirection,
          musics: musics));
    }
  }

  void _onUploadAudios(
      MusicHomeUploadAudios event, Emitter<MusicHomeState> emit) {
    emit(state.copyWith(
        uploadStatus:
            MusicHomeUploadStatusUnit(status: MusicHomeUploadStatus.start)));

    audioRepository.uploadAudios(
        audios: event.audios,
        onError: (msg) {
          add(MusicHomeUploadStatusChanged(MusicHomeUploadStatusUnit(
              status: MusicHomeUploadStatus.failure, failureReason: msg)));
        },
        onUploading: (sent, total) {
          add(MusicHomeUploadStatusChanged(MusicHomeUploadStatusUnit(
              status: MusicHomeUploadStatus.uploading,
              current: sent,
              total: total)));
        },
        onSuccess: () {
          add(MusicHomeUploadStatusChanged(MusicHomeUploadStatusUnit(
              status: MusicHomeUploadStatus.success)));
        });
  }

  void _onUploadStatusChanged(
      MusicHomeUploadStatusChanged event, Emitter<MusicHomeState> emit) async {
    emit(state.copyWith(uploadStatus: event.status));

    if (event.status.status == MusicHomeUploadStatus.success) {
      final audios = await audioRepository.getAllAudios();
      emit(state.copyWith(musics: audios));
    }
  }
}
