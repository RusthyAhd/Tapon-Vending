import 'dart:math';

import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = const <_NavItemData>[
      _NavItemData(label: 'HOME', icon: Icons.home_rounded),
      _NavItemData(label: 'PAYMENT', icon: Icons.credit_card_rounded),
      _NavItemData(label: 'PROFILE', icon: Icons.person_rounded),
    ];

    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final phase = _glowController.value;
        final pulse = 0.12 + (0.12 * sin(phase * 2 * pi));

        return Container(
          padding: const EdgeInsets.fromLTRB(7, 12, 16, 18),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(6, 10, 14, 0.96),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color.fromRGBO(0, 255, 204, 0.18),
                blurRadius: 24,
                offset: const Offset(0, -6),
              ),
            ],
            border: Border.all(
              color: const Color.fromRGBO(0, 255, 204, 0.2),
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              // Positioned.fill(
              //   child: ClipRRect(
              //     borderRadius: const BorderRadius.only(
              //       topLeft: Radius.circular(28),
              //       topRight: Radius.circular(28),
              //     ),
              //     child: Image.asset(
              //       'assets/images/giphy.gif',
              //       fit: BoxFit.cover,
              //     ),
              //   ),
              // ),
              Positioned.fill(
                child: Opacity(
                  opacity: pulse,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color.fromRGBO(0, 255, 204, 0.18),
                          const Color.fromRGBO(0, 140, 255, 0.05),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 20,
                right: 20,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color.fromRGBO(0, 255, 204, 0.0),
                        const Color.fromRGBO(0, 255, 204, 0.8),
                        const Color.fromRGBO(0, 255, 204, 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              Row(
                children: List.generate(items.length, (index) {
                  final item = items[index];
                  final isSelected = widget.selectedIndex == index;

                  return Expanded(
                    child: _NavItem(
                      label: item.label,
                      icon: item.icon,
                      isSelected: isSelected,
                      onTap: () => widget.onItemTapped(index),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle =
        Theme.of(context).textTheme.labelSmall ?? const TextStyle();

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: isSelected
              ? const LinearGradient(
                  colors: [
                    Color.fromRGBO(0, 255, 204, 0.25),
                    Color.fromRGBO(0, 140, 255, 0.18),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          border: Border.all(
            color: isSelected
                ? const Color.fromRGBO(0, 255, 204, 0.7)
                : const Color.fromRGBO(255, 255, 255, 0.08),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color.fromRGBO(0, 255, 204, 0.35),
                    blurRadius: 18,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutBack,
              child: Icon(
                icon,
                color: isSelected
                    ? const Color.fromRGBO(0, 255, 204, 1)
                    : Colors.white70,
                size: 22,
              ),
            ),
            const SizedBox(height: 6),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              style: baseStyle.copyWith(
                fontSize: 10.5,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? const Color.fromRGBO(0, 255, 204, 1)
                    : Colors.white54,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItemData {
  final String label;
  final IconData icon;

  const _NavItemData({required this.label, required this.icon});
}
