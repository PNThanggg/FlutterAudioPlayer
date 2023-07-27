import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'tape_button.dart';
import 'tape_painter.dart';

enum TapeStatus { initial, playing, pausing, stopping, choosing }

class Tape extends StatefulWidget {
  const Tape({super.key});

  @override
  _TapeState createState() => _TapeState();
}

class _TapeState extends State<Tape> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late AudioPlayer _audioPlayer;

  TapeStatus _status = TapeStatus.initial;
  String? _url;
  String? _title;
  double _currentPosition = 0.0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    Tween<double> tween = Tween<double>(begin: 0.0, end: 1.0);

    tween.animate(_controller);
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 300,
          height: 200,
          child: AnimatedBuilder(
            builder: (BuildContext context, Widget? child) {
              return CustomPaint(
                painter: TapePainter(
                  rotationValue: _controller.value,
                  title: _title ?? '',
                  progress: _currentPosition,
                ),
              );
            },
            animation: _controller,
          ),
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TapeButton(
              icon: Icons.play_arrow,
              onTap: play,
              isTapped: _status == TapeStatus.playing,
            ),
            const SizedBox(width: 8),
            TapeButton(
              icon: Icons.pause,
              onTap: pause,
              isTapped: _status == TapeStatus.pausing,
            ),
            const SizedBox(width: 8),
            TapeButton(
              icon: Icons.stop,
              onTap: stop,
              isTapped: _status == TapeStatus.stopping,
            ),
            const SizedBox(width: 8),
            TapeButton(
              icon: Icons.eject,
              onTap: choose,
              isTapped: _status == TapeStatus.choosing,
            ),
          ],
        )
      ],
    );
  }

  void stop() {
    setState(() {
      _status = TapeStatus.stopping;
      _currentPosition = 0.0;
    });
    _controller.stop();
    _audioPlayer.stop();
  }

  void pause() {
    setState(() {
      _status = TapeStatus.pausing;
    });
    _controller.stop();
    _audioPlayer.pause();
  }

  void play() async {
    if (_url == null) {
      return;
    }

    setState(() {
      _status = TapeStatus.playing;
    });

    _controller.repeat();
    _audioPlayer.play(UrlSource(_url!));
  }

  choose() async {
    stop();

    setState(() {
      _status = TapeStatus.choosing;
    });

    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio);

    if (result == null) {
      return;
    }

    PlatformFile file = result.files.first;

    _url = file.path;
    _audioPlayer.setSourceUrl(_url!);

    // final FlutterFFprobe _flutterFFprobe = FlutterFFprobe();
    // MediaInformation mediaInfo =
    //     await _flutterFFprobe.getMediaInformation(_url!);

    // Map<dynamic, dynamic> properties = mediaInfo.getMediaProperties()!;

    // int? duration = properties['duration'];

    file.path.toString().split('/').last;

    String? title = file.path.toString().split('/').last;
    String? artist;

    // if (properties['metadata'] != null) {
    //   title = properties['metadata']['title'];
    //   artist = properties['metadata']['artist'];
    // }

    String? completeTitle = artist == null ? title : "$artist - $title";

    _audioPlayer.onPlayerComplete.listen((event) {
      stop();
    });

    // _audioPlayer.onDurationChanged.listen((event) {
    //   _currentPosition = event.inMilliseconds / duration!;
    // });

    setState(() {
      _title = completeTitle;
      _status = TapeStatus.initial;
    });
  }
}
