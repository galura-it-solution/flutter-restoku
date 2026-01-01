import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:slims/core/constants/colors.dart';
import 'package:slims/core/utils/api_error.dart';
import 'package:slims/core/utils/secure_storage.dart';
import 'package:slims/infrastructure/data/restApi/restoku/model/table.model.dart';
import 'package:slims/infrastructure/data/restApi/restoku/service/table.service.dart';

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

  late final TableService tableService;

  @override
  void onInit() {
    super.onInit();
    final baseUrl = SecureStorageHelper.generateBaseUrl();
    tableService = TableService(baseUrl: baseUrl);
    fetchTables();

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        fetchTables(loadMore: true);
      }
    });
  }

  Future<void> fetchTables({bool loadMore = false}) async {
    if (loadMore) {
      if (isLoadingMore.value || !hasMore.value) return;
      isLoadingMore.value = true;
    } else {
      loading.value = true;
      errorMessage.value = '';
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
    scrollController.dispose();
    super.onClose();
  }
}
