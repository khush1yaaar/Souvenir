import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';

class JournalEntryScreen extends StatefulWidget {
  const JournalEntryScreen({super.key});

  @override
  State<JournalEntryScreen> createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends State<JournalEntryScreen> {
  final List<JournalContent> _contents = [];
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _textController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _addText() {
    if (_textController.text.trim().isEmpty) return;

    setState(() {
      _contents.add(
        JournalContent(type: ContentType.text, data: _textController.text),
      );
      _textController.clear();
    });
  }

  Future<void> _addImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _contents.add(
          JournalContent(type: ContentType.image, data: image.path),
        );
      });
    }
  }

  Future<void> _addVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() {
        _contents.add(
          JournalContent(type: ContentType.video, data: video.path),
        );
      });
    }
  }

  Future<void> _addAudio() async {
    final XFile? audio = await _picker.pickMedia();
    if (audio != null) {
      setState(() {
        _contents.add(
          JournalContent(type: ContentType.audio, data: audio.path),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Journal Entry'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              // Save the journal entry
              Navigator.pop(context, _contents);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _contents.length,
              itemBuilder: (context, index) {
                final content = _contents[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildContentWidget(content),
                );
              },
            ),
          ),
          _buildInputSection(),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'image',
            mini: true,
            onPressed: _addImage,
            child: const Icon(Icons.image),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'video',
            mini: true,
            onPressed: _addVideo,
            child: const Icon(Icons.videocam),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'audio',
            mini: true,
            onPressed: _addAudio,
            child: const Icon(Icons.audiotrack),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: 'Write your thoughts...',
                border: InputBorder.none,
              ),
              maxLines: 3,
              minLines: 1,
              onSubmitted: (_) => _addText(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 50.0),
            child: IconButton(icon: const Icon(Icons.send), onPressed: _addText),
          ),
        ],
      ),
    );
  }

  Widget _buildContentWidget(JournalContent content) {
    switch (content.type) {
      case ContentType.text:
        return Text(content.data, style: const TextStyle(fontSize: 16));
      case ContentType.image:
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(content.data),
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          ),
        );
      case ContentType.video:
        return _VideoPlayerWidget(filePath: content.data);
      case ContentType.audio:
        return _AudioPlayerWidget(
          filePath: content.data,
          audioPlayer: _audioPlayer,
        );
    }
  }
}

enum ContentType { text, image, video, audio }

class JournalContent {
  final ContentType type;
  final String data;

  JournalContent({required this.type, required this.data});
}

class _VideoPlayerWidget extends StatefulWidget {
  final String filePath;

  const _VideoPlayerWidget({required this.filePath});

  @override
  State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.filePath))
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        ),
        IconButton(
          icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
          onPressed: () {
            setState(() {
              _isPlaying = !_isPlaying;
              _isPlaying ? _controller.play() : _controller.pause();
            });
          },
        ),
      ],
    );
  }
}

class _AudioPlayerWidget extends StatefulWidget {
  final String filePath;
  final AudioPlayer audioPlayer;

  const _AudioPlayerWidget({required this.filePath, required this.audioPlayer});

  @override
  State<_AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<_AudioPlayerWidget> {
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _setupAudioPlayer();
  }

  void _setupAudioPlayer() async {
    widget.audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });

    widget.audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _duration = duration;
      });
    });

    widget.audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        _position = position;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Slider(
          min: 0,
          max: _duration.inSeconds.toDouble(),
          value: _position.inSeconds.toDouble(),
          onChanged: (value) async {
            await widget.audioPlayer.seek(Duration(seconds: value.toInt()));
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatDuration(_position)),
              Text(_formatDuration(_duration)),
            ],
          ),
        ),
        IconButton(
          icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
          onPressed: () async {
            if (_isPlaying) {
              await widget.audioPlayer.pause();
            } else {
              await widget.audioPlayer.play(UrlSource(widget.filePath));
            }
          },
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
