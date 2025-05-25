import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_cache.dart';
import 'performance_monitor.dart';

class ImageOptimizer {
  static const int _maxImageSize = 1024;
  static const int _thumbnailSize = 256;
  static const double _compressionQuality = 0.8;
  
  // Optimize image for display
  static ImageProvider optimizeImageProvider(
    String imagePath, {
    int? width,
    int? height,
    bool useCache = true,
  }) {
    final cacheKey = 'optimized_image_${imagePath}_${width}_$height';
    
    if (useCache) {
      final cached = AppCache.getMemoryCache<ImageProvider>(cacheKey);
      if (cached != null) {
        return cached;
      }
    }
    
    ImageProvider provider;
    
    if (imagePath.startsWith('http')) {
      // Network image
      provider = NetworkImage(imagePath);
    } else if (imagePath.startsWith('assets/')) {
      // Asset image
      provider = AssetImage(imagePath);
    } else {
      // File image
      provider = FileImage(File(imagePath));
    }
    
    // Apply resizing if dimensions specified
    if (width != null || height != null) {
      provider = ResizeImage(
        provider,
        width: width,
        height: height,
        allowUpscaling: false,
      );
    }
    
    if (useCache) {
      AppCache.setMemoryCache(cacheKey, provider);
    }
    
    return provider;
  }
  
  // Create thumbnail
  static Future<Uint8List?> createThumbnail(
    String imagePath, {
    int size = _thumbnailSize,
  }) async {
    PerformanceMonitor.startOperation('create_thumbnail');
    
    try {
      final cacheKey = 'thumbnail_${imagePath}_$size';
      
      // Check cache first
      final cached = await AppCache.getPersistentCache<String>(cacheKey);
      if (cached != null) {
        return Uint8List.fromList(cached.codeUnits);
      }
      
      // Load and resize image
      final imageProvider = optimizeImageProvider(imagePath, width: size, height: size);
      final imageStream = imageProvider.resolve(const ImageConfiguration());
      
      final completer = Completer<ui.Image>();
      late ImageStreamListener listener;
      
      listener = ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(info.image);
        imageStream.removeListener(listener);
      });
      
      imageStream.addListener(listener);
      final image = await completer.future;
      
      // Convert to bytes
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData?.buffer.asUint8List();
      
      if (bytes != null) {
        // Cache the thumbnail
        await AppCache.setPersistentCache(cacheKey, String.fromCharCodes(bytes));
      }
      
      return bytes;
    } catch (e) {
      debugPrint('Error creating thumbnail: $e');
      return null;
    } finally {
      PerformanceMonitor.endOperation('create_thumbnail');
    }
  }
  
  // Preload critical images
  static Future<void> preloadImages(BuildContext context, List<String> imagePaths) async {
    PerformanceMonitor.startOperation('preload_images');
    
    try {
      final futures = imagePaths.map((path) async {
        try {
          final provider = optimizeImageProvider(path);
          await precacheImage(provider, context);
        } catch (e) {
          debugPrint('Error preloading image $path: $e');
        }
      });
      
      await Future.wait(futures);
      debugPrint('✅ Preloaded ${imagePaths.length} images');
    } catch (e) {
      debugPrint('❌ Error preloading images: $e');
    } finally {
      PerformanceMonitor.endOperation('preload_images');
    }
  }
  
  // Clear image cache
  static void clearImageCache() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    debugPrint('🧹 Image cache cleared');
  }
  
  // Configure image cache
  static void configureImageCache({
    int? maximumSize,
    int? maximumSizeBytes,
  }) {
    final imageCache = PaintingBinding.instance.imageCache;
    
    if (maximumSize != null) {
      imageCache.maximumSize = maximumSize;
    }
    
    if (maximumSizeBytes != null) {
      imageCache.maximumSizeBytes = maximumSizeBytes;
    }
    
    debugPrint('📸 Image cache configured: ${imageCache.maximumSize} images, ${imageCache.maximumSizeBytes} bytes');
  }
  
  // Get image cache stats
  static Map<String, dynamic> getImageCacheStats() {
    final imageCache = PaintingBinding.instance.imageCache;
    
    return {
      'current_size': imageCache.currentSize,
      'maximum_size': imageCache.maximumSize,
      'current_size_bytes': imageCache.currentSizeBytes,
      'maximum_size_bytes': imageCache.maximumSizeBytes,
      'live_image_count': imageCache.liveImageCount,
      'pending_image_count': imageCache.pendingImageCount,
    };
  }
}

// Optimized image widget
class OptimizedImage extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool useCache;
  
  const OptimizedImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.useCache = true,
  });
  
  @override
  Widget build(BuildContext context) {
    final imageProvider = ImageOptimizer.optimizeImageProvider(
      imagePath,
      width: width?.toInt(),
      height: height?.toInt(),
      useCache: useCache,
    );
    
    return Image(
      image: imageProvider,
      width: width,
      height: height,
      fit: fit,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) {
          return child;
        }
        return placeholder ?? const CircularProgressIndicator();
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? const Icon(Icons.error);
      },
    );
  }
}
