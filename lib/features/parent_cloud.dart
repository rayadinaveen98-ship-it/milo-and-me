import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/controller.dart';
import '../core/brand.dart';
import '../ui/common.dart';
import '../domain/models.dart';

class ParentCloudPanel extends ConsumerStatefulWidget {
  const ParentCloudPanel({super.key});
  @override
  ConsumerState<ParentCloudPanel> createState() => _ParentCloudState();
}

class _ParentCloudState extends ConsumerState<ParentCloudPanel> {
  final email = TextEditingController(), code = TextEditingController();
  bool consent = false, busy = false;
  String? message;
  double? downloadProgress;
  @override
  void dispose() {
    email.dispose();
    code.dispose();
    super.dispose();
  }

  Future<void> run(Future<void> Function() action) async {
    if (busy) return;
    setState(() {
      busy = true;
      message = null;
    });
    try {
      await action();
    } catch (_) {
      if (mounted) {
        setState(
          () => message =
              'This action could not finish. Check your connection and account configuration, then try again. Local play and saved creations are safe.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          busy = false;
          downloadProgress = null;
        });
      }
    }
  }

  Future<void> download(Json pack) async {
    final app = ref.read(controllerProvider);
    app.parentServices.guard();
    if (pack['price_tier'] == 'premium' && !app.access.premium) {
      throw StateError('Parent entitlement required');
    }
    await app.content.download(
      url: Uri.parse(pack['download_url']),
      expectedHash: pack['sha256'],
      expectedId: pack['id'],
      expectedVersion: pack['version'],
      progress: (received, total) {
        if (mounted) {
          setState(
            () => downloadProgress = total == null ? null : received / total,
          );
        }
      },
    );
    if (mounted) setState(() => message = 'Installed and ready offline.');
  }

  @override
  Widget build(BuildContext context) {
    final app = ref.watch(controllerProvider), service = app.parentServices;
    if (!app.parentUnlocked) return const SizedBox.shrink();
    Widget button(String label, Future<void> Function() action) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: OutlinedButton(
        onPressed: busy ? null : () => run(action),
        child: Text(label),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Parent account & library',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Paper(
          color: Brand.mint,
          child: Text(
            service.live
                ? 'Optional adult account. Your email, consent record and verified purchase status go to the parent service. Child nicknames, art, voice and activity history stay on this device. No cloud backup is enabled.'
                : 'Offline playtest: all included activities are open. No cloud account or subscription is active. Test-store buttons below are simulations and never charge money.',
          ),
        ),
        if (service.live) ...[
          TextField(
            controller: email,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            decoration: const InputDecoration(labelText: 'Your adult email'),
          ),
          CheckboxListTile(
            value: consent,
            onChanged: busy
                ? null
                : (v) => setState(() => consent = v ?? false),
            title: const Text(
              'I am the parent or guardian and agree to the parent-account data use above.',
            ),
          ),
          button('Email a sign-in code', () async {
            if (!consent) throw StateError('Review the notice first');
            await service.requestCode(email.text.trim());
          }),
          TextField(
            controller: code,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 8,
            decoration: const InputDecoration(labelText: 'Email code'),
          ),
          button('Sign in and record consent', () async {
            await service.verifyCode(
              email.text.trim(),
              code.text.trim(),
              consent,
            );
            code.clear();
          }),
          button('Refresh account and content catalogue', service.refresh),
          button('Sign out', () async {
            await service.signOut();
            email.clear();
            code.clear();
          }),
        ],
        const SizedBox(height: 12),
        Text(
          service.live
              ? (app.access.premium
                    ? 'Verified premium library'
                    : 'Free sample library')
              : 'Full playtest library',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const Text(
          'Free includes Milo, the core room and care, basic outfits, sample drawing and puzzle activities, and a story. Premium adds the full activity library and packs. Your existing creations remain yours.',
        ),
        button(
          service.live
              ? 'Load Google Play plans and prices'
              : 'Open no-charge test store',
          service.loadStore,
        ),
        for (final p in service.products)
          button('${p.title} · ${p.price}', () => service.buy(p.id)),
        button(
          service.live ? 'Restore purchases' : 'Simulate restore',
          service.restore,
        ),
        if (service.live)
          const Text(
            'Subscriptions renew automatically unless cancelled in Google Play. Manage or cancel in Play Store → Payments & subscriptions → Subscriptions. Deleting an account does not cancel billing.',
          ),
        if (service.status.isNotEmpty) Paper(child: Text(service.status)),
        const SizedBox(height: 20),
        Text('Downloads', style: Theme.of(context).textTheme.titleLarge),
        const Text(
          'Only catalogue packs verified by checksum can be installed. Installed packs work offline. Removing a pack keeps completed memories.',
        ),
        for (final pack in service.catalogue)
          ListTile(
            title: Text('${pack['title']} · v${pack['version']}'),
            subtitle: Text(
              pack['price_tier'] == 'premium'
                  ? 'Premium pack'
                  : 'Included pack',
            ),
            trailing: IconButton(
              tooltip: 'Download pack',
              onPressed:
                  busy ||
                      (pack['price_tier'] == 'premium' && !app.access.premium)
                  ? null
                  : () => run(() => download(pack)),
              icon: const Icon(Icons.download_rounded),
            ),
          ),
        for (final pack in app.content.installed)
          ListTile(
            title: Text('${pack['title'] ?? pack['id']} · v${pack['version']}'),
            subtitle: const Text('Installed · available offline'),
            trailing: IconButton(
              tooltip: 'Remove downloaded pack',
              onPressed: busy
                  ? null
                  : () => run(() async {
                      service.guard();
                      await app.content.uninstall(pack['id']);
                    }),
              icon: const Icon(Icons.delete_outline_rounded),
            ),
          ),
        if (busy) LinearProgressIndicator(value: downloadProgress),
        if (message != null) Text(message!),
        if (service.live)
          button('Delete parent cloud account', () async {
            final yes = await showDialog<bool>(
              context: context,
              builder: (c) => AlertDialog(
                title: const Text('Delete your cloud account?'),
                content: const Text(
                  'Deletes parent account, consent and entitlement records. Local creations stay on this device. Cancel your store subscription separately to stop billing.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(c, false),
                    child: const Text('Keep account'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(c, true),
                    child: const Text('Delete account'),
                  ),
                ],
              ),
            );
            if (yes == true) {
              await service.deleteAccount();
              email.clear();
              code.clear();
            }
          }),
      ],
    );
  }
}
