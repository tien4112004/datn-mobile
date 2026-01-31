import 'package:AIPrimary/features/setting/widget/setting_category/setting_option.dart';
import 'package:flutter/material.dart';

class SettingSection extends StatelessWidget {
  const SettingSection({super.key, required this.title, required this.options});

  final String title;
  final List<SettingOption> options;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SizedBox(
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          title: Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
            ),
          ),
          subtitle: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).secondaryHeaderColor.withAlpha(50),
              borderRadius: const BorderRadius.all(Radius.circular(24)),
            ),
            child: Column(
              children: options.asMap().entries.map((entry) {
                int index = entry.key;
                SettingOption option = entry.value;
                return Column(
                  children: [
                    if (index != 0)
                      const Divider(height: 1, indent: 16, endIndent: 16),
                    option,
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
