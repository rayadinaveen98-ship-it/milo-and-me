import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/brand.dart';
import '../core/controller.dart';
import '../domain/models.dart';
import '../ui/common.dart';

class DrawingScreen extends ConsumerStatefulWidget {
  final String id;
  const DrawingScreen({super.key, required this.id});
  @override
  ConsumerState<DrawingScreen> createState() => _DrawingScreenState();
}

class _DrawingScreenState extends ConsumerState<DrawingScreen>
    with SingleTickerProviderStateMixin {
  final paintRevision = ValueNotifier<int>(0);
  final List<DrawingStroke> strokes = [], undone = [];
  int color = 0xFF344A46, step = 0;
  double width = .014;
  String mode = 'Together';
  bool eraser = false, saving = false, loading = true;
  Future<bool> draftWrites = Future.value(true);
  String? feedback;
  late AnimationController guide;
  @override
  void initState() {
    super.initState();
    guide = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();
    if (widget.id == 'create') mode = 'Create';
    restoreDraft();
  }

  Future<void> restoreDraft() async {
    try {
      final draft = await ref.read(controllerProvider).db.readDraft(widget.id);
      if (draft != null && mounted) {
        strokes.addAll(
          (draft['strokes'] as List).map(
            (s) => DrawingStroke.fromJson(Map<String, dynamic>.from(s)),
          ),
        );
        step = draft['step'] ?? 0;
        mode = draft['mode'] ?? mode;
      }
    } catch (_) {
      feedback =
          'The unfinished picture could not be opened. Saved memories are safe.';
    }
    if (mounted) setState(() => loading = false);
  }

  Future<bool> keepDraft() {
    if (loading || saving) return draftWrites;
    final db = ref.read(controllerProvider).db;
    final payload = jsonDecode(
      jsonEncode({
        'strokes': strokes.map((s) => s.toJson()).toList(),
        'step': step,
        'mode': mode,
      }),
    );
    draftWrites = draftWrites.then((_) async {
      try {
        await db.saveDraft(widget.id, Map<String, dynamic>.from(payload));
        return true;
      } catch (_) {
        if (mounted) {
          setState(
            () => feedback =
                'We couldn’t keep the unfinished picture yet. Please use Save before leaving.',
          );
        }
        return false;
      }
    });
    return draftWrites;
  }

  void edit(VoidCallback action) {
    setState(action);
    keepDraft();
  }

  @override
  void dispose() {
    paintRevision.dispose();
    guide.dispose();
    super.dispose();
  }

  void point(Offset p, Size size, {bool start = false}) {
    if (mode == 'Watch' || saving || loading) return;
    if (start) {
      setState(() {
        undone.clear();
        strokes.add(
          DrawingStroke(color: color, width: width, erase: eraser, points: []),
        );
      });
    }
    if (strokes.isEmpty) return;
    final point = [
      (p.dx / size.width).clamp(0.0, 1.0).toDouble(),
      (p.dy / size.height).clamp(0.0, 1.0).toDouble(),
    ];
    final points = strokes.last.points;
    if (points.isNotEmpty &&
        (point[0] - points.last[0]).abs() + (point[1] - points.last[1]).abs() <
            .001) {
      return;
    }
    points.add(point);
    paintRevision.value++;
  }

  Future<void> leave() async {
    if (!await keepDraft()) return;
    if (mounted) context.go('/home');
  }

  Future<void> save(Json? lesson) async {
    if (strokes.isEmpty || saving) return;
    setState(() {
      saving = true;
      feedback = null;
    });
    try {
      await draftWrites;
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      StrokePainter(strokes: strokes).paint(canvas, const Size(256, 256));
      final picture = recorder.endRecording();
      final image = await picture.toImage(256, 256);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      picture.dispose();
      if (bytes == null) throw StateError('Thumbnail unavailable');
      final memory = Memory(
        id: 'drawing:${DateTime.now().microsecondsSinceEpoch}',
        kind: 'drawing',
        title: lesson?['title'] ?? 'My wonderful picture',
        topic: lesson?['topic'] ?? 'picture',
        at: DateTime.now(),
        payload: {
          'strokes': strokes.map((s) => s.toJson()).toList(),
          'thumbnail': base64Encode(bytes.buffer.asUint8List()),
          'lesson': widget.id,
          'theme': lesson?['theme'],
        },
      );
      final ok = await ref
          .read(controllerProvider)
          .remember(memory, draftId: widget.id);
      if (!ok && mounted) {
        setState(() => feedback = ref.read(controllerProvider).error);
      }
      if (ok && mounted) {
        strokes.clear();
        await showReward(
          context,
          'A picture for our home',
          'Your creation is on our wall. An artist’s beret is waiting in the wardrobe!',
        );
      }
    } catch (_) {
      if (mounted) {
        setState(
          () =>
              feedback = 'Your picture is still here. Please try saving again.',
        );
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = ref.watch(controllerProvider);
    final lesson = app.content.find('drawings', widget.id);
    if (lesson == null && widget.id != 'create') {
      return const PageShell(
        title: 'Art corner',
        child: Center(
          child: Text(
            'This lesson is unavailable. Your saved pictures are safe.',
          ),
        ),
      );
    }
    final steps = lesson?['steps'] as List? ?? [];
    final reduced =
        app.world.reducedMotion || MediaQuery.disableAnimationsOf(context);
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (steps.isNotEmpty) step = step.clamp(0, steps.length - 1).toInt();
    final current = steps.isEmpty
        ? null
        : Map<String, dynamic>.from(steps[step]);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) leave();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Back home',
            onPressed: saving ? null : leave,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          title: Text(lesson?['title'] ?? 'Make something lovely'),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (lesson != null)
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      children: ['Watch', 'Together', 'Create']
                          .map(
                            (m) => ChoiceChip(
                              avatar: Icon(m == 'Watch' ? Icons.play_circle_rounded : m == 'Together' ? Icons.gesture_rounded : Icons.palette_rounded),
                              label: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text(m),
                              ),
                              selected: mode == m,
                              onSelected: saving
                                  ? null
                                  : (_) {
                                      setState(() => mode = m);
                                      guide.forward(from: 0);
                                      keepDraft();
                                    },
                            ),
                          )
                          .toList(),
                    ),
                  const SizedBox(height: 12),
                  Paper(
                    color: Brand.mint,
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      mode == 'Create'
                          ? 'Every mark is yours. What will you imagine?'
                          : '${step + 1} / ${steps.length}  ·  ${current?['say'] ?? ''}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 12),
                  AspectRatio(
                    aspectRatio: 1,
                    child: LayoutBuilder(
                      builder: (context, c) => Semantics(
                        label: 'Drawing paper. Drag one finger to draw.',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: GestureDetector(
                            onPanStart: (d) =>
                                point(d.localPosition, c.biggest, start: true),
                            onPanUpdate: (d) =>
                                point(d.localPosition, c.biggest),
                            onPanEnd: (_) => keepDraft(),
                            onPanCancel: () => keepDraft(),
                            onTapUp: (d) {
                              point(d.localPosition, c.biggest, start: true);
                              keepDraft();
                            },
                            child: AnimatedBuilder(
                              animation: guide,
                              builder: (context, child) => CustomPaint(
                                size: c.biggest,
                                painter: StrokePainter(
                                  repaint: paintRevision,
                                  strokes: strokes,
                                  guides: mode == 'Create'
                                      ? []
                                      : steps
                                            .take(step + 1)
                                            .map(
                                              (s) =>
                                                  Map<String, dynamic>.from(s),
                                            )
                                            .toList(),
                                  progress: reduced ? 1 : guide.value,
                                  watch: mode == 'Watch',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (mode != 'Create' && steps.isNotEmpty)
                    Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        BigAction(
                          'Back',
                          Icons.skip_previous_rounded,
                          step > 0
                              ? () {
                                  setState(() => step--);
                                  guide.forward(from: 0);
                                  keepDraft();
                                }
                              : null,
                        ),
                        BigAction(
                          'Show again',
                          Icons.replay_rounded,
                          () => guide.forward(from: 0),
                        ),
                        BigAction(
                          'Next',
                          Icons.skip_next_rounded,
                          step < steps.length - 1
                              ? () {
                                  setState(() => step++);
                                  guide.forward(from: 0);
                                  keepDraft();
                                }
                              : null,
                        ),
                      ],
                    ),
                  if (mode != 'Create')
                    Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        BigAction(
                          guide.isAnimating ? 'Pause' : 'Continue',
                          guide.isAnimating
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          () => setState(() {
                            if (guide.isAnimating) {
                              guide.stop();
                            } else {
                              guide.forward(
                                from: guide.value == 1 ? 0 : guide.value,
                              );
                            }
                          }),
                        ),
                        if (current?['audio'] != null)
                          BigAction(
                            'Listen',
                            Icons.volume_up_rounded,
                            () => app.audio.narrate(current!['audio']),
                          ),
                      ],
                    ),
                  if (mode != 'Watch') ...[
                    Wrap(
                      alignment: WrapAlignment.center,
                      children:
                          [
                                0xFF344A46,
                                0xFF638A72,
                                0xFFCE6C55,
                                0xFF528BAD,
                                0xFF977AB5,
                                0xFFF0BE51,
                              ]
                              .map(
                                (v) => Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Semantics(
                                    label: {
                                      0xFF344A46: 'Ink',
                                      0xFF638A72: 'Green',
                                      0xFFCE6C55: 'Coral',
                                      0xFF528BAD: 'Blue',
                                      0xFF977AB5: 'Purple',
                                      0xFFF0BE51: 'Gold',
                                    }[v],
                                    selected: color == v && !eraser,
                                    child: IconButton.filled(
                                      style: IconButton.styleFrom(
                                        backgroundColor: Color(v),
                                        minimumSize: const Size(52, 52),
                                      ),
                                      onPressed: () => setState(() {
                                        color = v;
                                        eraser = false;
                                      }),
                                      icon: Icon(
                                        color == v && !eraser
                                            ? Icons.check
                                            : Icons.circle,
                                        color: Colors.white,
                                        size: color == v ? 22 : 8,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                    Row(
                      children: [
                        const Text('Brush size'),
                        Expanded(
                          child: Slider(
                            label: width < .02 ? 'Fine' : 'Thick',
                            value: width,
                            min: .006,
                            max: .045,
                            onChanged: (v) => setState(() => width = v),
                          ),
                        ),
                      ],
                    ),
                    Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        BigAction(
                          'Undo',
                          Icons.undo_rounded,
                          strokes.isEmpty
                              ? null
                              : () => edit(
                                  () => undone.add(strokes.removeLast()),
                                ),
                        ),
                        BigAction(
                          'Redo',
                          Icons.redo_rounded,
                          undone.isEmpty
                              ? null
                              : () => edit(
                                  () => strokes.add(undone.removeLast()),
                                ),
                        ),
                        BigAction(
                          eraser ? 'Brush' : 'Eraser',
                          eraser
                              ? Icons.brush_rounded
                              : Icons.cleaning_services_rounded,
                          () => setState(() => eraser = !eraser),
                        ),
                        BigAction(
                          'Clear',
                          Icons.delete_outline_rounded,
                          strokes.isEmpty
                              ? null
                              : () async {
                                  final yes = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text(
                                        'Start a fresh picture?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, false),
                                          child: const Text('Keep it'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, true),
                                          child: const Text('Fresh paper'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (yes == true && mounted) {
                                    edit(() {
                                      strokes.clear();
                                      undone.clear();
                                    });
                                  }
                                },
                        ),
                      ],
                    ),
                    if (feedback != null) Text(feedback!),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: strokes.isEmpty || saving
                          ? null
                          : () => save(lesson),
                      icon: const Icon(Icons.favorite_rounded),
                      label: Text(
                        saving ? 'Saving our memory…' : 'Keep in our home',
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class StrokePainter extends CustomPainter {
  final List<DrawingStroke> strokes;
  final List<Json> guides;
  final double progress;
  final bool watch;
  StrokePainter({
    required this.strokes,
    this.guides = const [],
    this.progress = 1,
    this.watch = false,
    super.repaint,
  });
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);
    final pen = Paint()
      ..isAntiAlias = true
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    void draw(List<List<double>> points, double portion) {
      if (points.isEmpty) return;
      final path = Path()
        ..moveTo(points.first[0] * size.width, points.first[1] * size.height);
      for (final pt in points.skip(1)) {
        path.lineTo(pt[0] * size.width, pt[1] * size.height);
      }
      if (points.length == 1) {
        canvas.drawCircle(
          Offset(points.first[0] * size.width, points.first[1] * size.height),
          pen.strokeWidth / 2,
          Paint()
            ..color = pen.color
            ..blendMode = pen.blendMode,
        );
        return;
      }
      if (portion == 1) {
        canvas.drawPath(path, pen);
        return;
      }
      for (final metric in path.computeMetrics()) {
        canvas.drawPath(metric.extractPath(0, metric.length * portion), pen);
      }
    }

    if (watch) {
      for (var i = 0; i < guides.length; i++) {
        pen
          ..color = Brand.sage
          ..strokeWidth = size.width * .01;
        draw(
          (guides[i]['points'] as List)
              .map(
                (p) => (p as List).map((v) => (v as num).toDouble()).toList(),
              )
              .toList(),
          i == guides.length - 1 ? progress : 1,
        );
      }
      return;
    }
    if (guides.isNotEmpty) {
      for (var i = 0; i < guides.length; i++) {
        pen
          ..color = const Color(0x55638A72)
          ..strokeWidth = size.width * .009;
        draw(
          (guides[i]['points'] as List)
              .map(
                (p) => (p as List).map((v) => (v as num).toDouble()).toList(),
              )
              .toList(),
          i == guides.length - 1 ? progress : 1,
        );
      }
    }
    canvas.saveLayer(Offset.zero & size, Paint());
    for (final stroke in strokes) {
      pen
        ..color = Color(stroke.color)
        ..strokeWidth = stroke.width * size.width
        ..blendMode = stroke.erase ? BlendMode.clear : BlendMode.srcOver;
      draw(stroke.points, 1);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant StrokePainter old) => true;
}
