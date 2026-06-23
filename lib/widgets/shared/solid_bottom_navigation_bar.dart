import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class BottomNavItem {
  final IconData icon;
  final String label;

  BottomNavItem({required this.icon, required this.label});
}

class SolidBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavItem> items;

  const SolidBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    // Map label overrides for 1996 Dell catalog style
    final labelOverrides = {
      'Dashboard': 'HOME',
      'Member': 'FIND',
      'Laporan': 'LAPORAN',
      'Pengaturan': 'PENGATURAN',
    };

    return Container(
      color: AppColors.canvas,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top 1px black rule
          Container(height: 1, color: AppColors.frameInk),

          // The connecting green rule + icon-label row
          Stack(
            alignment: Alignment.center,
            children: [
              // Green horizontal rule connecting all items
              Positioned(
                left: 0,
                right: 0,
                top: 20,
                child: Container(height: 2, color: const Color(0xFF007700)),
              ),

              // Nav items row
              Padding(
                padding: EdgeInsets.only(
                  top: 8,
                  bottom: 8 + MediaQuery.of(context).padding.bottom,
                  left: 16,
                  right: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(items.length, (index) {
                    final isSelected = currentIndex == index;
                    final item = items[index];
                    final displayLabel = labelOverrides[item.label] ?? item.label.toUpperCase();

                    return GestureDetector(
                      onTap: () => onTap(index),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        constraints: const BoxConstraints(minWidth: 64),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Icon in white box (to block the green rule behind)
                            Container(
                              color: AppColors.canvas,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              child: Icon(
                                item.icon,
                                size: 22,
                                color: isSelected ? AppColors.primary : AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Label in classic-blue if selected, black otherwise
                            Text(
                              displayLabel,
                              style: GoogleFonts.arimo(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? AppColors.link : AppColors.ink,
                                decoration: isSelected ? TextDecoration.underline : null,
                                decorationColor: isSelected ? AppColors.link : null,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),

          // Bottom thin rule
          Container(height: 1, color: AppColors.frameInk),
        ],
      ),
    );
  }
}
