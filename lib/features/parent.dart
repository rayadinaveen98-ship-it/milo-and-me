import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/brand.dart';
import '../core/version.dart';
import '../core/controller.dart';
import '../ui/common.dart';
import 'parent_cloud.dart';

class ParentScreen extends ConsumerStatefulWidget {
  const ParentScreen({super.key});
  @override
  ConsumerState<ParentScreen> createState() => _ParentScreenState();
}

class _ParentScreenState extends ConsumerState<ParentScreen> {
  final pin = TextEditingController();
  bool busy = false;
  String? error;
  @override
  void dispose() {
    pin.dispose();
    super.dispose();
  }

  Future<void> unlock() async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final ok = await ref.read(controllerProvider).security.verify(pin.text);
      if (ok) {
        ref.read(controllerProvider).unlockParent();
        pin.clear();
      } else {
        setState(() => error = 'That PIN didn’t match. Please try again.');
      }
    } catch (e) {
      if (mounted) {
        setState(
          () => error =
              'Please wait a minute before trying again, or check device secure storage.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = ref.watch(controllerProvider), w = app.world;
    void leave() {
      app.lockParent();
      context.go('/home');
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) leave();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('For grown-ups'),
          leading: IconButton(
            tooltip: 'Return to play',
            onPressed: leave,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: !app.parentUnlocked
                    ? [
                        const Icon(
                          Icons.lock_outline_rounded,
                          size: 64,
                          color: Brand.sage,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'A space just for you',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Enter the six-digit PIN chosen at setup.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: pin,
                          obscureText: true,
                          maxLength: 6,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Parent PIN',
                          ),
                          onSubmitted: (_) {
                            if (!busy) unlock();
                          },
                        ),
                        if (error != null) Text(error!),
                        FilledButton(
                          onPressed: busy ? null : unlock,
                          child: Text(busy ? 'Checking…' : 'Open parent space'),
                        ),
                      ]
                    : [
                        if (error != null) Text(error!),
                        Text(
                          'Small moments, meaningful play',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 18),
                        Paper(
                          color: Brand.mint,
                          child: Text(
                            '${w.memories.where((m) => m.kind == 'drawing').length} pictures made\n${w.completedPuzzles.length} puzzles explored\n${w.completedStories.length} stories shared\n${w.memories.where((m) => m.kind == 'science').length} discoveries\n${w.companion.favourites.keys.join(', ')} explored\n\nProgress belongs to your child. There are no rankings.',
                          ),
                        ),
                        const SizedBox(height: 22),
                        Text(
                          'A comfortable play space',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        SwitchListTile(
                          title: const Text('Gentle room music'),
                          value: w.music,
                          onChanged: (v) async {
                            await app.change((n) {
                              n.music = v;
                              return n;
                            });
                            await app.configureAudio();
                          },
                        ),
                        SwitchListTile(
                          title: const Text('Sound effects'),
                          value: w.effects,
                          onChanged: (v) async {
                            await app.change((n) {
                              n.effects = v;
                              return n;
                            });
                            await app.configureAudio();
                          },
                        ),
                        SwitchListTile(
                          title: const Text('Reduced motion'),
                          subtitle: const Text(
                            'Keep the pet and drawing guides still.',
                          ),
                          value: w.reducedMotion,
                          onChanged: (v) => app.change((n) {
                            n.reducedMotion = v;
                            return n;
                          }),
                        ),
                        SwitchListTile(title: const Text('Story and drawing narration'), subtitle: const Text('Plays authored recordings where available. No microphone or cloud voice service.'), value: w.voice, onChanged: (v) async { if (!app.parentUnlocked) return; await app.change((n) { n.voice = v; return n; }); await app.configureAudio(); }),
                        const ListTile(
                          leading: Icon(Icons.language_rounded), title: Text('Language: English'), subtitle: Text('Current bundled content and controls use English. Downloaded packs declare their language.')),
                        const ListTile(
                          leading: Icon(Icons.record_voice_over_outlined),
                          title: Text('Read-together stories'),
                          subtitle: Text(
                            'This edition uses on-screen text. Recorded narration is not included yet.',
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text('Time for each play session'),
                        Wrap(
                          spacing: 8,
                          children: [10, 20, 30, 45]
                              .map(
                                (minutes) => ChoiceChip(
                                  label: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Text('$minutes min'),
                                  ),
                                  selected: w.sessionMinutes == minutes,
                                  onSelected: (_) => app.change((n) {
                                    n.sessionMinutes = minutes;
                                    return n;
                                  }),
                                ),
                              )
                              .toList(),
                        ),
                        Text(
                          '${app.elapsedSeconds ~/ 60} minutes in this session. A break screen appears at the limit.',
                        ),
                        TextButton.icon(
                          onPressed: () async {
                            try {
                              await app.newSession();
                              if (context.mounted) leave();
                            } catch (_) {
                              if (mounted) {
                                setState(
                                  () => error =
                                      'Could not start a session. Please try again.',
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.play_circle_outline_rounded),
                          label: const Text('Start a fresh play session'),
                        ),
                        const Divider(height: 36),
                        Text(
                          'Profile & privacy',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        ListTile(
                          title: const Text('Local nickname'),
                          subtitle: Text(w.nickname),
                          trailing: const Icon(Icons.edit_outlined),
                          onTap: () async {
                            final name = TextEditingController(
                              text: w.nickname,
                            );
                            final result = await showDialog<String>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Change nickname'),
                                content: TextField(
                                  controller: name,
                                  maxLength: 20,
                                  decoration: const InputDecoration(
                                    labelText: 'Nickname',
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Cancel'),
                                  ),
                                  FilledButton(
                                    onPressed: () {
                                      if (name.text.trim().isNotEmpty) {
                                        Navigator.pop(ctx, name.text.trim());
                                      }
                                    },
                                    child: const Text('Save'),
                                  ),
                                ],
                              ),
                            );
                            if (result != null) {
                              await app.change((n) {
                                n.nickname = result;
                                return n;
                              });
                            }
                          },
                        ),
                        const Paper(
                          child: Text(
                            'Your child’s nickname, pet, artwork, progress and memories are stored in this app’s private space on this device. No child account, ads, tracking or child-data cloud upload is enabled. No microphone, camera, contacts or location permission is requested. Android automatic backup is disabled.\n\nLocal-storage agreement was recorded during setup. Deleting the app may permanently remove creations. This is not a cloud backup service.',
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Activities on this device',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        ListTile(
                          leading: const Icon(Icons.offline_pin_outlined),
                          title: const Text('Meadow friends · Included'),
                          subtitle: Text(
                            '${app.content.list('drawings').length} drawings · ${app.content.list('puzzles').length} puzzles · ${app.content.list('stories').length} stories\nAvailable without internet',
                          ),
                        ),
                        const Text(
                          'Included content is stored on this device. Manage optional parent services below.',
                        ),
                        const Divider(height: 36),
                        const ParentCloudPanel(),
                        const Divider(height: 36),
                        Text(
                          'Manage this device',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        TextButton.icon(
                          onPressed: busy
                              ? null
                              : () async {
                                  final yes = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text(
                                        'Delete this local profile?',
                                      ),
                                      content: const Text(
                                        'This permanently deletes this child’s pet, drawings, stories, progress and downloaded packs on this device. The parent PIN remains until setup is completed again.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, false),
                                          child: const Text('Keep everything'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, true),
                                          child: const Text(
                                            'Delete local data',
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (yes != true) return;
                                  setState(() => busy = true);
                                  final ok = await app.reset();
                                  if (ok && context.mounted) {
                                    app.lockParent();
                                    context.go('/');
                                  }
                                  if (mounted) setState(() => busy = false);
                                },
                          icon: const Icon(Icons.delete_outline_rounded),
                          label: const Text(
                            'Delete local profile and creations',
                          ),
                        ),
                        const ListTile(leading: Icon(Icons.help_outline_rounded), title: Text('Help & accessibility'), subtitle: Text('Tap Milo for a reaction. Activities save on this device; use the memory book to revisit creations. Use Android text size and screen reader settings, plus reduced motion above. A parent PIN is required for adult controls. For support, use the repository issue tracker and omit child names, pictures and personal information.')),
                        const SizedBox(height: 18),
                        const Text(
                          'Milo & Me · $appVersion\nSupervised playtest edition. English content.\nNo medical, developmental or learning outcome claims.',
                          textAlign: TextAlign.center,
                        ),
                      ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
