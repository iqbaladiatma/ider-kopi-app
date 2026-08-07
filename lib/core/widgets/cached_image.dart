import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Cached network image dengan placeholder & error handling.
///
/// Pakai `CachedNetworkImage` untuk caching otomatis.
/// Untuk Directus, file URL = `${AppConfig.apiBaseUrl}/assets/$fileId`.
class CachedImage extends StatelessWidget {
  final String? fileId;
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const CachedImage({
    super.key,
    this.fileId,
    this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  String get _imageUrl => url ?? '';

  @override
  Widget build(BuildContext context) {
    if (_imageUrl.isEmpty) {
      return _placeholder();
    }

    final image = CachedNetworkImage(
      imageUrl: _imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, __) => _loading(),
      errorWidget: (_, __, ___) => _placeholder(),
      memCacheWidth: 512, // Limit memory cache
    );

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }
    return image;
  }

  Widget _placeholder() => Container(
        width: width,
        height: height,
        color: AppColors.ink.withValues(alpha: 0.05),
        child: Icon(Icons.image_outlined,
            color: AppColors.ink.withValues(alpha: 0.3), size: 32),
      );

  Widget _loading() => Container(
        width: width,
        height: height,
        color: AppColors.ink.withValues(alpha: 0.05),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.red,
            ),
          ),
        ),
      );
}
