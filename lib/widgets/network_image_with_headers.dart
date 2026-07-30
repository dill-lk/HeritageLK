import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../theme/heritage_colors.dart';

/// A cached network image widget that stores images on disk so Android
/// doesn't re-download them on every rebuild / screen visit.
///
/// Uses [CachedNetworkImage] which provides both memory cache and a
/// persistent disk cache via the `flutter_cache_manager` package.
class HNetworkImage extends StatelessWidget {
  const HNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorWidget,
    this.loadingColor = HeritageColors.orange,
    this.borderRadius,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? errorWidget;
  final Color loadingColor;
  final BorderRadius? borderRadius;

  static const Map<String, String> _headers = {
    'User-Agent': 'HeritageLK/1.0 (Flutter; Android)',
    'Accept': 'image/webp,image/png,image/*,*/*;q=0.8',
  };

  @override
  Widget build(BuildContext context) {
    Widget image = CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      httpHeaders: _headers,
      // Memory cache: keep up to 200 images × 200 MB
      memCacheWidth: width != null ? (width! * 2).toInt() : null,
      placeholder: (context, url) => _placeholder(
        child: CircularProgressIndicator(
          color: loadingColor,
          strokeWidth: 2,
        ),
      ),
      errorWidget: (context, url, error) =>
          errorWidget ??
          _placeholder(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.broken_image_outlined,
                    color: loadingColor.withValues(alpha: 0.6), size: 32),
                const SizedBox(height: 6),
                Text(
                  'Image unavailable',
                  style: TextStyle(
                    color: HeritageColors.cream.withValues(alpha: 0.5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
    );

    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius!, child: image);
    }

    return image;
  }

  Widget _placeholder({required Widget child}) => SizedBox(
        width: width,
        height: height,
        child: Container(
          color: const Color(0xFF2A221C),
          child: Center(child: child),
        ),
      );
}
