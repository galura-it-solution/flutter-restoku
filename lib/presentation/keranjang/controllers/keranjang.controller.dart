import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:slims/core/constants/colors.dart';
import 'package:slims/core/utils/api_error.dart';
import 'package:slims/core/utils/secure_storage.dart';
import 'package:slims/core/utils/shared_preference.dart';
import 'package:slims/infrastructure/data/restApi/restoku/model/menu.model.dart';
import 'package:slims/infrastructure/data/restApi/restoku/model/table.model.dart';
import 'package:slims/infrastructure/data/restApi/restoku/service/order.service.dart';
import 'package:slims/infrastructure/data/restApi/restoku/service/table.service.dart';
import 'package:slims/infrastructure/data/restApi/restoku/service/tables_events.service.dart';
import 'package:slims/presentation/home/controllers/home.controller.dart';
import 'package:slims/presentation/keranjang/models/cart_item.dart';
import 'package:slims/presentation/keranjang/controllers/ongoing_orders.controller.dart';

class KeranjangController extends GetxController {
  static const String _idempotencyKeyStorageKey =
      'last_order_idempotency_key';
  static const String _orderSignatureStorageKey = 'last_order_signature';

  final listCart = <CartItem>[].obs;
  final tables = <TableModel>[].obs;
  final selectedTableId = Rxn<int>();
  final loading = false.obs;
  final tableLoading = false.obs;
  final submitting = false.obs;
  final orderNote = ''.obs;
  String _lastIdempotencyKey = '';
  String _lastOrderSignature = '';
  bool _suppressIdempotencyReset = true;
  StreamSubscription<String>? _tableEventsSub;
  StreamSubscription<bool>? _tableConnectionSub;
  DateTime? _lastTableRefresh;
  Timer? _tablePollTimer;
  bool _tableSseHealthy = false;

  late final OrderService orderService;
  late final TableService tableService;
  late final TablesEventsService tablesEventsService;

  @override
  void onInit() {
    super.onInit();
    final baseUrl = SecureStorageHelper.generateBaseUrl();
    orderService = OrderService(baseUrl: baseUrl);
    tableService = TableService(baseUrl: baseUrl);
    tablesEventsService = Get.isRegistered<TablesEventsService>()
        ? Get.find<TablesEventsService>()
        : Get.put(TablesEventsService(), permanent: true);
    _loadIdempotencyFromStorage();
    setDataCartFromStorage().whenComplete(() {
      _suppressIdempotencyReset = false;
      _syncIdempotencyWithCurrentCart();
    });
    fetchTables();
    _tableConnectionSub =
        tablesEventsService.connectionChanges.listen((connected) {
      if (connected) {
        _markTableSseConnected();
      } else {
        _markTableSseDisconnected();
      }
    });
    _tableEventsSub = tablesEventsService.events.listen((payload) {
      if (payload == 'ping') return;
      final now = DateTime.now();
      if (_lastTableRefresh != null &&
          now.difference(_lastTableRefresh!) < const Duration(seconds: 1)) {
        return;
      }
      _lastTableRefresh = now;
      fetchTables(silent: true);
    });
    tablesEventsService.ensureConnected();
    if (!tablesEventsService.isConnected) {
      _markTableSseDisconnected();
    }

    ever(listCart, (_) {
      SharedPrefsHelper.saveModel(
        'cart',
        listCart.map((el) => el.toJson()).toList(),
      );
      HomeController homeController = Get.find();
      homeController.setCountItemCart();
      _handleOrderInputChange();
    });
    ever(orderNote, (_) => _handleOrderInputChange());
    ever(selectedTableId, (_) => _handleOrderInputChange());
  }

  Future<void> setDataCartFromStorage() async {
    loading.value = true;
    await Future.delayed(const Duration(milliseconds: 300));

    final listCartStorage = await SharedPrefsHelper.getModel('cart');

    if (listCartStorage is List) {
      final List<CartItem> data = listCartStorage
          .whereType<Map<String, dynamic>>()
          .map(CartItem.fromJson)
          .toList();

      listCart.assignAll(data);
    }

    loading.value = false;
  }

  Future<void> fetchTables({bool silent = false}) async {
    if (!silent) {
      tableLoading.value = true;
    }
    void applyTables(dynamic raw) {
      if (raw == null) return;
      final data = raw is String ? json.decode(raw) : raw;
      final listData = (data['data'] as List?) ?? [];
      final parsed = listData
          .whereType<Map<String, dynamic>>()
          .map(TableModel.fromJson)
          .toList();
      tables.assignAll(parsed);

      TableModel? availableTable;
      for (final table in tables) {
        if (table.status == 'available') {
          availableTable = table;
          break;
        }
      }

      if (selectedTableId.value == null && availableTable != null) {
        selectedTableId.value = availableTable.id;
      }
      _syncIdempotencyWithCurrentCart();
    }

    final result = await tableService.getTables(
      forceRefresh: true,
      useCache: false,
      onUpdate: applyTables,
    );

    result.fold(
      (l) {
        if (!silent) {
          final message = ApiErrorMessage.from(
            l,
            fallback: 'Tidak bisa memuat daftar meja.',
          );
          Get.snackbar(
            'Gagal',
            message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: MasterColor.danger,
            colorText: Colors.white,
            margin: const EdgeInsets.all(10),
            borderRadius: 8,
          );
        }
      },
      (r) => applyTables(r.data),
    );
    if (!silent) {
      tableLoading.value = false;
    }
  }

  void _markTableSseConnected() {
    if (_tableSseHealthy) return;
    _tableSseHealthy = true;
    _stopTablePolling();
  }

  void _markTableSseDisconnected() {
    if (!_tableSseHealthy) {
      _startTablePolling();
      return;
    }
    _tableSseHealthy = false;
    _startTablePolling();
  }

  void _startTablePolling() {
    _tablePollTimer?.cancel();
    _tablePollTimer = Timer.periodic(const Duration(seconds: 12), (_) {
      fetchTables(silent: true);
    });
  }

  void _stopTablePolling() {
    _tablePollTimer?.cancel();
    _tablePollTimer = null;
  }

  num get totalPrice {
    return listCart.fold(
      0,
      (previous, item) => previous + (item.menu.price * item.quantity),
    );
  }

  void addToCart(MenuModel menu) {
    if (!menu.isAvailable) {
      Get.snackbar(
        'Info',
        'Menu sedang tidak tersedia.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: MasterColor.warning,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(10),
        borderRadius: 8,
      );
      return;
    }
    final index = listCart.indexWhere((item) => item.menu.id == menu.id);

    if (index == -1) {
      listCart.add(CartItem(menu: menu, quantity: 1));
      Get.snackbar(
        'Berhasil',
        'Menu ditambahkan ke keranjang.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: MasterColor.primary,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(10),
        borderRadius: 8,
      );
      return;
    }

    final existing = listCart[index];
    listCart[index] = existing.copyWith(quantity: existing.quantity + 1);
  }

  void updateQuantity(MenuModel menu, int quantity) {
    final index = listCart.indexWhere((item) => item.menu.id == menu.id);

    if (index == -1) return;

    if (quantity <= 0) {
      listCart.removeAt(index);
    } else {
      listCart[index] = listCart[index].copyWith(quantity: quantity);
    }
  }

  void updateItemNote(MenuModel menu, String note) {
    final index = listCart.indexWhere((item) => item.menu.id == menu.id);
    if (index == -1) return;
    listCart[index] = listCart[index].copyWith(
      note: note.trim().isEmpty ? null : note.trim(),
    );
  }

  void removeFromCart(int menuId) {
    listCart.removeWhere((item) => item.menu.id == menuId);
  }

  void setSelectedTable(int tableId) {
    selectedTableId.value = tableId;
  }

  void clearCart() {
    listCart.clear();
    orderNote.value = '';
    _resetIdempotency();
  }

  Future<void> _loadIdempotencyFromStorage() async {
    _lastIdempotencyKey =
        await SharedPrefsHelper.getString(_idempotencyKeyStorageKey) ?? '';
    _lastOrderSignature =
        await SharedPrefsHelper.getString(_orderSignatureStorageKey) ?? '';
  }

  void _persistIdempotency(String signature, String key) {
    _lastOrderSignature = signature;
    _lastIdempotencyKey = key;
    SharedPrefsHelper.saveString(_orderSignatureStorageKey, signature);
    SharedPrefsHelper.saveString(_idempotencyKeyStorageKey, key);
  }

  void _resetIdempotency() {
    _lastIdempotencyKey = '';
    _lastOrderSignature = '';
    SharedPrefsHelper.remove(_orderSignatureStorageKey);
    SharedPrefsHelper.remove(_idempotencyKeyStorageKey);
  }

  void _syncIdempotencyWithCurrentCart() {
    if (_suppressIdempotencyReset) return;
    if (listCart.isEmpty) {
      _resetIdempotency();
      return;
    }
    if (selectedTableId.value == null) return;

    final items = listCart
        .map(
          (item) => {
            'menu_id': item.menu.id,
            'quantity': item.quantity,
            'notes': item.note,
          },
        )
        .toList();
    final noteValue = orderNote.value.trim();
    final signature = _buildOrderSignature(
      tableId: selectedTableId.value!,
      items: items,
      note: noteValue.isEmpty ? null : noteValue,
    );

    if (_lastOrderSignature.isEmpty ||
        _lastOrderSignature != signature ||
        _lastIdempotencyKey.isEmpty) {
      _resetIdempotency();
    }
  }

  void _handleOrderInputChange() {
    if (_suppressIdempotencyReset) return;
    if (listCart.isEmpty) {
      _resetIdempotency();
      return;
    }
    if (selectedTableId.value == null) return;

    final items = listCart
        .map(
          (item) => {
            'menu_id': item.menu.id,
            'quantity': item.quantity,
            'notes': item.note,
          },
        )
        .toList();
    final noteValue = orderNote.value.trim();
    final signature = _buildOrderSignature(
      tableId: selectedTableId.value!,
      items: items,
      note: noteValue.isEmpty ? null : noteValue,
    );

    if (_lastOrderSignature.isNotEmpty &&
        _lastOrderSignature != signature) {
      _resetIdempotency();
    }
  }

  String _buildOrderSignature({
    required int tableId,
    required List<Map<String, dynamic>> items,
    String? note,
  }) {
    final normalizedItems = List<Map<String, dynamic>>.from(items);
    normalizedItems.sort((a, b) {
      return (a['menu_id'] as int).compareTo(b['menu_id'] as int);
    });

    return jsonEncode({
      'table_id': tableId,
      'note': note ?? '',
      'items': normalizedItems
          .map(
            (item) => {
              'menu_id': item['menu_id'],
              'quantity': item['quantity'],
              'notes': item['notes'] ?? '',
            },
          )
          .toList(),
    });
  }

  Future<void> placeOrder() async {
    if (listCart.isEmpty) {
      Get.snackbar(
        'Info',
        'Keranjang masih kosong.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: MasterColor.warning,
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
        borderRadius: 8,
      );
      return;
    }

    if (selectedTableId.value == null) {
      Get.snackbar(
        'Info',
        'Pilih meja terlebih dahulu.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: MasterColor.warning,
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
        borderRadius: 8,
      );
      return;
    }

    submitting.value = true;

    final items = listCart
        .map(
          (item) => {
            'menu_id': item.menu.id,
            'quantity': item.quantity,
            'notes': item.note,
          },
        )
        .toList();

    final noteValue = orderNote.value.trim();
    final orderSignature = _buildOrderSignature(
      tableId: selectedTableId.value!,
      items: items,
      note: noteValue.isEmpty ? null : noteValue,
    );

    final idempotencyKey = (_lastOrderSignature == orderSignature &&
            _lastIdempotencyKey.isNotEmpty)
        ? _lastIdempotencyKey
        : 'order-${DateTime.now().millisecondsSinceEpoch}-${items.length}';

    _persistIdempotency(orderSignature, idempotencyKey);

    final result = await orderService.createOrder(
      tableId: selectedTableId.value!,
      items: items,
      note: noteValue.isEmpty ? null : noteValue,
      idempotencyKey: idempotencyKey,
    );

    result.fold(
      (l) {
        final message = ApiErrorMessage.from(
          l,
          fallback: 'Order tidak bisa diproses.',
        );
        Get.snackbar(
          'Gagal',
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: MasterColor.danger,
          colorText: Colors.white,
          margin: const EdgeInsets.all(10),
          borderRadius: 8,
        );
      },
      (r) {
        Get.snackbar(
          'Sukses',
          'Order berhasil dibuat.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: MasterColor.primary,
          colorText: Colors.white,
          margin: const EdgeInsets.all(10),
          borderRadius: 8,
        );
        clearCart();
        Get.find<OngoingOrdersController>().fetchOngoingOrders();
        fetchTables();
      },
    );

    submitting.value = false;
  }

  @override
  void onClose() {
    _tableEventsSub?.cancel();
    _tableConnectionSub?.cancel();
    _tablePollTimer?.cancel();
    super.onClose();
  }
}
