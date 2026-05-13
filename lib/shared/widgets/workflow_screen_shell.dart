import 'package:flutter/material.dart';

class WorkflowScreenShell extends StatelessWidget {
  const WorkflowScreenShell({
    required this.title,
    required this.subtitle,
    required this.leftPanel,
    required this.rightPanel,
    required this.primaryAction,
    this.headerBadge,
    this.topWidgets = const [],
    this.result,
    super.key,
  });

  final String title;
  final String subtitle;
  final Widget leftPanel;
  final Widget rightPanel;
  final Widget primaryAction;
  final String? headerBadge;
  final List<Widget> topWidgets;
  final Widget? result;

  static const _tabletBreakpoint = 980.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= _tabletBreakpoint;
        return ListView(
          padding: EdgeInsets.fromLTRB(
            isTablet ? 28 : 20,
            isTablet ? 24 : 20,
            isTablet ? 28 : 20,
            28,
          ),
          children: [
            _WorkflowHeader(
              title: title,
              subtitle: subtitle,
              isTablet: isTablet,
              badge: headerBadge,
            ),
            if (topWidgets.isNotEmpty) ...[
              const SizedBox(height: 20),
              ...topWidgets,
            ],
            const SizedBox(height: 20),
            if (isTablet)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 10, child: leftPanel),
                  const SizedBox(width: 24),
                  Expanded(flex: 12, child: rightPanel),
                ],
              )
            else
              Column(children: [rightPanel, leftPanel]),
            const SizedBox(height: 8),
            primaryAction,
            if (result != null) ...[const SizedBox(height: 18), result!],
          ],
        );
      },
    );
  }
}

class _WorkflowHeader extends StatelessWidget {
  const _WorkflowHeader({
    required this.title,
    required this.subtitle,
    required this.isTablet,
    this.badge,
  });

  final String title;
  final String subtitle;
  final bool isTablet;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 22 : 18,
        vertical: isTablet ? 18 : 16,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFDFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D163A66),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: isTablet ? 52 : 46,
            height: isTablet ? 52 : 46,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.space_dashboard_rounded,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          if (badge != null && badge!.trim().isNotEmpty) ...[
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                badge!,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
