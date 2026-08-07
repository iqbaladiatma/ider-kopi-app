import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State untuk paginated list.
class PaginationState<T> {
  final List<T> items;
  final bool isLoading;
  final bool hasMore;
  final int page;
  final int pageSize;
  final Object? error;

  const PaginationState({
    this.items = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.page = 0,
    this.pageSize = 20,
    this.error,
  });

  PaginationState<T> copyWith({
    List<T>? items,
    bool? isLoading,
    bool? hasMore,
    int? page,
    int? pageSize,
    Object? error,
  }) {
    return PaginationState<T>(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      error: error,
    );
  }
}

/// StateNotifier untuk paginated list dengan lazy loading.
///
/// Usage:
/// ```dart
/// final historyPaginator = PaginatedNotifier<AttendanceRecord>(
///   fetchPage: (page, size) => repo.getHistory(userId, offset: page * size, limit: size),
/// );
/// ```
class PaginatedNotifier<T> extends StateNotifier<PaginationState<T>> {
  final Future<List<T>> Function(int page, int pageSize) fetchPage;

  PaginatedNotifier({
    required this.fetchPage,
    int pageSize = 20,
  }) : super(PaginationState<T>(pageSize: pageSize));

  /// Load first page (reset).
  Future<void> refresh() async {
    state = PaginationState<T>(pageSize: state.pageSize);
    await loadMore();
  }

  /// Load next page if available & not loading.
  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final nextPage = state.page + 1;
      final items = await fetchPage(nextPage, state.pageSize);

      if (!mounted) return;

      state = state.copyWith(
        items: [...state.items, ...items],
        page: nextPage,
        isLoading: false,
        hasMore: items.length == state.pageSize,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('PaginatedNotifier.loadMore error: $e');
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: e);
    }
  }
}

/// Helper untuk detect scroll near bottom (trigger load more).
bool shouldLoadMore(ScrollNotification scroll, {double threshold = 200}) {
  return scroll.metrics.pixels >= scroll.metrics.maxScrollExtent - threshold;
}
