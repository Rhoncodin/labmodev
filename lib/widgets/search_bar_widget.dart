import 'dart:async';

import 'package:flutter/material.dart';

import '../models/weather_model.dart';
import 'glass_panel.dart';

class SearchBarWidget extends StatefulWidget {
  final Future<List<LocationData>> Function(String query) onSearch;
  final Future<void> Function(LocationData location) onLocationSelected;

  const SearchBarWidget({
    super.key,
    required this.onSearch,
    required this.onLocationSelected,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  Timer? _debounce;
  Future<List<LocationData>>? _searchFuture;
  String _query = '';
  bool _showResults = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      final query = value.trim();
      if (!mounted) {
        return;
      }

      setState(() {
        _query = value;
      });

      setState(() {
        _query = query;
        _showResults = query.isNotEmpty;
        _searchFuture = query.isEmpty ? null : widget.onSearch(query);
      });
    });
  }

  Future<void> _selectLocation(LocationData location) async {
    _controller.clear();
    _focusNode.unfocus();
      setState(() {
        _query = '';
        _showResults = false;
        _searchFuture = null;
      });
    await widget.onLocationSelected(location);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GlassPanel(
          borderRadius: BorderRadius.circular(12),
          backgroundAlpha: 0.2,
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            onChanged: _onChanged,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search city...',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.white.withValues(alpha: 0.7),
                size: 20,
              ),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: Colors.white.withValues(alpha: 0.7),
                        size: 18,
                      ),
                      onPressed: () {
                        _controller.clear();
                        setState(() {
                          _query = '';
                          _showResults = false;
                          _searchFuture = null;
                        });
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        if (_showResults && _searchFuture != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: FutureBuilder<List<LocationData>>(
              future: _searchFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _SearchResultsPanel(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.blueGrey.withValues(alpha: 0.8),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Searching for matching cities...',
                              style: TextStyle(fontSize: 13, color: Color(0xFF334155)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return _SearchResultsPanel(
                    child: _SearchMessage(
                      icon: Icons.travel_explore_rounded,
                      message: '${snapshot.error}',
                    ),
                  );
                }

                final results = snapshot.data ?? <LocationData>[];
                if (results.isEmpty) {
                  return const _SearchResultsPanel(
                    child: _SearchMessage(
                      icon: Icons.location_searching_rounded,
                      message: 'No matching cities found yet. Try a broader keyword.',
                    ),
                  );
                }

                return _SearchResultsPanel(
                  child: Column(
                    children: results
                        .map(
                          (location) => InkWell(
                            onTap: () => _selectLocation(location),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color: Colors.blue,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          location.cityName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          location.country,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _SearchResultsPanel extends StatelessWidget {
  final Widget child;

  const _SearchResultsPanel({required this.child});

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      backgroundAlpha: 0.95,
      borderRadius: BorderRadius.circular(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: child,
      ),
    );
  }
}

class _SearchMessage extends StatelessWidget {
  final IconData icon;
  final String message;

  const _SearchMessage({
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2563EB), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFF475569),
                fontSize: 13,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
