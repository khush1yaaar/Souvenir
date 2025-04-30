import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:ui' as ui;

class DrawingBoardScreen extends StatelessWidget {
  const DrawingBoardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const DrawingBoard();
  }
}

class DrawingBoard extends StatefulWidget {
  const DrawingBoard({Key? key}) : super(key: key);

  @override
  DrawingBoardState createState() => DrawingBoardState();
}

class DrawingBoardState extends State<DrawingBoard> {
  Color selectedColor = Colors.black;
  double strokeWidth = 3.0;
  double eraserWidth = 10.0; // Separate stroke width for eraser
  bool isEraser = false;
  bool showPenOptions = false;
  bool showStrokeSlider = false;
  List<DrawingPoint?> drawingPoints = [];

  // Color palettes
  final List<List<Color>> colorPalettes = [
    [
      Colors.black,
      Colors.grey.shade800,
      Colors.grey.shade600,
      Colors.grey.shade400,
      Colors.grey.shade200,
      Colors.white,
      Colors.brown.shade800,
      Colors.brown.shade600,
    ],
    [
      Colors.red.shade900,
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.indigo,
      Colors.purple,
    ],
    [
      Colors.pink.shade300,
      Colors.red.shade300,
      Colors.orange.shade300,
      Colors.yellow.shade300,
      Colors.green.shade300,
      Colors.blue.shade300,
      Colors.indigo.shade300,
      Colors.purple.shade300,
    ],
  ];

  int currentPaletteIndex = 0;

  // Pen options
  final List<Map<String, dynamic>> penOptions = [
    {'name': 'Pen', 'icon': Icons.edit, 'strokeCap': StrokeCap.round},
    {'name': 'Marker', 'icon': Icons.brush, 'strokeCap': StrokeCap.square},
    {'name': 'Pencil', 'icon': Icons.create, 'strokeCap': StrokeCap.round},
  ];

  int selectedPenIndex = 0;

  Future<ui.Image?> _getImage() async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final painter = _DrawingPainter(drawingPoints);
    painter.paint(canvas, MediaQuery.of(context).size);
    final picture = pictureRecorder.endRecording();
    return await picture.toImage(
      MediaQuery.of(context).size.width.toInt(),
      MediaQuery.of(context).size.height.toInt(),
    );
  }

  void _saveDrawing() async {
    final image = await _getImage();
    final byteData = await image?.toByteData(format: ui.ImageByteFormat.png);
    final imageBytes = byteData?.buffer.asUint8List();

    if (imageBytes != null) {
      Navigator.pop(context, imageBytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Drawing Board"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.grey[100],
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // Pen options dropdown (shown above toolbar when open)
          if (showPenOptions)
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(penOptions.length, (index) {
                      return InkWell(
                        onTap: () {
                          setState(() {
                            selectedPenIndex = index;
                            showPenOptions = false;
                            showStrokeSlider = true;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: selectedPenIndex == index
                                ? Colors.blue.shade50
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(penOptions[index]['icon']),
                              const SizedBox(height: 4),
                              Text(
                                penOptions[index]['name'],
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  // Stroke width slider for pen
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Text('Width:', style: TextStyle(fontSize: 12)),
                        Expanded(
                          child: Slider(
                            min: 1,
                            max: 20,
                            value: strokeWidth,
                            onChanged: (val) => setState(() => strokeWidth = val),
                          ),
                        ),
                        Text(
                          '${strokeWidth.toStringAsFixed(1)}px',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          // Toolbar with pen options and color palette
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[100],
            child: Column(
              children: [
                // Pen and color selection row
                Row(
                  children: [
                    // Pen selection (1/3 width)
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            showPenOptions = !showPenOptions;
                            if (!showPenOptions) {
                              showStrokeSlider = false;
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                penOptions[selectedPenIndex]['icon'],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                penOptions[selectedPenIndex]['name'],
                                style: const TextStyle(fontSize: 14),
                              ),
                              const Icon(Icons.arrow_drop_up_rounded, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Color palette (2/3 width)
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: 80, // Increased height for 2 rows
                        child: PageView.builder(
                          itemCount: colorPalettes.length,
                          onPageChanged: (index) {
                            setState(() {
                              currentPaletteIndex = index;
                            });
                          },
                          itemBuilder: (context, paletteIndex) {
                            return Column(
                              children: [
                                // First row of 4 colors
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: colorPalettes[paletteIndex]
                                      .sublist(0, 4)
                                      .map((color) {
                                    bool isSelected =
                                        selectedColor == color && !isEraser;
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedColor = color;
                                          isEraser = false;
                                        });
                                      },
                                      child: Container(
                                        width: isSelected ? 30 : 25,
                                        height: isSelected ? 30 : 25,
                                        decoration: BoxDecoration(
                                          color: color,
                                          shape: BoxShape.circle,
                                          border: isSelected
                                              ? Border.all(
                                                  color: Colors.black,
                                                  width: 2,
                                                )
                                              : Border.all(
                                                  color: Colors.grey.shade300,
                                                ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 8),
                                // Second row of 4 colors
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: colorPalettes[paletteIndex]
                                      .sublist(4)
                                      .map((color) {
                                    bool isSelected =
                                        selectedColor == color && !isEraser;
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedColor = color;
                                          isEraser = false;
                                        });
                                      },
                                      child: Container(
                                        width: isSelected ? 30 : 25,
                                        height: isSelected ? 30 : 25,
                                        decoration: BoxDecoration(
                                          color: color,
                                          shape: BoxShape.circle,
                                          border: isSelected
                                              ? Border.all(
                                                  color: Colors.black,
                                                  width: 2,
                                                )
                                              : Border.all(
                                                  color: Colors.grey.shade300,
                                                ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                // Eraser width slider (only shown when eraser is active)
                if (isEraser && showStrokeSlider)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Text('Eraser Size:', style: TextStyle(fontSize: 12)),
                        Expanded(
                          child: Slider(
                            min: 5,
                            max: 40,
                            value: eraserWidth,
                            onChanged: (val) => setState(() => eraserWidth = val),
                          ),
                        ),
                        Text(
                          '${eraserWidth.toStringAsFixed(1)}px',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          // Drawing area
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: GestureDetector(
                onPanStart: (details) {
                  setState(() {
                    drawingPoints.add(
                      DrawingPoint(
                        details.localPosition,
                        Paint()
                          ..color = isEraser ? Colors.white : selectedColor
                          ..isAntiAlias = true
                          ..strokeWidth = isEraser ? eraserWidth : strokeWidth
                          ..strokeCap = penOptions[selectedPenIndex]['strokeCap'],
                      ),
                    );
                  });
                },
                onPanUpdate: (details) {
                  setState(() {
                    drawingPoints.add(
                      DrawingPoint(
                        details.localPosition,
                        Paint()
                          ..color = isEraser ? Colors.white : selectedColor
                          ..isAntiAlias = true
                          ..strokeWidth = isEraser ? eraserWidth : strokeWidth
                          ..strokeCap = penOptions[selectedPenIndex]['strokeCap'],
                      ),
                    );
                  });
                },
                onPanEnd: (details) {
                  setState(() {
                    drawingPoints.add(null);
                  });
                },
                child: CustomPaint(
                  painter: _DrawingPainter(drawingPoints),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          // Bottom bar with eraser and other tools
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.grey[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  label: const Text("Clear Board"),
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() => drawingPoints = []);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      isEraser = !isEraser;
                      showStrokeSlider = isEraser;
                    });
                  },
                  icon: Icon(
                    isEraser ? Icons.brush : FontAwesomeIcons.eraser,
                    size: 16,
                  ),
                  label: Text(isEraser ? 'Drawing' : 'Eraser'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: isEraser ? Colors.black : Colors.white,
                    backgroundColor: isEraser ? Colors.white : Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _saveDrawing,
                  icon: const Icon(Icons.done),
                  label: const Text("Done"),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawingPainter extends CustomPainter {
  final List<DrawingPoint?> drawingPoints;

  _DrawingPainter(this.drawingPoints);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < drawingPoints.length - 1; i++) {
      if (drawingPoints[i] != null && drawingPoints[i + 1] != null) {
        canvas.drawLine(
          drawingPoints[i]!.offset,
          drawingPoints[i + 1]!.offset,
          drawingPoints[i]!.paint,
        );
      } else if (drawingPoints[i] != null && drawingPoints[i + 1] == null) {
        canvas.drawPoints(PointMode.points, [
          drawingPoints[i]!.offset,
        ], drawingPoints[i]!.paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class DrawingPoint {
  final Offset offset;
  final Paint paint;

  DrawingPoint(this.offset, this.paint);
}