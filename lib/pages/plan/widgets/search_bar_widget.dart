import 'package:flutter/material.dart';
import 'package:explore_id/colors/color.dart';
import '../providers/search_suggestion_notifier.dart';

/// Unified Search Bar with Suggestions Dropdown - All in One Widget
/// Menyatukan searchbar dan suggestions dropdown dalam 1 widget yang smooth
class UnifiedSearchBarWidget extends StatefulWidget {
  final TextEditingController controller;
  final bool isSearching;
  final SearchSuggestionNotifier suggestionNotifier;
  final Function(String) onChanged;
  final Function(LocationSuggestion) onSuggestionSelected;
  final VoidCallback onAddPressed;

  const UnifiedSearchBarWidget({
    Key? key,
    required this.controller,
    required this.isSearching,
    required this.suggestionNotifier,
    required this.onChanged,
    required this.onSuggestionSelected,
    required this.onAddPressed,
  }) : super(key: key);

  @override
  State<UnifiedSearchBarWidget> createState() => _UnifiedSearchBarWidgetState();
}

class _UnifiedSearchBarWidgetState extends State<UnifiedSearchBarWidget>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  late AnimationController _dropdownAnimController;
  late Animation<double> _dropdownHeightAnimation;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();

    // Animation controller untuk smooth dropdown expand/collapse
    _dropdownAnimController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _dropdownHeightAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _dropdownAnimController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Listen to suggestions changes
    widget.suggestionNotifier.addListener(_onSuggestionsChanged);
  }

  void _onSuggestionsChanged() {
    if (widget.suggestionNotifier.hasSuggestions) {
      _dropdownAnimController.forward();
    } else {
      _dropdownAnimController.reverse();
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _dropdownAnimController.dispose();
    widget.suggestionNotifier.removeListener(_onSuggestionsChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 40,
      left: 16,
      right: 16,
      child: ListenableBuilder(
        listenable: widget.suggestionNotifier,
        builder: (context, _) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Search Bar
              _buildSearchBar(),

              // Animated Dropdown with Suggestions
              SizeTransition(
                sizeFactor: _dropdownHeightAnimation,
                axisAlignment: -1.0,
                child: _buildSuggestionsDropdown(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(32),
        topRight: Radius.circular(32),
        bottomLeft: Radius.circular(
          widget.suggestionNotifier.hasSuggestions ? 0 : 32,
        ),
        bottomRight: Radius.circular(
          widget.suggestionNotifier.hasSuggestions ? 0 : 32,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
            bottomLeft: Radius.circular(
              widget.suggestionNotifier.hasSuggestions ? 0 : 32,
            ),
            bottomRight: Radius.circular(
              widget.suggestionNotifier.hasSuggestions ? 0 : 32,
            ),
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 8),
            const Icon(Icons.search, color: tdcyan),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  hintText: "Cari lokasi (manual submit saja)",
                  border: InputBorder.none,
                  isDense: true,
                ),
                onChanged: (value) {
                  widget.onChanged(value);
                  widget.suggestionNotifier.searchLocations(value);
                },
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    _handleAddDestination();
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            if (widget.isSearching)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: tdcyan,
                  ),
                ),
              )
            else
              IconButton(
                icon: const Icon(Icons.add_circle, color: tdcyan),
                tooltip: 'Tambah destinasi',
                onPressed: _handleAddDestination,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionsDropdown() {
    if (!widget.suggestionNotifier.hasSuggestions) {
      return const SizedBox.shrink();
    }

    return Material(
      elevation: 4,
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(12),
        bottomRight: Radius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
          border: Border(
            left: BorderSide(color: tdcyan.withOpacity(0.2), width: 1),
            right: BorderSide(color: tdcyan.withOpacity(0.2), width: 1),
            bottom: BorderSide(color: tdcyan.withOpacity(0.2), width: 1),
          ),
        ),
        constraints: BoxConstraints(maxHeight: 300, minHeight: 0),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemCount: widget.suggestionNotifier.suggestions.length,
          itemBuilder: (context, index) {
            final suggestion = widget.suggestionNotifier.suggestions[index];
            return _buildSuggestionItem(suggestion, index);
          },
        ),
      ),
    );
  }

  Widget _buildSuggestionItem(LocationSuggestion suggestion, int index) {
    return InkWell(
      onTap: () {
        widget.controller.text = suggestion.name;
        widget.onSuggestionSelected(suggestion);
        widget.suggestionNotifier.clearSuggestions();
        _focusNode.unfocus();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border:
              index > 0
                  ? Border(top: BorderSide(color: Colors.grey.withOpacity(0.1)))
                  : null,
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 20,
              color: tdcyan.withOpacity(0.7),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    suggestion.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    suggestion.fullAddress,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleAddDestination() {
    if (widget.controller.text.trim().isNotEmpty) {
      widget.onAddPressed();
      widget.suggestionNotifier.clearSuggestions();
      _focusNode.unfocus();
    }
  }
}

/// Backward Compatibility - Old SearchBarWidget
class SearchBarWidget extends StatefulWidget {
  final TextEditingController controller;
  final bool isSearching;
  final SearchSuggestionNotifier suggestionNotifier;
  final Function(String) onChanged;
  final Function(LocationSuggestion) onSuggestionSelected;
  final VoidCallback onAddPressed;

  const SearchBarWidget({
    Key? key,
    required this.controller,
    required this.isSearching,
    required this.suggestionNotifier,
    required this.onChanged,
    required this.onSuggestionSelected,
    required this.onAddPressed,
  }) : super(key: key);

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late FocusNode _focusNode;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 40,
      left: 16,
      right: 16,
      child: CompositedTransformTarget(
        link: _layerLink,
        child: Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(32),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Row(
              children: [
                const SizedBox(width: 8),
                const Icon(Icons.search, color: tdcyan),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    textInputAction: TextInputAction.search,
                    decoration: const InputDecoration(
                      hintText: "Cari lokasi (manual submit saja)",
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    onChanged: (value) {
                      widget.onChanged(value);
                      widget.suggestionNotifier.searchLocations(value);
                    },
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        _handleAddDestination();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                if (widget.isSearching)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: tdcyan,
                      ),
                    ),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: tdcyan),
                    tooltip: 'Tambah destinasi',
                    onPressed: _handleAddDestination,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleAddDestination() {
    if (widget.controller.text.trim().isNotEmpty) {
      widget.onAddPressed();
      widget.suggestionNotifier.clearSuggestions();
      _focusNode.unfocus();
    }
  }
}

/// Dropdown widget untuk menampilkan suggestions (deprecated - gunakan UnifiedSearchBarWidget)
class SearchSuggestionsDropdown extends StatelessWidget {
  final SearchSuggestionNotifier notifier;
  final Function(LocationSuggestion) onSuggestionSelected;
  final TextEditingController controller;

  const SearchSuggestionsDropdown({
    Key? key,
    required this.notifier,
    required this.onSuggestionSelected,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: notifier,
      builder: (context, _) {
        if (!notifier.hasSuggestions && notifier.error == null) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: tdcyan.withOpacity(0.2), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: notifier.suggestions.length,
            itemBuilder: (context, index) {
              final suggestion = notifier.suggestions[index];
              return InkWell(
                onTap: () {
                  controller.text = suggestion.name;
                  onSuggestionSelected(suggestion);
                  notifier.clearSuggestions();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border:
                        index > 0
                            ? Border(
                              top: BorderSide(
                                color: Colors.grey.withOpacity(0.1),
                              ),
                            )
                            : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        suggestion.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        suggestion.fullAddress,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
