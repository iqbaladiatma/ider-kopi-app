import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../shared/widgets/empty_view.dart';
import '../../shared/widgets/error_view.dart';

/// Helper widget untuk render Riverpod [AsyncValue] secara konsisten.
///
/// Otomatis handle:
/// - loading → CircularProgressIndicator
/// - error → ErrorView dengan retry
/// - data → child(data) atau EmptyView jika null/empty
class AsyncValueWidget<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final Widget? loading;
  final String? errorTitle;
  final VoidCallback? onRetry;
  final T? emptyValue;
  final Widget? emptyWidget;

  const AsyncValueWidget({
    super.key,
    required this.value,
    required this.data,
    this.loading,
    this.errorTitle,
    this.onRetry,
    this.emptyValue,
    this.emptyWidget,
  });

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: (d) {
        if (d == null || d == emptyValue) {
          return emptyWidget ?? const EmptyView(title: 'Tidak ada data');
        }
        if (d is List && d.isEmpty) {
          return emptyWidget ?? const EmptyView(title: 'Tidak ada data');
        }
        return data(d);
      },
      loading: () =>
          loading ??
          const Center(
            child: CircularProgressIndicator(
              color: AppColors.red,
              strokeWidth: 2,
            ),
          ),
      error: (e, _) => ErrorView(
        message: _formatError(e),
        title: errorTitle ?? 'Terjadi Kesalahan',
        onRetry: onRetry,
      ),
    );
  }

  String _formatError(Object e) {
    final s = e.toString();
    // Strip "Exception: " prefix
    if (s.startsWith('Exception: ')) return s.substring(11);
    return s;
  }
}

/// Helper untuk ListView dengan AsyncValue<List<T>>.
class AsyncListWidget<T> extends StatelessWidget {
  final AsyncValue<List<T>> value;
  final Widget Function(T item, int index) itemBuilder;
  final Widget Function(T item)? separatorBuilder;
  final EdgeInsets? padding;
  final String? emptyMessage;
  final IconData? emptyIcon;
  final VoidCallback? onRetry;

  const AsyncListWidget({
    super.key,
    required this.value,
    required this.itemBuilder,
    this.separatorBuilder,
    this.padding,
    this.emptyMessage,
    this.emptyIcon,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return AsyncValueWidget<List<T>>(
      value: value,
      onRetry: onRetry,
      emptyWidget: EmptyView(
        title: emptyMessage ?? 'Tidak ada data',
        icon: emptyIcon ?? Icons.inbox_outlined,
      ),
      data: (items) => ListView.separated(
        padding: padding ?? const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, i) => separatorBuilder != null
            ? separatorBuilder!(items[i])
            : const SizedBox(height: 12),
        itemBuilder: (_, i) => itemBuilder(items[i], i),
      ),
    );
  }
}
