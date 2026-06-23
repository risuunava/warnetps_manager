import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import 'retro_bevel_container.dart';

class RetroScaffold extends StatelessWidget {
  final Widget child;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool showBackButton;
  final VoidCallback? onBackTap;

  const RetroScaffold({
    super.key,
    required this.child,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.showBackButton = false,
    this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.frameInk, // Outer border color
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      body: Container(
        // Outer 8px black frame
        decoration: BoxDecoration(
          color: AppColors.frameInk,
          border: Border.all(color: AppColors.frameInk, width: 8.0),
        ),
        child: Container(
          color: AppColors.canvas, // Inner page canvas
          child: Column(
            children: [
              // Retro Top Banner
              _buildTopBanner(context),
              
              // Thin black separator line
              Container(
                height: 1,
                color: AppColors.frameInk,
              ),

              // Back button link if enabled
              if (showBackButton)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 12.0),
                    child: InkWell(
                      onTap: onBackTap ?? () => Navigator.maybePop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.canvas,
                          border: Border.all(color: AppColors.frameInk),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.arrow_back, size: 14, color: AppColors.ink),
                            const SizedBox(width: 8),
                            Text(
                              'KEMBALI',
                              style: GoogleFonts.arimo(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // Page Content
              Expanded(
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBanner(BuildContext context) {
    return Container(
      color: AppColors.frameInk,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Main Title / Tagline
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'WARNETPS MANAGER. ONLINE.',
                  style: GoogleFonts.arimo(
                    color: AppColors.canvas,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'SISTEM MANAGEMENT PUSAT VERSI 3.0',
                  style: GoogleFonts.arimo(
                    color: Colors.grey[400],
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          
          // Right: Pinned Phone Callout and "BUY a DELL" Sticker
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Phone number (Dell Red callout)
              Text(
                '082115276734',
                style: GoogleFonts.arimo(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 12),
              
              // Yellow Bevel Sticker: RISU
              RetroBevelContainer(
                color: AppColors.yellowSticker,
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Text(
                  'RISU',
                  style: GoogleFonts.arimo(
                    color: AppColors.ink,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
