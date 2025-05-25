import 'package:flutter/material.dart';
import 'performance_monitor.dart';

class LazyLoader {
  static final Map<String, dynamic> _loadedData = {};
  static final Map<String, Future<dynamic>> _loadingFutures = {};
  
  // Lazy load data with caching
  static Future<T> loadData<T>(
    String key,
    Future<T> Function() loader, {
    Duration? cacheExpiry,
    bool forceReload = false,
  }) async {
    // Check if already loaded and not expired
    if (!forceReload && _loadedData.containsKey(key)) {
      final cached = _loadedData[key];
      if (cached is _CachedData<T>) {
        if (cacheExpiry == null || !cached.isExpired(cacheExpiry)) {
          return cached.data;
        }
      }
    }
    
    // Check if already loading
    if (_loadingFutures.containsKey(key)) {
      return await _loadingFutures[key] as T;
    }
    
    // Start loading
    PerformanceMonitor.startOperation('lazy_load_$key');
    
    final future = loader().then((data) {
      _loadedData[key] = _CachedData<T>(data, DateTime.now());
      _loadingFutures.remove(key);
      PerformanceMonitor.endOperation('lazy_load_$key');
      return data;
    }).catchError((error) {
      _loadingFutures.remove(key);
      PerformanceMonitor.endOperation('lazy_load_$key');
      throw error;
    });
    
    _loadingFutures[key] = future;
    return await future;
  }
  
  // Clear cached data
  static void clearCache([String? key]) {
    if (key != null) {
      _loadedData.remove(key);
      _loadingFutures.remove(key);
    } else {
      _loadedData.clear();
      _loadingFutures.clear();
    }
  }
  
  // Check if data is loaded
  static bool isLoaded(String key) {
    return _loadedData.containsKey(key);
  }
  
  // Check if data is loading
  static bool isLoading(String key) {
    return _loadingFutures.containsKey(key);
  }
  
  // Get cache stats
  static Map<String, dynamic> getStats() {
    return {
      'loaded_items': _loadedData.length,
      'loading_items': _loadingFutures.length,
      'total_items': _loadedData.length + _loadingFutures.length,
    };
  }
}

class _CachedData<T> {
  final T data;
  final DateTime loadedAt;
  
  _CachedData(this.data, this.loadedAt);
  
  bool isExpired(Duration expiry) {
    return DateTime.now().difference(loadedAt) > expiry;
  }
}

// Lazy loading widget
class LazyLoadingWidget<T> extends StatefulWidget {
  final String cacheKey;
  final Future<T> Function() loader;
  final Widget Function(BuildContext context, T data) builder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context, Object error)? errorBuilder;
  final Duration? cacheExpiry;
  final bool autoLoad;
  
  const LazyLoadingWidget({
    super.key,
    required this.cacheKey,
    required this.loader,
    required this.builder,
    this.loadingBuilder,
    this.errorBuilder,
    this.cacheExpiry,
    this.autoLoad = true,
  });
  
  @override
  State<LazyLoadingWidget<T>> createState() => _LazyLoadingWidgetState<T>();
}

class _LazyLoadingWidgetState<T> extends State<LazyLoadingWidget<T>> {
  late Future<T> _future;
  
  @override
  void initState() {
    super.initState();
    if (widget.autoLoad) {
      _loadData();
    }
  }
  
  void _loadData() {
    _future = LazyLoader.loadData<T>(
      widget.cacheKey,
      widget.loader,
      cacheExpiry: widget.cacheExpiry,
    );
  }
  
  void reload() {
    setState(() {
      _future = LazyLoader.loadData<T>(
        widget.cacheKey,
        widget.loader,
        cacheExpiry: widget.cacheExpiry,
        forceReload: true,
      );
    });
  }
  
  @override
  Widget build(BuildContext context) {
    if (!widget.autoLoad && !LazyLoader.isLoaded(widget.cacheKey) && !LazyLoader.isLoading(widget.cacheKey)) {
      return ElevatedButton(
        onPressed: () {
          setState(() {
            _loadData();
          });
        },
        child: const Text('Load Data'),
      );
    }
    
    return FutureBuilder<T>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return widget.errorBuilder?.call(context, snapshot.error!) ??
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(height: 8),
                    Text('Error: ${snapshot.error}'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: reload,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
        }
        
        if (snapshot.hasData) {
          return widget.builder(context, snapshot.data!);
        }
        
        return widget.loadingBuilder?.call(context) ??
            const Center(child: CircularProgressIndicator());
      },
    );
  }
}

// Lazy list view for large datasets
class LazyListView<T> extends StatefulWidget {
  final Future<List<T>> Function(int page, int pageSize) loader;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final int pageSize;
  final Widget? loadingWidget;
  final Widget? emptyWidget;
  final ScrollController? controller;
  
  const LazyListView({
    super.key,
    required this.loader,
    required this.itemBuilder,
    this.pageSize = 20,
    this.loadingWidget,
    this.emptyWidget,
    this.controller,
  });
  
  @override
  State<LazyListView<T>> createState() => _LazyListViewState<T>();
}

class _LazyListViewState<T> extends State<LazyListView<T>> {
  final List<T> _items = [];
  late ScrollController _scrollController;
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;
  
  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_onScroll);
    _loadNextPage();
  }
  
  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }
  
  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadNextPage();
    }
  }
  
  Future<void> _loadNextPage() async {
    if (_isLoading || !_hasMore) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final newItems = await widget.loader(_currentPage, widget.pageSize);
      
      setState(() {
        _items.addAll(newItems);
        _currentPage++;
        _hasMore = newItems.length == widget.pageSize;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error loading page $_currentPage: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty && _isLoading) {
      return widget.loadingWidget ?? const Center(child: CircularProgressIndicator());
    }
    
    if (_items.isEmpty && !_isLoading) {
      return widget.emptyWidget ?? const Center(child: Text('No items found'));
    }
    
    return ListView.builder(
      controller: _scrollController,
      itemCount: _items.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < _items.length) {
          return widget.itemBuilder(context, _items[index], index);
        } else {
          return widget.loadingWidget ?? 
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              );
        }
      },
    );
  }
}
