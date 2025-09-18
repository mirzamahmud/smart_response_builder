import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:smart_response_builder/smart_response_builder.dart';

void main() {
  runApp(const MyApp());
}

/// Controller for demo API with pagination + offline handling
class ProductController extends GetxController {
  final products = <String>[].obs;
  final isLoading = false.obs;
  final error = RxnString();

  // Pagination state
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final paginationError = RxnString();

  // Connectivity state
  final isOffline = false.obs;

  final dio = Dio();
  int _page = 1;
  final int _limit = 10;

  @override
  void onInit() {
    super.onInit();
    fetchProducts(refresh: true);
  }

  /// Check Connectivity
  Future<bool> isConnected() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    try {
      if (connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi)) {
        return true;
      } else {
        return false;
      }
    } on SocketException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Fetch products with optional refresh
  Future<void> fetchProducts({bool refresh = false}) async {
    isOffline.value = false;

    if (!await isConnected()) {
      isOffline.value = true;
      isLoading.value = false;
      return;
    }

    if (refresh) {
      _page = 1;
      hasMore.value = true;
      products.clear();
      error.value = null;
    }

    if (products.isEmpty) {
      isLoading.value = true;
    }

    try {
      final response = await dio.get(
        "https://jsonplaceholder.typicode.com/posts",
        queryParameters: {"_page": _page, "_limit": _limit},
      );

      final List<dynamic> data = response.data;
      if (refresh) {
        products.assignAll(data.map((e) => e["title"] as String).toList());
      } else {
        products.addAll(data.map((e) => e["title"] as String));
      }

      // Pagination control
      if (data.length < _limit) {
        hasMore.value = false;
      } else {
        _page++;
      }
    } catch (e) {
      if (products.isEmpty) {
        error.value = e.toString();
      } else {
        paginationError.value = e.toString();
      }
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  /// Load more data when scroll hits bottom
  Future<void> loadMore() async {
    if (!hasMore.value || isLoadingMore.value) return;
    isLoadingMore.value = true;
    await fetchProducts();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "Respo Builder Demo",
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          centerTitle: true,
          title: const Text("Example"),
        ),
        body: GetX<ProductController>(
          init: ProductController(),
          builder: (controller) {
            return ResponseBuilder<List<String>>(
              data: controller.products,
              isLoading: controller.isLoading.value,
              errorMsg: controller.error.value,
              // pagination
              isLoadingMore: controller.isLoadingMore.value,
              hasMore: controller.hasMore.value,
              paginationError: controller.paginationError.value,
              // connectivity
              isOffline: controller.isOffline.value,
              onRetry: () => controller.fetchProducts(refresh: true),
              dataWidgetBuilder: (context, data) {
                return NotificationListener<ScrollNotification>(
                  onNotification: (scroll) {
                    if (scroll.metrics.pixels >=
                            scroll.metrics.maxScrollExtent - 200 &&
                        !controller.isLoadingMore.value) {
                      controller.loadMore();
                    }
                    return false;
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: data.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder:
                        (context, index) => ListTile(title: Text(data[index])),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
