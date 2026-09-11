import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/brand.dart';
import '../core/controller.dart';
import '../ui/pet.dart';
import '../ui/common.dart';
import '../ui/illustrated.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int step = 0, color = 0;
  bool consent = false, busy = false;
  String? error;
  final nickname = TextEditingController(),
      pet = TextEditingController(text: Brand.defaultPet),
      pin = TextEditingController(),
      confirmPin = TextEditingController();
  @override
  void dispose() {
    nickname.dispose();
    pet.dispose();
    pin.dispose();
    confirmPin.dispose();
    super.dispose();
  }

  Future<void> next() async {
    if (busy) return;
    setState(() {
      busy = true;
      error = null;
    });
    final app = ref.read(controllerProvider);
    try {
      if (step == 1) {
        if (!consent) {
          throw const FormatException(
            'A grown-up needs to read and agree before we begin.',
          );
        }
        if (pin.text != confirmPin.text) {
          throw const FormatException('Those PINs don’t match.');
        }
        await app.security.setPin(pin.text);
      }
      if (step == 2 && nickname.text.trim().isEmpty) {
        throw const FormatException('Choose a nickname to use here.');
      }
      if (step == 3 && pet.text.trim().isEmpty) {
        throw const FormatException('What shall we call your friend?');
      }
      if (step == 4) {
        final ok = await app.change((w) {
          w.nickname = nickname.text.trim();
          w.petName = pet.text.trim();
          w.color = color;
          w.onboarded = true;
          w.privacyAccepted = true;
          return w;
        });
        if (ok) {
          await app.care('cuddle');
          if (mounted) context.go('/drawing/flower');
        }
      } else if (mounted) {
        setState(() => step++);
      }
    } catch (e) {
      if (mounted) {
        setState(
          () => error = e is FormatException
              ? e.message.toString()
              : 'We couldn’t save the parent PIN. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final headings = [
      'A little friend.\nA world to discover.',
      'A little note for grown-ups',
      'Who’s coming to play?',
      'Meet your forever curious friend',
      'Your first little adventure',
    ];
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.all(28),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        Brand.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    Text(
                      '${step + 1} / 5',
                      style: const TextStyle(color: Brand.sage),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: step == 1 ? 100 : 310,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(36),
                    child: Stack(
                      children: [
                        if (step != 1)
                          Positioned.fill(
                            child: SceneArt(
                              step == 4 ? 'studio' : 'garden',
                              fit: BoxFit.cover,
                            ),
                          ),
                        Positioned.fill(
                          child: PetView(
                            color: color,
                            pose: step == 0
                                ? 'waving'
                                : step == 2
                                ? 'curious'
                                : step == 4
                                ? 'celebrating'
                                : 'happy',
                            reducedMotion: MediaQuery.disableAnimationsOf(
                              context,
                            ),
                            onTap: step == 4 ? next : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Text(
                  headings[step],
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 18),
                if (step == 0)
                  const Text(
                    'Draw a dream. Solve a little mystery. Make memories together.',
                    textAlign: TextAlign.center,
                  ),
                if (step == 1) ...[
                  const Paper(
                    child: Text(
                      'An offline play space for ages 5–8. No ads, chat, child account, microphone or tracking. Nicknames, pictures and memories stay on this device. Deleting the app may erase them.\n\nThis early version includes a small original activity collection. Please play together at first.',
                    ),
                  ),
                  CheckboxListTile(
                    value: consent,
                    onChanged: (v) => setState(() => consent = v ?? false),
                    title: const Text(
                      'I’m the grown-up setting this up, and I agree to local storage.',
                    ),
                  ),
                  TextField(
                    controller: pin,
                    decoration: const InputDecoration(
                      labelText: 'Create a six-digit parent PIN',
                    ),
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  TextField(
                    controller: confirmPin,
                    decoration: const InputDecoration(
                      labelText: 'Repeat parent PIN',
                    ),
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const Text(
                    'Keep this PIN private. It protects settings and data deletion. No email is collected for recovery.',
                  ),
                ],
                if (step == 2) ...[
                  const Text(
                    'A made-up nickname is lovely. No real name needed.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nickname,
                    maxLength: 20,
                    decoration: const InputDecoration(
                      labelText: 'Your nickname',
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                ],
                if (step == 3) ...[
                  TextField(
                    controller: pet,
                    maxLength: 20,
                    decoration: const InputDecoration(
                      labelText: 'Your friend’s name',
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const Text(
                    'Choose a cosy colour',
                    textAlign: TextAlign.center,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (i) => Semantics(
                        label: ['Honey', 'Sage', 'Lilac'][i],
                        selected: color == i,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: IconButton.filled(
                            style: IconButton.styleFrom(
                              backgroundColor: Brand.petColors[i],
                              foregroundColor: Brand.ink,
                              minimumSize: const Size(60, 60),
                            ),
                            onPressed: () => setState(() => color = i),
                            icon: Icon(
                              color == i ? Icons.check : Icons.circle_outlined,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                if (step == 4)
                  Text(
                    '“Hello, ${nickname.text}! Tap me for our first cuddle. Then let’s draw a flower for our home.”',
                    textAlign: TextAlign.center,
                  ),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: busy ? null : next,
                  child: Text(
                    busy
                        ? 'Saving…'
                        : [
                            'Let’s meet',
                            'Continue',
                            'Meet my friend',
                            'That’s my friend',
                            'A cuddle & let’s play',
                          ][step],
                  ),
                ),
                if (step > 1)
                  TextButton(
                    onPressed: busy ? null : () => setState(() => step--),
                    child: const Text('Back'),
                  ),
                const SizedBox(height: 18),
                const Text(
                  Brand.tagline,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Brand.sage),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
