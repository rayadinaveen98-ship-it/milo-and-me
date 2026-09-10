import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'parent_backend.dart';

class StoreProduct {
  final String id, title, price;
  const StoreProduct(this.id, this.title, this.price);
}

class StoreReceipt {
  final String productId, token, source;
  final Object? native;
  const StoreReceipt(this.productId, this.token, this.source, {this.native});
}

abstract interface class PurchaseStore {
  Stream<StoreReceipt> get receipts;
  Future<List<StoreProduct>> products(Set<String> ids);
  Future<void> buy(String id, String parentId);
  Future<void> restore();
  Future<void> complete(StoreReceipt receipt);
  Future<void> dispose();
}

class GooglePurchaseStore implements PurchaseStore {
  final InAppPurchase api;
  final _events = StreamController<StoreReceipt>.broadcast();
  late final StreamSubscription<List<PurchaseDetails>> _subscription;
  final Map<String, ProductDetails> _products = {};
  GooglePurchaseStore({InAppPurchase? api})
    : api = api ?? InAppPurchase.instance {
    _subscription = this.api.purchaseStream.listen((updates) {
      for (final p in updates) {
        if (p.status == PurchaseStatus.purchased ||
            p.status == PurchaseStatus.restored) {
          _events.add(
            StoreReceipt(
              p.productID,
              p.verificationData.serverVerificationData,
              p.verificationData.source,
              native: p,
            ),
          );
        } else if (p.status == PurchaseStatus.error ||
            p.status == PurchaseStatus.canceled) {
          _events.addError(StateError('Purchase was not completed.'));
        }
      }
    }, onError: _events.addError);
  }
  @override
  Stream<StoreReceipt> get receipts => _events.stream;
  @override
  Future<List<StoreProduct>> products(Set<String> ids) async {
    if (!await api.isAvailable()) {
      throw StateError('Google Play is unavailable on this device.');
    }
    final result = await api.queryProductDetails(ids);
    if (result.error != null || result.notFoundIDs.isNotEmpty) {
      throw StateError('Store products are not configured yet.');
    }
    for (final p in result.productDetails) {
      _products[p.id] = p;
    }
    return result.productDetails
        .map((p) => StoreProduct(p.id, p.title, p.price))
        .toList();
  }

  @override
  Future<void> buy(String id, String parentId) async {
    final p = _products[id];
    if (p == null) throw StateError('Load store products first.');
    if (!await api.buyNonConsumable(
      purchaseParam: PurchaseParam(
        productDetails: p,
        applicationUserName: parentId,
      ),
    )) {
      throw StateError('Store could not start this purchase.');
    }
  }

  @override
  Future<void> restore() => api.restorePurchases();
  @override
  Future<void> complete(StoreReceipt receipt) async {
    final p = receipt.native as PurchaseDetails;
    if (p.pendingCompletePurchase) await api.completePurchase(p);
  }

  @override
  Future<void> dispose() async {
    await _subscription.cancel();
    await _events.close();
  }
}

class SandboxPurchaseStore implements PurchaseStore {
  final _events = StreamController<StoreReceipt>.broadcast();
  StoreReceipt? owned;
  int completed = 0;
  @override
  Stream<StoreReceipt> get receipts => _events.stream;
  @override
  Future<List<StoreProduct>> products(Set<String> ids) async => [
    for (final id in ids)
      StoreProduct(id, 'Test $id', 'No charge · simulation'),
  ];
  @override
  Future<void> buy(String id, String parentId) async {
    owned = StoreReceipt(id, 'sandbox:$parentId:$id', 'sandbox');
    _events.add(owned!);
  }

  @override
  Future<void> restore() async {
    if (owned != null) _events.add(owned!);
  }

  @override
  Future<void> complete(StoreReceipt receipt) async {
    completed++;
  }

  @override
  Future<void> dispose() => _events.close();
}

/// A restored transaction takes exactly the same verification path as a new one.
class PurchaseCoordinator {
  final PurchaseStore store;
  final Future<Entitlement> Function(StoreReceipt) verify;
  final Future<void> Function(Entitlement) deliver;
  final void Function(String) report;
  late final StreamSubscription<StoreReceipt> _subscription;
  Future<void> _queue = Future.value();
  PurchaseCoordinator({
    required this.store,
    required this.verify,
    required this.deliver,
    required this.report,
  }) {
    _subscription = store.receipts.listen((r) {
      _queue = _queue.then((_) async {
        try {
          final verified = await verify(r);
          if (!verified.validAt(DateTime.now()) ||
              verified.productId != r.productId) {
            throw StateError('Store verification has not confirmed access.');
          }
          await deliver(verified);
          await store.complete(r);
          report('Purchase verified. Your library is ready.');
        } catch (_) {
          report(
            'Purchase could not be verified. No access was granted. Try Restore when connected.',
          );
        }
      });
    }, onError: (_) => report('The store did not complete this purchase.'));
  }
  Future<void> settle() => _queue;
  Future<void> dispose() async {
    await _subscription.cancel();
    await _queue;
    await store.dispose();
  }
}
