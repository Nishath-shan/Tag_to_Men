import 'package:flutter/material.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

extension AppColors on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  
  Color get bgColor => isDark ? const Color(0xFF121212) : const Color(0xFFF8FBFF);
  Color get textColor => isDark ? Colors.white : const Color(0xFF101828);
  Color get cardColor => isDark ? const Color(0xFF1E1E1E) : Colors.white;
  Color get subTextColor => isDark ? const Color(0xFFAAAAAA) : const Color(0xFF667085);
  Color get highlightBgColor => isDark ? const Color(0xFF2C2C2C) : const Color(0xFFEAF3FF);
  Color get secondaryBgColor => isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF4FF);
  Color get borderColor => isDark ? const Color(0xFF333333) : const Color(0xFFEAECF0);
  Color get iconColor => isDark ? const Color(0xFFCCCCCC) : const Color(0xFF344054);
  Color get primaryColor => const Color(0xFF1450F0);
  Color get inputFillColor => isDark ? const Color(0xFF2C2C2C) : Colors.white;
}
