import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:slims/core/constants/colors.dart';
import 'package:slims/core/utils/api_error.dart';
import 'package:slims/core/utils/secure_storage.dart';
import 'package:slims/infrastructure/data/restApi/restoku/model/category.model.dart';
import 'package:slims/infrastructure/data/restApi/restoku/service/category.service.dart';

class SellerCategoryController extends GetxController {
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

  late final CategoryService categoryService;

  @override
  void onInit() {
    super.onInit();
    final baseUrl = SecureStorageHelper.generateBaseUrl();
    categoryService = CategoryService(baseUrl: baseUrl);
    fetchCategories();

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        fetchCategories(loadMore: true);
      }
    });
  }

  Future<void> fetchCategories({bool loadMore = false}) async {
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
    List<CategoryModel> parsed = [];

    void applyCategories(dynamic raw) {
      if (raw == null) return;
      final data = raw is String ? json.decode(raw) : raw;
      final listData = (data['data'] as List?) ?? [];
      parsed = listData
          .whereType<Map<String, dynamic>>()
          .map(CategoryModel.fromJson)
          .toList();
      if (loadMore) {
        categories.addAll(parsed);
      } else {
        categories.assignAll(parsed);
      }
      errorMessage.value = '';
    }

    final result = await categoryService.getCategories(
      page: currentPage,
      perPage: perPage,
      onUpdate: applyCategories,
    );

    result.fold(
      (l) {
        errorMessage.value = ApiErrorMessage.from(
          l,
          fallback: 'Gagal memuat kategori.',
        );
      },
      (r) => applyCategories(r.data),
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

  Future<void> createCategory(
    Map<String, dynamic> payload, {
    String? imagePath,
  }) async {
    if (actionLoading.value) return;
    actionLoading.value = true;
    try {
      final result = imagePath == null
          ? await categoryService.createCategory(payload)
          : await categoryService.createCategoryWithImage(
              payload: payload,
              filePath: imagePath,
            );
      result.fold(
        (l) {
          final message = ApiErrorMessage.from(
            l,
            fallback: 'Tidak bisa membuat kategori.',
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
          fetchCategories();
        },
      );
    } finally {
      actionLoading.value = false;
    }
  }

  Future<void> updateCategory(
    int id,
    Map<String, dynamic> payload, {
    String? imagePath,
  }) async {
    if (actionLoading.value) return;
    actionLoading.value = true;
    try {
      final result = await categoryService.updateCategory(id, payload);
      await result.fold(
        (l) async {
          final message = ApiErrorMessage.from(
            l,
            fallback: 'Tidak bisa mengubah kategori.',
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
          if (imagePath != null) {
            final upload = await categoryService.uploadCategoryImage(
              id: id,
              filePath: imagePath,
            );
            upload.fold(
              (l) {
                final message = ApiErrorMessage.from(
                  l,
                  fallback: 'Tidak bisa mengunggah gambar kategori.',
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
          fetchCategories();
        },
      );
    } finally {
      actionLoading.value = false;
    }
  }

  Future<void> deleteCategory(int id) async {
    if (deletingId.value == id) return;
    deletingId.value = id;
    try {
      final result = await categoryService.deleteCategory(id);
      result.fold(
        (l) {
          final message = ApiErrorMessage.from(
            l,
            fallback: 'Tidak bisa menghapus kategori.',
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
          fetchCategories();
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
