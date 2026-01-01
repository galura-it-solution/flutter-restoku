import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:slims/core/constants/colors.dart';
import 'package:slims/core/utils/api_error.dart';
import 'package:slims/core/utils/secure_storage.dart';
import 'package:slims/infrastructure/data/restApi/restoku/model/category.model.dart';
import 'package:slims/infrastructure/data/restApi/restoku/model/menu.model.dart';
import 'package:slims/infrastructure/data/restApi/restoku/service/category.service.dart';
import 'package:slims/infrastructure/data/restApi/restoku/service/menu.service.dart';

class SellerMenuController extends GetxController {
  final menus = <MenuModel>[].obs;
  final categories = <CategoryModel>[].obs;
  final loading = false.obs;
  final actionLoading = false.obs;
  final deletingId = Rxn<int>();
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final errorMessage = ''.obs;
  final page = 1.obs;
  final int perPage = 20;
  final scrollController = ScrollController();

  late final MenuService menuService;
  late final CategoryService categoryService;

  @override
  void onInit() {
    super.onInit();
    final baseUrl = SecureStorageHelper.generateBaseUrl();
    menuService = MenuService(baseUrl: baseUrl);
    categoryService = CategoryService(baseUrl: baseUrl);
    fetchCategories();
    fetchMenus();

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        fetchMenus(loadMore: true);
      }
    });
  }

  Future<void> fetchCategories() async {
    void applyCategories(dynamic raw) {
      if (raw == null) return;
      final data = raw is String ? json.decode(raw) : raw;
      final listData = (data['data'] as List?) ?? [];
      final parsed = listData
          .whereType<Map<String, dynamic>>()
          .map(CategoryModel.fromJson)
          .toList();
      categories.assignAll(parsed);
    }

    final result = await categoryService.getCategories(
      perPage: 100,
      onUpdate: applyCategories,
    );
    result.fold(
      (l) {},
      (r) => applyCategories(r.data),
    );
  }

  Future<void> fetchMenus({bool loadMore = false}) async {
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
    List<MenuModel> parsed = [];

    void applyMenus(dynamic raw) {
      if (raw == null) return;
      final data = raw is String ? json.decode(raw) : raw;
      final listData = (data['data'] as List?) ?? [];
      parsed = listData
          .whereType<Map<String, dynamic>>()
          .map(MenuModel.fromJson)
          .toList();
      if (loadMore) {
        menus.addAll(parsed);
      } else {
        menus.assignAll(parsed);
      }
      errorMessage.value = '';
    }

    final result = await menuService.getMenus(
      page: currentPage,
      perPage: perPage,
      onUpdate: applyMenus,
    );

    result.fold(
      (l) {
        errorMessage.value = ApiErrorMessage.from(
          l,
          fallback: 'Gagal memuat menu.',
        );
      },
      (r) => applyMenus(r.data),
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

  Future<void> createMenu(
    Map<String, dynamic> payload, {
    String? imagePath,
  }) async {
    if (actionLoading.value) return;
    actionLoading.value = true;
    try {
      final result = imagePath == null || imagePath.isEmpty
          ? await menuService.createMenu(payload)
          : await menuService.createMenuWithImage(
              payload: payload,
              filePath: imagePath,
            );
      result.fold(
        (l) {
          final message = ApiErrorMessage.from(
            l,
            fallback: 'Tidak bisa membuat menu.',
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
          fetchMenus();
        },
      );
    } finally {
      actionLoading.value = false;
    }
  }

  Future<void> updateMenu(
    int id,
    Map<String, dynamic> payload, {
    String? imagePath,
  }) async {
    if (actionLoading.value) return;
    actionLoading.value = true;
    try {
      final result = await menuService.updateMenu(id, payload);
      result.fold(
        (l) {
          final message = ApiErrorMessage.from(
            l,
            fallback: 'Tidak bisa mengubah menu.',
          );
          Get.snackbar(
            'Gagal',
            message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: MasterColor.danger,
            colorText: MasterColor.white,
          );
        },
        (r) async {
          if (imagePath != null && imagePath.isNotEmpty) {
            await _uploadMenuImage(id, imagePath);
          }
          fetchMenus();
        },
      );
    } finally {
      actionLoading.value = false;
    }
  }

  Future<void> deleteMenu(int id) async {
    if (deletingId.value == id) return;
    deletingId.value = id;
    try {
      final result = await menuService.deleteMenu(id);
      result.fold(
        (l) {
          final message = ApiErrorMessage.from(
            l,
            fallback: 'Tidak bisa menghapus menu.',
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
          fetchMenus();
        },
      );
    } finally {
      if (deletingId.value == id) {
        deletingId.value = null;
      }
    }
  }

  Future<void> _uploadMenuImage(int menuId, String imagePath) async {
    final result = await menuService.uploadMenuImage(
      id: menuId,
      filePath: imagePath,
    );

    result.fold(
      (l) {
        final message = ApiErrorMessage.from(
          l,
          fallback: 'Tidak bisa upload gambar menu.',
        );
        Get.snackbar(
          'Gagal',
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: MasterColor.danger,
          colorText: MasterColor.white,
        );
      },
      (r) {},
    );
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
