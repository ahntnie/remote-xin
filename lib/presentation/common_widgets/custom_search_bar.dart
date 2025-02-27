import 'package:flutter/material.dart';

import '../../core/all.dart';
import '../resource/resource.dart';
import 'app_icon.dart';
import 'text_field.dart';

class CustomSearchBar extends StatefulWidget {
  const CustomSearchBar({
    this.searchController,
    this.searchFocusNode,
    this.height = 44,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.hintText,
    this.onChanged,
    this.autofocus = true,
    this.onClear,
    this.prefixIcon,
    this.suffixIcon,
    this.textInputAction,
    this.onSubmit,
    super.key,
  });

  final TextEditingController? searchController;
  final FocusNode? searchFocusNode;
  final double height;
  final EdgeInsets padding;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final bool autofocus;
  final VoidCallback? onClear;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmit;

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  final ValueNotifier<String> _textNotifier = ValueNotifier<String>('');
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = widget.searchController ?? TextEditingController();
    _searchController.addListener(() {
      _textNotifier.value = _searchController.text;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onClear() {
    _searchController.clear();
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: AppTextField(
        controller: _searchController,
        focusNode: widget.searchFocusNode,
        hintText: widget.hintText,
        hintStyle: AppTextStyles.s16w400.subText2Color,
        onChanged: widget.onChanged,
        autofocus: widget.autofocus,
        prefixIcon: _buildPrefix(context),
        suffixIcon: widget.suffixIcon ?? _buildSuffixIcon(context),
        contentPadding: widget.padding,
        fillColor: AppColors.grey6,
        borderRadius: 100,
        textInputAction: widget.textInputAction,
        onFieldSubmitted: widget.onSubmit,
        border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(100)),
      ),
    );
  }

  Widget _buildPrefix(BuildContext context) {
    if (widget.prefixIcon != null) {
      return widget.prefixIcon!;
    }

    return AppIcon(
      icon: AppIcons.search,
      color: AppColors.subText2,
    );
  }

  Widget? _buildSuffixIcon(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _textNotifier,
      builder: (_, text, __) {
        return widget.onClear != null && text.isNotEmpty
            ? _buildClearButton(context)
            : const SizedBox.shrink();
      },
    );
  }

  Widget _buildClearButton(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppIcon(
          icon: AppIcons.close,
          color: AppColors.subText2,
          onTap: _onClear,
        ),
      ],
    );
  }
}
