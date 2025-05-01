import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:souvenir/controllers/journal_controller.dart';
import 'dart:io';
import 'package:souvenir/models/journal_content_model.dart';
import 'package:souvenir/models/journal_model.dart';
import 'package:souvenir/screens/drawing_board_screen.dart';
import 'package:path_provider/path_provider.dart';

class JournalWritingScreen extends StatefulWidget {
  final String title;
  const JournalWritingScreen({super.key, required this.title});

  @override
  State<JournalWritingScreen> createState() => _JournalWritingScreenState();
}

class _JournalWritingScreenState extends State<JournalWritingScreen> {
  final TextEditingController _currentTextController = TextEditingController();
  final TextEditingController _editingTextController = TextEditingController();
  final JournalController _journalController = Get.find<JournalController>();
  User? user = FirebaseAuth.instance.currentUser;
  final ImagePicker _picker = ImagePicker();
  final FocusNode _focusNode = FocusNode();

  List<JournalContentModel> _contents = [];
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  int? _editingIndex;

  @override
  void initState() {
    super.initState();
    _currentTextController.addListener(_handleCurrentTextChange);
  }

  @override
  void dispose() {
    _currentTextController.removeListener(_handleCurrentTextChange);
    _currentTextController.dispose();
    _editingTextController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleCurrentTextChange() {
    // Update state if needed for current text
  }

  void _saveCurrentText() {
    if (_currentTextController.text.isNotEmpty) {
      setState(() {
        _contents.add(
          JournalContentModel(type: 'text', data: _currentTextController.text),
        );
        _currentTextController.clear();
      });
    }
  }

  void _saveEditedText() {
    if (_editingIndex != null) {
      if (_editingTextController.text.isNotEmpty) {
        setState(() {
          _contents[_editingIndex!] = JournalContentModel(
            type: 'text',
            data: _editingTextController.text,
          );
          _editingIndex = null;
          _editingTextController.clear();
        });
      } else {
        // If editing and text is empty, remove the item
        setState(() {
          _contents.removeAt(_editingIndex!);
          _editingIndex = null;
          _editingTextController.clear();
        });
      }
    }
    _focusNode.requestFocus();
  }

  void _startEditingText(int index) {
    if (_contents[index].type == 'text') {
      setState(() {
        _editingIndex = index;
        _editingTextController.text = _contents[index].data;
      });
    }
  }

  Future<void> _addImage() async {
    _saveCurrentText();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _contents.add(JournalContentModel(type: 'image', data: image.path));
      });
    }
    _focusNode.requestFocus();
  }

  void _addImageToJournal(Uint8List imageBytes) async {
    // Create a temporary file to store the image
    final tempDir = await getTemporaryDirectory();
    final file = File(
      '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(imageBytes);

    setState(() {
      _contents.add(JournalContentModel(type: 'image', data: file.path));
    });
  }

  Future<void> _addVideo() async {
    _saveCurrentText();
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() {
        _contents.add(JournalContentModel(type: 'video', data: video.path));
      });
    }
    _focusNode.requestFocus();
  }

  Future<void> _addAudio() async {
    _saveCurrentText();
    // Implement actual audio picking logic here
    setState(() {
      _contents.add(
        JournalContentModel(type: 'audio', data: 'audio_placeholder'),
      );
    });
    _focusNode.requestFocus();
  }

  Widget _buildContentItem(JournalContentModel content, int index) {
    if (content.type == 'text' && _editingIndex == index) {
      // Show text field in place of the text being edited
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TextField(
          controller: _editingTextController,
          focusNode: _focusNode,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          style: TextStyle(fontSize: 18),
          cursorColor: Theme.of(context).primaryColor,
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            isDense: true,
            suffixIcon: IconButton(
              icon: Icon(Icons.check),
              onPressed: _saveEditedText,
            ),
          ),
          autofocus: true,
          onSubmitted: (_) => _saveEditedText(),
        ),
      );
    }

    // Regular content display
    switch (content.type) {
      case 'image':
        if (content.data is Uint8List) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: InteractiveViewer(
              panEnabled: true, // Enable panning
              minScale: 0.5, // Minimum zoom scale
              maxScale: 3.0, // Maximum zoom scale
              child: Image.memory(
                content.data as Uint8List,
                fit:
                    BoxFit
                        .contain, // Changed from BoxFit.cover to BoxFit.contain
              ),
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 3.0,
              child: Image.file(File(content.data), fit: BoxFit.contain),
            ),
          );
        }
      case 'video':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            children: [
              Icon(Icons.videocam, size: 50, color: Colors.blue),
              Text('Video: ${content.data.split('/').last}'),
            ],
          ),
        );
      case 'audio':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Icon(Icons.audiotrack, size: 30, color: Colors.green),
              SizedBox(width: 10),
              Text('Audio recording'),
            ],
          ),
        );
      case 'text':
        return GestureDetector(
          onTap: () => _startEditingText(index),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(content.data, style: TextStyle(fontSize: 18)),
          ),
        );
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          try {
            // Create the journal model
            final journal = JournalModel(
              id: DateTime.now().millisecondsSinceEpoch.toString(), // or use Uuid().v4()
              title: widget.title,
              createdAt: createdAt,
              updatedAt: updatedAt,
              contents: _contents,
            );

            // Get the current user (you'll need to implement this)
            if (user == null) {
              throw Exception('User not logged in');
            }

            // Save the journal
            await _journalController.addJournal(user!.uid, journal);

            // Show success message
            Get.snackbar('Success', 'Journal saved successfully!');
            Get.back(); // Return to previous screen
          } catch (e) {
            Get.snackbar('Error', 'Failed to save journal: ${e.toString()}');
          }
        },
        label: Text("Save"),
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 30.0, left: 20),
                child:
                    widget.title.isEmpty
                        ? Text(
                          "Title",
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                        : Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Display all content items
                        ..._contents
                            .asMap()
                            .entries
                            .map(
                              (entry) =>
                                  _buildContentItem(entry.value, entry.key),
                            )
                            .toList(),

                        // Always show the current text input field
                        TextField(
                          controller: _currentTextController,
                          focusNode: _focusNode,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          style: TextStyle(fontSize: 18),
                          cursorColor: Theme.of(context).primaryColor,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Start writing your thoughts...',
                          ),
                          onSubmitted: (_) => _saveCurrentText(),
                        ),

                        SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            left: 10,
            right: 10,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: () {
                      _addImage();
                    },
                    icon: Icon(Icons.image_outlined),
                    tooltip: 'Add image',
                  ),
                  IconButton(
                    onPressed: () {
                      _addVideo();
                    },
                    icon: Icon(Icons.videocam_outlined),
                    tooltip: 'Add video',
                  ),
                  IconButton(
                    onPressed: () {
                      _addAudio();
                    },
                    icon: Icon(Icons.audiotrack_outlined),
                    tooltip: 'Add audio',
                  ),

                  IconButton(
                    onPressed: () async {
                      final imageBytes = await Get.to<Uint8List>(
                        () => DrawingBoardScreen(),
                      );
                      if (imageBytes != null) {
                        _addImageToJournal(imageBytes);
                      }
                    },
                    icon: Icon(Icons.draw_outlined),
                    tooltip: 'Add drawing image',
                  ),
                  IconButton(
                    onPressed: () {
                      // Implement undo functionality
                    },
                    icon: Icon(Icons.undo),
                    tooltip: 'Undo',
                  ),
                  IconButton(
                    onPressed: () {
                      // Implement redo functionality
                    },
                    icon: Icon(Icons.redo),
                    tooltip: 'Redo',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
