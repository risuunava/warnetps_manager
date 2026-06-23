import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import 'retro_crt_monitor.dart';

enum UnitState { occupied, available, maintenance }

class UnitCard extends StatefulWidget {
  final String title;
  final UnitState state;
  final String? timeText;
  final Widget? timeWidget;
  final VoidCallback onTap;

  const UnitCard({
    super.key,
    required this.title,
    required this.state,
    this.timeText,
    this.timeWidget,
    required this.onTap,
  });

  @override
  State<UnitCard> createState() => _UnitCardState();
}

class _UnitCardState extends State<UnitCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // Ribbon-card tint & status label per DESIGN.md
    final Color bodyTint;
    final String stateText;
    final Color crtScreenColor;
    final bool isPowerOn;

    switch (widget.state) {
      case UnitState.occupied:
        bodyTint = AppColors.tintPeach;
        stateText = 'TERISI';
        crtScreenColor = const Color(0xFF1A6B1A); // Classic CRT green
        isPowerOn = true;
        break;
      case UnitState.available:
        bodyTint = AppColors.tintSage;
        stateText = 'TERSEDIA';
        crtScreenColor = const Color(0xFF003080); // Dark blue idle
        isPowerOn = true;
        break;
      case UnitState.maintenance:
        bodyTint = AppColors.tintSalmon;
        stateText = 'MAINTENANCE';
        crtScreenColor = AppColors.frameInk;
        isPowerOn = false;
        break;
    }

    final bool isMaintenance = widget.state == UnitState.maintenance;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: isMaintenance ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: isMaintenance ? null : widget.onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // === ribbon-card-title: White title bar ===
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: _isHovered && !isMaintenance ? const Color(0xFFF0F0F0) : AppColors.canvas,
                border: const Border(
                  top: BorderSide(color: AppColors.frameInk, width: 1),
                  left: BorderSide(color: AppColors.frameInk, width: 1),
                  right: BorderSide(color: AppColors.frameInk, width: 1),
                  bottom: BorderSide(color: AppColors.frameInk, width: 1),
                ),
              ),
              child: Text(
                widget.title.toUpperCase(),
                style: GoogleFonts.arimo(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                  height: 1.0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // === ribbon-card-body: Tinted body with CRT notch ===
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isMaintenance ? bodyTint.withOpacity(0.6) : bodyTint,
                  border: const Border(
                    left: BorderSide(color: AppColors.frameInk, width: 1),
                    right: BorderSide(color: AppColors.frameInk, width: 1),
                    bottom: BorderSide(color: AppColors.frameInk, width: 1),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Left: State text + time
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // State badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.canvas,
                                border: Border.all(color: AppColors.frameInk, width: 1),
                              ),
                              child: Text(
                                stateText,
                                style: GoogleFonts.arimo(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.ink,
                                  height: 1.0,
                                ),
                              ),
                            ),
                            if (!isMaintenance && widget.state == UnitState.occupied) ...[
                              const SizedBox(height: 4),
                              widget.timeWidget ??
                                  Text(
                                    widget.timeText ?? '--:--:--',
                                    style: GoogleFonts.tinos(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.ink,
                                    ),
                                  ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // Right: CRT monitor "product photo notch"
                    Padding(
                      padding: const EdgeInsets.only(right: 6, top: 4, bottom: 4),
                      child: RetroCrtMonitor(
                        screenColor: crtScreenColor,
                        isPowerOn: isPowerOn,
                        width: 44,
                        height: 38,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
