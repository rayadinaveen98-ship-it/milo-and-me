import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/brand.dart';
import 'core/controller.dart';
import 'data/database.dart';
import 'domain/engines.dart';
import 'data/content_repository.dart';
import 'features/onboarding.dart';
import 'features/home.dart';
import 'features/world.dart';
import 'features/scenarios.dart';
import 'features/catalogues.dart';
import 'features/drawing.dart';
import 'features/puzzle.dart';
import 'features/story.dart';
import 'features/memories.dart';
import 'features/wardrobe.dart';
import 'features/parent.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Bootstrap());
}

class Bootstrap extends StatefulWidget {
  const Bootstrap({super.key});
  @override
  State<Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<Bootstrap> {
  late Future<AppController> future;
  @override
  void initState() {
    super.initState();
    future = load();
  }

  Future<AppController> load() async {
    final db = await AppDatabase.open();
    try {
      final content = ContentRepository(db);
      await content.load();
      var world = await db.readWorld();
      if (world.onboarded) {
        world = PetEngine().greet(world, DateTime.now());
        await db.saveWorld(world);
      }
      return AppController(
        db,
        content,
        world,
        sessionSeconds: await db.readSession(),
      );
    } catch (_) {
      await db.close();
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<AppController>(
    future: future,
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        return ProviderScope(
          overrides: [controllerProvider.overrideWith((ref) => snapshot.data!)],
          child: const MiloApp(),
        );
      }
      return MaterialApp(
        theme: Brand.theme(),
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.spa_rounded, size: 76, color: Brand.sage),
                  const SizedBox(height: 18),
                  Text(
                    Brand.name,
                    style: Brand.theme().textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 20),
                  if (snapshot.hasError) ...[
                    const Text(
                      'We couldn’t open your play space. Your saved data has not been reset.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => setState(() => future = load()),
                      child: const Text('Try again'),
                    ),
                  ] else
                    const CircularProgressIndicator(),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

class MiloApp extends ConsumerStatefulWidget {
  const MiloApp({super.key});
  @override
  ConsumerState<MiloApp> createState() => _MiloAppState();
}

class _MiloAppState extends ConsumerState<MiloApp> {
  late GoRouter router;
  @override
  void initState() {
    super.initState();
    final app = ref.read(controllerProvider);
    Widget child(Widget screen) => SessionGuard(child: screen);
    router = GoRouter(
      initialLocation: app.world.onboarded ? '/home' : '/',
      refreshListenable: app,
      redirect: (context, state) {
        if (!app.world.onboarded && state.uri.path != '/') return '/';
        if (app.world.onboarded && state.uri.path == '/') return '/home';
        return null;
      },
      routes: [
        GoRoute(path: '/', builder: (c, s) => const OnboardingScreen()),
        GoRoute(path: '/home', builder: (c, s) => child(const HomeScreen())),
        GoRoute(path: '/world', builder: (c, s) => child(const WorldScreen())),
        for (final kind in ['cooking', 'roleplay']) ...[
          GoRoute(
            path: '/$kind',
            builder: (c, s) => child(ScenarioCatalogue(kind: kind)),
          ),
          GoRoute(
            path: '/$kind/:id',
            builder: (c, s) => child(
              ScenarioScreen(
                key: ValueKey(s.pathParameters['id']),
                kind: kind,
                id: s.pathParameters['id']!,
              ),
            ),
          ),
        ],
        for (final kind in ['drawings', 'puzzles', 'stories'])
          GoRoute(
            path: '/$kind',
            builder: (c, s) => child(CatalogueScreen(kind: kind)),
          ),
        GoRoute(
          path: '/drawing/:id',
          builder: (c, s) => child(
            DrawingScreen(
              key: ValueKey(s.pathParameters['id']),
              id: s.pathParameters['id']!,
            ),
          ),
        ),
        GoRoute(
          path: '/puzzle/:id',
          builder: (c, s) => child(
            PuzzleScreen(
              key: ValueKey(s.pathParameters['id']),
              id: s.pathParameters['id']!,
            ),
          ),
        ),
        GoRoute(
          path: '/story/:id',
          builder: (c, s) => child(
            StoryScreen(
              key: ValueKey(s.pathParameters['id']),
              id: s.pathParameters['id']!,
            ),
          ),
        ),
        GoRoute(
          path: '/wardrobe',
          builder: (c, s) => child(const WardrobeScreen()),
        ),
        GoRoute(
          path: '/memories',
          builder: (c, s) => child(const MemoriesScreen()),
        ),
        GoRoute(path: '/parent', builder: (c, s) => const ParentScreen()),
      ],
      errorBuilder: (c, s) => Scaffold(
        body: Center(
          child: FilledButton(
            onPressed: () => c.go('/home'),
            child: const Text('Back to our home'),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: Brand.name,
    debugShowCheckedModeBanner: false,
    theme: Brand.theme(),
    routerConfig: router,
  );
}

class SessionGuard extends ConsumerWidget {
  final Widget child;
  const SessionGuard({super.key, required this.child});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final app = ref.watch(controllerProvider);
    return Stack(
      children: [
        ExcludeSemantics(
          excluding: app.sessionOver,
          child: TickerMode(enabled: !app.sessionOver, child: child),
        ),
        if (app.sessionOver)
          Positioned.fill(
            child: Material(
              color: Brand.cream,
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.wb_sunny_rounded,
                          size: 72,
                          color: Brand.sage,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'A little time to rest',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Our adventures can wait. Shall we draw on paper or find a leaf outside?',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: () => context.go('/parent'),
                          child: const Text('Grown-up controls'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
