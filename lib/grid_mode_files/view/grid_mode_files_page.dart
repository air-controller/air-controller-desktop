import 'package:air_controller/ext/global_key_x.dart';
import 'package:air_controller/ext/pointer_down_event_x.dart';
import 'package:air_controller/home/bloc/home_bloc.dart';
import 'package:air_controller/l10n/l10n.dart';
import 'package:air_controller/model/display_type.dart';
import 'package:air_controller/util/sound_effect.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../constant_pool.dart';
import '../../file_home/bloc/file_home_bloc.dart';
import '../../model/file_node.dart';
import '../../network/device_connection_manager.dart';
import '../../util/file_util.dart';
import '../../util/system_app_launcher.dart';
import '../../widget/simple_gesture_detector.dart';

class GridModeFilesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<FileHomeBloc>(
      create: (context) => context.read<FileHomeBloc>(),
      child: GridModeFilesView(),
    );
  }
}

class GridModeFilesView extends StatelessWidget {
  final _divider_line_color = Color(0xffe0e0e0);
  final _globalKeys = Map<FileNode, GlobalKey>();

  @override
  Widget build(BuildContext context) {
    List<FileNode> files =
        context.select((FileHomeBloc bloc) => bloc.state.files);
    List<FileNode> checkedFiles =
        context.select((FileHomeBloc bloc) => bloc.state.checkedFiles);
    List<FileNode> dirStack =
        context.select((FileHomeBloc bloc) => bloc.state.dirStack);
    FileNode? currentRenamingFile =
        context.select((FileHomeBloc bloc) => bloc.state.currentRenamingFile);
    bool isRenamingMode =
        context.select((FileHomeBloc bloc) => bloc.state.isRenamingMode);
    bool isOnlyDownloadDir =
        context.select((FileHomeBloc bloc) => bloc.isOnlyDownloadDir);
    bool isDraggingToRoot =
        context.select((FileHomeBloc bloc) => bloc.state.isDraggingToRoot);
    FileNode? currentDraggingTarget =
        context.select((FileHomeBloc bloc) => bloc.state.currentDraggingTarget);

    Widget content = Column(children: [
      Container(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Container(
                  child: GestureDetector(
                    child: Text(
                        isOnlyDownloadDir
                            ? context.l10n.downloads
                            : context.l10n.phoneStorage,
                        style: TextStyle(
                            color: Color(0xff5b5c61), fontSize: 12.0)),
                    onTap: () {
                      context.read<FileHomeBloc>().add(FileHomeOpenDir(null));
                    },
                  ),
                  margin: EdgeInsets.only(right: 10),
                ),
                ...List.generate(dirStack.length, (index) {
                  FileNode fileNode = dirStack[index];

                  return GestureDetector(
                    child: Row(
                      children: [
                        Image.asset("assets/icons/ic_right_arrow.png",
                            height: 20),
                        Container(
                          child: Text(fileNode.data.name,
                              style: TextStyle(
                                  color: Color(0xff5b5c61), fontSize: 12.0)),
                          padding: EdgeInsets.only(right: 5),
                        ),
                      ],
                    ),
                    onTap: () {
                      context
                          .read<FileHomeBloc>()
                          .add(FileHomeOpenDir(fileNode));
                    },
                  );
                })
              ],
            ),
          ),
          color: Color(0xfffaf9fa),
          padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
          height: 30),
      Divider(color: _divider_line_color, height: 1.0, thickness: 1.0),
      Expanded(
          child: Container(
              child: GridView.builder(
                itemBuilder: (BuildContext context, int index) {
                  FileNode fileNode = files[index];
                  final globalKey = GlobalKey(debugLabel: "GridItem: $index");
                  _globalKeys[fileNode] = globalKey;

                  return _FileGridItem(
                      key: globalKey,
                      isShowing: _isShowing(context),
                      file: fileNode,
                      isChecked: checkedFiles.contains(fileNode),
                      currentRenamingFile: currentRenamingFile,
                      isRenamingMode: isRenamingMode,
                      isDragEntered: !isDraggingToRoot &&
                          currentDraggingTarget == fileNode,
                      onTap: (file) {
                        context
                            .read<FileHomeBloc>()
                            .add(FileHomeCheckedChanged(file));

                        FileNode? currentRenamingFile = context
                            .read<FileHomeBloc>()
                            .state
                            .currentRenamingFile;

                        if (file != currentRenamingFile) {
                          context
                              .read<FileHomeBloc>()
                              .add(FileHomeRenameExit());
                        }
                      },
                      onDoubleTap: (file) {
                        if (file.data.isDir) {
                          context
                              .read<FileHomeBloc>()
                              .add(FileHomeOpenDir(file));
                        } else {
                          SystemAppLauncher.openFile(file.data);
                        }
                      },
                      onMouseRightTap: (position, file) {
                        List<FileNode> checkedFiles =
                            context.read<FileHomeBloc>().state.checkedFiles;
                        if (!checkedFiles.contains(file)) {
                          context
                              .read<FileHomeBloc>()
                              .add(FileHomeCheckedChanged(file));
                        }

                        context.read<FileHomeBloc>().add(
                            FileHomeMenuStatusChanged(FileHomeMenuStatus(
                                isOpened: true,
                                position: position,
                                current: file)));
                      },
                      onNewNameChanged: (value) {
                        context
                            .read<FileHomeBloc>()
                            .add(FileHomeNewNameChanged(value ?? ""));
                      });
                },
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.0,
                    mainAxisSpacing: 10),
                padding: EdgeInsets.all(10.0),
                itemCount: files.length,
                primary: false,
              ),
              color: Colors.white)),
    ]);

    final _rootFocusNode = FocusNode();

    _rootFocusNode.canRequestFocus = true;
    _rootFocusNode.requestFocus();

    return Scaffold(
      body: GestureDetector(
        child: DropTarget(
            onDragEntered: (details) {
              if (!_isShowing(context)) return;

              _updateDraggingStatus(context, details);
            },
            onDragDone: (details) {
              if (!_isShowing(context)) return;

              final currentDraggingTarget =
                  context.read<FileHomeBloc>().state.currentDraggingTarget;
              final isDraggingToRoot =
                  context.read<FileHomeBloc>().state.isDraggingToRoot;

              if (isDraggingToRoot) {

              } else {

              }
            },
            onDragUpdated: (details) {
              if (!_isShowing(context)) return;

              _updateDraggingStatus(context, details);
            },
            onDragExited: (details) {
              if (!_isShowing(context)) return;
            },
            child: content),
        onTap: () {
          context.read<FileHomeBloc>().add(FileHomeClearChecked());
          context.read<FileHomeBloc>().add(FileHomeRenameExit());
        },
      ),
    );
  }

  void _updateDraggingStatus(BuildContext context, DropEventDetails details) {
    final globalPosition = details.globalPosition;

    bool isHitedDir = false;

    final isDraggingToRoot =
        context.read<FileHomeBloc>().state.isDraggingToRoot;
    final currentDraggingTarget =
        context.read<FileHomeBloc>().state.currentDraggingTarget;

    for (int i = 0; i < _globalKeys.length; i++) {
      final fileNode = _globalKeys.keys.elementAt(i);
      final globalKey = _globalKeys.values.elementAt(i);

      final rect = globalKey.globalPaintBounds;

      if (rect?.contains(globalPosition) == true && fileNode.data.isDir) {
        if (isDraggingToRoot ||
            (!isDraggingToRoot && currentDraggingTarget != fileNode)) {
          context
              .read<FileHomeBloc>()
              .add(FileHomeDraggingUpdate(false, fileNode));
          SoundEffect.play(SoundType.bubble);
        }
        isHitedDir = true;
        break;
      }
    }

    if (!isHitedDir && !isDraggingToRoot) {
      context.read<FileHomeBloc>().add(FileHomeDraggingUpdate(true, null));
    }
  }

  bool _isShowing(BuildContext context) {
    final homeTab = context.read<HomeBloc>().state.tab;
    final displayType = context.read<FileHomeBloc>().state.displayType;

    final isOnlyDownloadDir = context.read<FileHomeBloc>().isOnlyDownloadDir;

    if (isOnlyDownloadDir &&
        homeTab == HomeTab.download &&
        displayType == DisplayType.icon) {
      return true;
    }

    if (!isOnlyDownloadDir &&
        homeTab == HomeTab.allFile &&
        displayType == DisplayType.icon) {
      return true;
    }

    return false;
  }
}

class _FileGridItem extends StatefulWidget {
  final bool isShowing;
  final FileNode file;
  final FileNode? currentRenamingFile;
  final bool isRenamingMode;
  final bool isChecked;
  final bool isDragEntered;
  final Function(FileNode)? onTap;
  final Function(FileNode)? onDoubleTap;
  final Function(Offset, FileNode)? onMouseRightTap;
  final Function(String?)? onNewNameChanged;

  const _FileGridItem(
      {Key? key,
      required this.isShowing,
      required this.file,
      this.currentRenamingFile,
      this.isRenamingMode = false,
      this.isChecked = false,
      this.isDragEntered = false,
      this.onTap,
      this.onDoubleTap,
      this.onMouseRightTap,
      this.onNewNameChanged})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _FileGridItemState();
  }
}

class _FileGridItemState extends State<_FileGridItem> {
  // bool _isDragEntered = false;

  @override
  Widget build(BuildContext context) {
    final file = widget.file;
    bool isDir = file.data.isDir;

    String name = file.data.name;
    String extension = "";
    int pointIndex = name.lastIndexOf(".");
    if (pointIndex != -1) {
      extension = name.substring(pointIndex + 1);
    }

    String fileTypeIcon = getFileTypeIcon(isDir, extension.toLowerCase());

    Widget icon = Image.asset(fileTypeIcon, width: 100, height: 100);

    if (FileUtil.isImage(file.data)) {
      String encodedPath =
          Uri.encodeFull("${file.data.folder}/${file.data.name}");
      String imageUrl =
          "${DeviceConnectionManager.instance.rootURL}/stream/image/thumbnail2?path=${encodedPath}&width=400&height=400";
      icon = Container(
        child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            width: 100,
            height: 100,
            memCacheWidth: 400,
            fadeOutDuration: Duration.zero,
            fadeInDuration: Duration.zero,
            errorWidget: (context, url, error) {
              return Image.asset("assets/icons/brokenImage.png",
                  width: 100, height: 100);
            }),
        decoration: BoxDecoration(
            border: new Border.all(color: Color(0xffdedede), width: 1),
            borderRadius: new BorderRadius.all(Radius.circular(2.0))),
        padding: EdgeInsets.all(6),
      );
    }

    if (FileUtil.isVideo(file.data)) {
      String videoThumbnail =
          "${DeviceConnectionManager.instance.rootURL}/stream/video/thumbnail2?path=${file.data.folder}/${file.data.name}&width=400&height=400";
      icon = Stack(
        children: [
          CachedNetworkImage(
            imageUrl: videoThumbnail,
            fit: BoxFit.cover,
            width: 100,
            height: 100,
            memCacheWidth: 400,
            fadeOutDuration: Duration.zero,
            fadeInDuration: Duration.zero,
          ),
          Positioned(
            child: Image.asset("assets/icons/ic_video_indictor.png",
                width: 20, height: 20),
            left: 15,
            bottom: 8,
          )
        ],
      );
    }

    final inputController = TextEditingController();

    inputController.text = file.data.name;

    final focusNode = FocusNode();

    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        inputController.selection = TextSelection(
            baseOffset: 0, extentOffset: inputController.text.length);
      }
    });

    final backgroundFileSelected = Color(0xffe6e6e6);
    final backgroundFileNormal = Colors.white;

    final fileNameTextColorNormal = Color(0xff515151);

    final fileNameTextColorSelected = Colors.white;

    final backgroundFileNameNormal = Colors.white;
    final backgroundFileNameSelected = Color(0xff5d87ed);

    return Listener(
      child: Column(children: [
        SimpleGestureDetector(
            child: Container(
              child: icon,
              decoration: BoxDecoration(
                  color: widget.isChecked || widget.isDragEntered
                      ? backgroundFileSelected
                      : backgroundFileNormal,
                  borderRadius: BorderRadius.all(Radius.circular(4.0))),
              padding: EdgeInsets.all(8),
            ),
            onTap: () {
              widget.onTap?.call(widget.file);
            },
            onDoubleTap: () {
              widget.onDoubleTap?.call(widget.file);
            }),
        SimpleGestureDetector(
          child: Container(
            constraints: BoxConstraints(maxWidth: 150),
            child: Stack(
              children: [
                Visibility(
                  child: Text(
                    file.data.name,
                    style: TextStyle(
                        fontSize: 14,
                        color: (widget.isChecked &&
                                    file != widget.currentRenamingFile) ||
                                widget.isDragEntered
                            ? fileNameTextColorSelected
                            : fileNameTextColorNormal),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  visible: widget.isRenamingMode
                      ? file != widget.currentRenamingFile
                      : true,
                ),
                Visibility(
                  child: Container(
                    child: IntrinsicWidth(
                      child: TextField(
                        focusNode: focusNode,
                        controller: inputController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color(0xffcccbcd),
                                    width: 3,
                                    style: BorderStyle.solid)),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color(0xffcccbcd),
                                    width: 3,
                                    style: BorderStyle.solid),
                                borderRadius: BorderRadius.circular(4)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color(0xffcccbcd),
                                    width: 4,
                                    style: BorderStyle.solid),
                                borderRadius: BorderRadius.circular(4)),
                            contentPadding: EdgeInsets.fromLTRB(8, 3, 8, 3)),
                        cursorColor: Color(0xff333333),
                        style:
                            TextStyle(fontSize: 14, color: Color(0xff333333)),
                        onChanged: (value) {
                          widget.onNewNameChanged?.call(value);
                        },
                      ),
                    ),
                    height: 30,
                  ),
                  visible: file == widget.currentRenamingFile &&
                      widget.isRenamingMode,
                  maintainState: false,
                  maintainSize: false,
                )
              ],
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(3)),
              color: (widget.isChecked && file != widget.currentRenamingFile) ||
                      widget.isDragEntered
                  ? backgroundFileNameSelected
                  : backgroundFileNameNormal,
            ),
            margin: EdgeInsets.only(top: 10),
            padding: EdgeInsets.fromLTRB(5, 3, 5, 3),
          ),
          onTap: () {
            widget.onTap?.call(file);
          },
          onDoubleTap: () {
            widget.onDoubleTap?.call(widget.file);
          },
        )
      ]),
      onPointerDown: (event) {
        if (event.isRightMouseClick()) {
          widget.onMouseRightTap?.call(event.position, widget.file);
        }
      },
    );
  }

  String getFileTypeIcon(bool isDir, String extension) {
    if (isDir) {
      return "assets/icons/ic_large_type_folder.png";
    } else {
      return ConstantPool.fileExtensionIconMap[extension] ??
          ConstantPool.fileExtensionIconMap["other"]!;
    }
  }
}
