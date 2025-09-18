import 'package:flutter/material.dart';

class ResponseBuilder<T> extends StatelessWidget {
  /// A smart widget to handle multiple response states in one place:
  /// - Loading
  /// - Error
  /// - Empty
  /// - Success (data)
  /// - Pagination (loading more, no more data, pagination error)
  /// - Offline (no internet)
  ///
  /// Example:
  /// ```dart
  /// ResponseBuilder<List<Product>>(
  ///   data: controller.products.value,
  ///   isLoading: controller.isLoading.value,
  ///   error: controller.error.value,
  ///   isOffline: controller.isOffline.value,
  ///   onRetry: controller.fetchProducts,
  ///   dataBuilder: (context, products) => ListView.builder(
  ///     itemCount: products.length,
  ///     itemBuilder: (_, i) => ListTile(title: Text(products[i].title)),
  ///   ),
  /// )
  /// ```
  const ResponseBuilder({
    super.key,
    this.data,
    this.hasMore = true,
    this.isOffline = false,
    this.isLoading = false,
    this.errorMsg,
    this.isLoadingMore = false,
    this.paginationError,
    this.onRetry,

    this.emptyWidgetBuilder,
    this.loadingWidgetBuilder,
    this.offlineWidgetBuilder,
    this.noMoreDataWidgetBuilder,
    this.loadingMoreDataWidgetBuilder,

    this.dataWidgetBuilder,
    this.errorWidgetBuilder,
    this.paginationErrorWidgetBuilder,
  });

  /// The response data of type [T].
  /// Example: `List<Product>`, `User`, etc.
  /// If not `null` and not empty, [dataWidgetBuilder] will be called.
  final T? data;

  /// Whether more data is available to load.
  /// If `false`, shows [noMoreDataWidgetBuilder] or a default "No more data" text.
  final bool hasMore;

  /// Whether the device is currently offline.
  /// Shows [offlineWidgetBuilder] or a default "No internet connection" widget.
  final bool isOffline;

  /// Whether the initial request is loading.
  /// Shows [loadingWidgetBuilder] or a default [CircularProgressIndicator].
  final bool isLoading;

  /// Error message to display when a request fails.
  /// Shows [errorWidgetBuilder] or a default error widget with retry option.
  final String? errorMsg;

  /// Whether the next page of data is currently loading.
  /// Typically used to show a bottom loader in lists.
  final bool isLoadingMore;

  /// Error message for pagination requests (load more).
  /// Shows [paginationErrorWidgetBuilder] or a default inline error text.
  final String? paginationError;

  /// Callback for retrying a failed or offline request.
  /// Shown as a Retry button in error/offline state.
  final void Function()? onRetry;

  /// Builder for empty state (when [data] is empty or null).
  /// If `null`, shows a default "No data available".
  final WidgetBuilder? emptyWidgetBuilder;

  /// Custom builder for the initial loading state.
  /// If `null`, defaults to a [CircularProgressIndicator].
  final WidgetBuilder? loadingWidgetBuilder;

  /// Builder for offline state (no internet).
  /// If `null`, shows a default Wi-Fi-off icon + Retry button.
  final WidgetBuilder? offlineWidgetBuilder;

  /// Builder for "No more data" state when [hasMore] is false.
  /// If `null`, shows a default "No more data" text.
  final WidgetBuilder? noMoreDataWidgetBuilder;

  /// Builder for pagination loader (appears at the bottom of list).
  /// If `null`, shows a default [CircularProgressIndicator].
  final WidgetBuilder? loadingMoreDataWidgetBuilder;

  /// Builder for rendering the actual [data].
  /// This is typically where you build your list or detail UI.
  final Widget Function(BuildContext, T)? dataWidgetBuilder;

  /// Custom builder for rendering errors.
  /// Receives the error [String] message.
  final Widget Function(BuildContext, String)? errorWidgetBuilder;

  /// Builder for pagination error.
  /// Receives the error [String] message.
  final Widget Function(BuildContext, String)? paginationErrorWidgetBuilder;

  /// Checks if the [data] is empty.
  /// Supports `Iterable` and `Map` types.
  bool isEmptyData() {
    if (data == null) return true;
    if (data is Iterable && (data as Iterable).isEmpty) return true;
    if (data is Map && (data as Map).isEmpty) return true;

    return false;
  }

  @override
  Widget build(BuildContext context) {
    // Loading state
    if (isLoading) {
      return loadingWidgetBuilder?.call(context) ??
          Center(child: CircularProgressIndicator());
    }

    // Offline state
    if (isOffline) {
      return offlineWidgetBuilder?.call(context) ??
          Center(
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  const Text("No internet connection"),
                  const SizedBox(height: 12),
                  if (onRetry != null)
                    ElevatedButton(
                      onPressed: onRetry,
                      child: const Text("Retry"),
                    ),
                ],
              ),
            ),
          );
    }

    // Error state
    if (errorMsg != null) {
      return errorWidgetBuilder?.call(context, errorMsg!) ??
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(errorMsg!, style: const TextStyle(color: Colors.red)),
                if (onRetry != null)
                  ElevatedButton(
                    onPressed: onRetry,
                    child: const Text("Retry"),
                  ),
              ],
            ),
          );
    }

    // Empty state
    if (isEmptyData()) {
      return emptyWidgetBuilder?.call(context) ??
          const Center(child: Text("No data available"));
    }

    // Data state + pagination
    if (dataWidgetBuilder != null) {
      final widget = dataWidgetBuilder!(context, data as T);
      return Column(
        children: [
          Expanded(child: widget),

          // Loading more (pagination)
          if (isLoadingMore)
            loadingMoreDataWidgetBuilder?.call(context) ??
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(),
                ),

          // Pagination error
          if (paginationError != null)
            paginationErrorWidgetBuilder?.call(context, paginationError!) ??
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    paginationError!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

          // No more data
          if (!hasMore && !isLoadingMore && paginationError == null)
            noMoreDataWidgetBuilder?.call(context) ??
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    "No more data",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
        ],
      );
    }

    // Fallback: return empty widget
    return const SizedBox.shrink();
  }
}
