import 'package:AIPrimary/shared/widgets/custom_search_bar.dart';
import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  final String hintText;
  final VoidCallback onTap;

  const SearchField({super.key, required this.hintText, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: CustomSearchBar(
        enabled: false,
        autoFocus: false,
        hintText: hintText,
        onTap: () {},
      ),
    );
  }
}
