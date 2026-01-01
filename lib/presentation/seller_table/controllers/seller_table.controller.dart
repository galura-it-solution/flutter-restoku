import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:slims/core/constants/colors.dart';
import 'package:slims/core/utils/api_error.dart';
import 'package:slims/core/utils/secure_storage.dart';
import 'package:slims/infrastructure/data/restApi/restoku/model/table.model.dart';
import 'package:slims/infrastructure/data/restApi/restoku/service/table.service.dart';
import 'package:slims/infrastructure/data/restApi/restoku/service/tables_events.service.dart';

class SellerTableController extends GetxController {
  final tables = <TableModel>[].obs;
  final loading = false.obs;
  final actionLoading = false.obs;
  final deletingId = Rxn<int>();
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final errorMessage = ''.obs;
  final page = 1.obs;
  final int perPage = 20;
  final scrollController = ScrollController();
  Timer? _pollTimer;
  StreamSubscription<String>? _tableEventsSub;
  StreamSubscription<bool>? _tableConnectionSub;
  DateTime? _lastTableRefresh;
  bool _sseHealthy = false;

  late final TableService tableService;
  late final TablesEventsService tablesEventsService;

  @override
  void onInit() {
    super.onInit();
    final baseUrl = SecureStorageHelper.generateBaseUrl();
    tableService = TableService(baseUrl: baseUrl);
    tablesEventsService = Get.isRegistered<TablesEventsService>()
        ? Get.find<TablesEventsService>()
        : Get.put(TablesEventsService(), permanent: true);
    fetchTables();

    _tableConnectionSub =
        tablesEventsService.connectionChanges.listen((connected) {
      if (connected) {
        _markSseConnected();
      } else {
        _markSseDisconnected();
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
      _markSseDisconnected();
    }

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        fetchTables(loadMore: true);
      }
    });
  }

  Future<void> fetchTables({bool loadMore = false, bool silent = false}) async {
    if (loadMore) {
      if (isLoadingMore.value || !hasMore.value) return;
      isLoadingMore.value = true;
    } else if (!silent) {
      loading.value = true;
      errorMessage.value = '';
      page.value = 1;
      hasMore.value = true;
    } else {
      page.value = 1;
      hasMore.value = true;
    }
    final currentPage = loadMore ? page.value + 1 : 1;
    List<TableModel> parsed = [];

    void applyTables(dynamic raw) {
      if (raw == null) return;
      final data = raw is String ? json.decode(raw) : raw;
      final listData = (data['data'] as List?) ?? [];
      parsed = listData
          .whereType<Map<String, dynamic>>()
          .map(TableModel.fromJson)
          .toList();
      if (loadMore) {
        tables.addAll(parsed);
      } else {
        tables.assignAll(parsed);
      }
      errorMessage.value = '';
    }

    final result = await tableService.getTables(
      page: currentPage,
      perPage: perPage,
      onUpdate: applyTables,
    );

    result.fold(
      (l) {
        errorMessage.value = ApiErrorMessage.from(
          l,
          fallback: 'Gagal memuat meja.',
        );
      },
      (r) => applyTables(r.data),
    );

    if (parsed.isNotEmpty) {
      page.value = currentPage;
    }
    hasMore.value = parsed.length == perPage;

    if (loadMore) {
      isLoadingMore.value = false;
    } else {
      loading.value = false;
    }
  }

  void _markSseConnected() {
    if (_sseHealthy) return;
    _sseHealthy = true;
    _stopPolling();
  }

  void _markSseDisconnected() {
    if (!_sseHealthy) {
      _startPolling();
      return;
    }
    _sseHealthy = false;
    _startPolling();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      fetchTables(silent: true);
    });
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> createTable(Map<String, dynamic> payload) async {
    if (actionLoading.value) return;
    actionLoading.value = true;
    try {
      final result = await tableService.createTable(payload);
      result.fold(
        (l) {
          final message = ApiErrorMessage.from(
            l,
            fallback: 'Tidak bisa membuat meja.',
          );
          Get.snackbar(
            'Gagal',
            message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: MasterColor.danger,
            colorText: MasterColor.white,
          );
        },
        (r) {
          fetchTables();
        },
      );
    } finally {
      actionLoading.value = false;
    }
  }

  Future<void> updateTable(int id, Map<String, dynamic> payload) async {
    if (actionLoading.value) return;
    actionLoading.value = true;
    try {
      final result = await tableService.updateTable(id, payload);
      result.fold(
        (l) {
          final message = ApiErrorMessage.from(
            l,
            fallback: 'Tidak bisa mengubah meja.',
          );
          Get.snackbar(
            'Gagal',
            message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: MasterColor.danger,
            colorText: MasterColor.white,
          );
        },
        (r) {
          fetchTables();
        },
      );
    } finally {
      actionLoading.value = false;
    }
  }

  Future<void> deleteTable(int id) async {
    if (deletingId.value == id) return;
    deletingId.value = id;
    try {
      final result = await tableService.deleteTable(id);
      result.fold(
        (l) {
          final message = ApiErrorMessage.from(
            l,
            fallback: 'Tidak bisa menghapus meja.',
          );
          Get.snackbar(
            'Gagal',
            message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: MasterColor.danger,
            colorText: MasterColor.white,
          );
        },
        (r) {
          fetchTables();
        },
      );
    } finally {
      if (deletingId.value == id) {
        deletingId.value = null;
      }
    }
  }

  @override
  void onClose() {
    _tableEventsSub?.cancel();
    _tableConnectionSub?.cancel();
    _pollTimer?.cancel();
    scrollController.dispose();
    super.onClose();
  }
}
