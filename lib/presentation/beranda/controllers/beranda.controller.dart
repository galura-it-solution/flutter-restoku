import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:slims/core/utils/api_error.dart';
import 'package:slims/core/utils/secure_storage.dart';
import 'package:slims/infrastructure/data/restApi/restoku/model/category.model.dart';
import 'package:slims/infrastructure/data/restApi/restoku/model/menu.model.dart';
import 'package:slims/infrastructure/data/restApi/restoku/service/category.service.dart';
import 'package:slims/infrastructure/data/restApi/restoku/service/menu.service.dart';

class BerandaController extends GetxController {
  final scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();

  final categories = <CategoryModel>[].obs;
  final menus = <MenuModel>[].obs;
  final selectedCategoryId = Rxn<int>();

  final limit = 10;
  final search = ''.obs;
  final hasMore = true.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final page = 1.obs;
  Timer? _searchDebounce;

  late final CategoryService categoryService;
  late final MenuService menuService;

  @override
  void onInit() {
    super.onInit();
    final baseUrl = SecureStorageHelper.generateBaseUrl();
    categoryService = CategoryService(baseUrl: baseUrl);
    menuService = MenuService(baseUrl: baseUrl);

    fetchCategories();
    fetchMenus(loadMore: false);

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 250) {
        if (hasMore.value) {
          fetchMenus(loadMore: true);
        }
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
      perPage: 50,
      onUpdate: applyCategories,
    );

    result.fold(
      (l) => Logger().e(l),
      (r) => applyCategories(r.data),
    );
  }

  Future<void> fetchMenus({bool loadMore = false}) async {
    if (isLoading.value || (!hasMore.value && loadMore)) return;

    try {
      isLoading.value = true;
      final int currentPage = loadMore ? page.value + 1 : 1;

      void applyMenus(dynamic raw) {
        if (raw == null) return;
        final data = raw is String ? json.decode(raw) : raw;
        final listData = (data['data'] as List?) ?? [];
        final parsed = listData
            .whereType<Map<String, dynamic>>()
            .map(MenuModel.fromJson)
            .toList();

        errorMessage.value = '';
        if (loadMore) {
          final startIndex = (currentPage - 1) * limit;
          final nextMenus = List<MenuModel>.from(menus);
          if (startIndex <= nextMenus.length) {
            final replaceEnd =
                min(startIndex + parsed.length, nextMenus.length);
            nextMenus.replaceRange(startIndex, replaceEnd, parsed);
            if (startIndex + parsed.length > nextMenus.length) {
              nextMenus.addAll(parsed.sublist(replaceEnd - startIndex));
            }
            menus.assignAll(nextMenus);
          } else {
            menus.addAll(parsed);
          }
        } else {
          menus.assignAll(parsed);
        }

        if (parsed.isNotEmpty) {
          page.value = currentPage;
        }

        hasMore.value = parsed.length == limit;
      }

      final result = await menuService.getMenus(
        page: currentPage,
        perPage: limit,
        categoryId: selectedCategoryId.value,
        search: search.value,
        onUpdate: applyMenus,
      );

      result.fold(
        (l) {
          errorMessage.value = ApiErrorMessage.from(
            l,
            fallback: 'Gagal memuat menu.',
          );
          Logger().e(l);
        },
        (r) => applyMenus(r.data),
      );
    } catch (e, st) {
      errorMessage.value = ApiErrorMessage.from(
        e,
        fallback: 'Gagal memuat menu.',
      );
      Logger().e(e, stackTrace: st);
    } finally {
      isLoading.value = false;
    }
  }

  void applyCategory(int? categoryId) {
    selectedCategoryId.value = categoryId;
    page.value = 1;
    hasMore.value = true;
    fetchMenus(loadMore: false);
  }

  void searchMenus(String keyword) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      search.value = keyword;
      page.value = 1;
      hasMore.value = true;
      fetchMenus(loadMore: false);
    });
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    scrollController.dispose();
    searchController.dispose();
    super.onClose();
  }
}
