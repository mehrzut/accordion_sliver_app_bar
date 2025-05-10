import 'package:flutter/material.dart';

class AccordionSliverAppBar extends StatefulWidget {
  final Widget? background;
  final List<AccordionSliverChild> children;
  final Widget Function(double progress)? backgroundOverlayBuilder;
  final bool floating;
  final bool safeArea;
  const AccordionSliverAppBar({
    super.key,
    this.background,
    required this.children,
    this.backgroundOverlayBuilder,
    this.floating = false,
    this.safeArea = true,
  });

  @override
  State<AccordionSliverAppBar> createState() => _AccordionSliverAppBarState();
}

class _AccordionSliverAppBarState extends State<AccordionSliverAppBar> {
  // We keep a widget cache for animated builders as before.
  Map<AccordionSliverChild, Map<double, Widget>> _widgetCache = {};

  @override
  Widget build(BuildContext context) {
    // Compute safe area height from MediaQuery.
    final safeAreaHeight = MediaQuery.of(context).padding.top;

    // Create a safe area widget. Its height is fixed (static) and it returns nothing.
    final safeAreaWidget = AccordionSliverChild.static(
      height: safeAreaHeight,
      priority: 10000, // a high priority to ensure it is at the top
      builder: (context) => const SizedBox.shrink(),
    );

    // Combine the safe area widget with the provided children.
    final combinedChildren = <AccordionSliverChild>[
      if (widget.safeArea) safeAreaWidget,
      ...widget.children,
    ];

    // Calculate the total expanded and collapsed heights based on combined children.
    final double totalExpandedHeight = combinedChildren.fold(
      0.0,
      (sum, child) => sum + child.expandedHeight,
    );
    final double totalCollapsedHeight = combinedChildren.fold(
      0.0,
      (sum, child) => sum + child.collapsedHeight,
    );

    // Calculate previous heights for each child.
    final previousHeights = <AccordionSliverChild, double>{};
    final sortedChildren = List<AccordionSliverChild>.from(combinedChildren)
      ..sort((a, b) => b.priority.compareTo(a.priority));
    double cumulativeSum = 0;
    for (var item in sortedChildren) {
      previousHeights[item] = cumulativeSum;
      cumulativeSum += item.expandedHeight - item.collapsedHeight;
    }

    return SliverAppBar(
      primary: false,
      pinned: true,
      floating: widget.floating,
      expandedHeight: totalExpandedHeight,
      toolbarHeight: totalCollapsedHeight,
      collapsedHeight: totalCollapsedHeight,
      automaticallyImplyLeading: false,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final double flexibleSpaceCurrentHeight = constraints.biggest.height;
          final double expansionAmount =
              flexibleSpaceCurrentHeight - totalCollapsedHeight;

          double progress = totalExpandedHeight == totalCollapsedHeight
              ? 1.0
              : (flexibleSpaceCurrentHeight - totalCollapsedHeight) /
                  (totalExpandedHeight - totalCollapsedHeight);
          progress = progress.clamp(0.0, 1.0);

          // Calculate current heights and progress for each child.
          List<double> currentHeights = [];
          List<double> progresses = [];
          for (var item in combinedChildren) {
            final double previous = previousHeights[item] ?? 0.0;
            final double heightDiff =
                item.expandedHeight - item.collapsedHeight;
            double itemProgress;
            if (expansionAmount < previous) {
              currentHeights.add(item.collapsedHeight);
              itemProgress = 0;
            } else if (expansionAmount < previous + heightDiff) {
              final double additionalExpansion = expansionAmount - previous;
              currentHeights.add(item.collapsedHeight + additionalExpansion);
              itemProgress = additionalExpansion / heightDiff;
            } else {
              currentHeights.add(item.expandedHeight);
              itemProgress = 1;
            }
            progresses.add(itemProgress);
          }

          // Calculate top positions for each child.
          List<double> tops = [];
          double cumulativeTop = 0;
          for (double height in currentHeights) {
            tops.add(cumulativeTop);
            cumulativeTop += height;
          }

          // Create Positioned widgets for each child.
          List<Widget> children = [];
          for (int index = 0; index < combinedChildren.length; index++) {
            final item = combinedChildren[index];
            final double top = tops[index];
            final double height = currentHeights[index];
            final double itemProgress = progresses[index];

            Widget child;
            if (itemProgress == 0 || itemProgress == 1) {
              if (_widgetCache.containsKey(item) &&
                  (_widgetCache[item]?.containsKey(itemProgress) ?? false)) {
                child = _widgetCache[item]![itemProgress]!;
              } else {
                Widget newWidget = item.animatedBuilder(context, itemProgress);
                _widgetCache[item] ??= {};
                _widgetCache[item]![itemProgress] = newWidget;
                child = newWidget;
              }
            } else {
              child = item.animatedBuilder(context, itemProgress);
            }

            children.add(
              Positioned(
                key: ValueKey(item),
                top: top,
                left: 0,
                right: 0,
                height: height,
                child: item.wrapperBuilder(
                  context,
                  SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    clipBehavior: item.clipBehavior,
                    child: child,
                  ),
                ),
              ),
            );
          }

          // Build the stack containing background, optional overlay, and all children.
          List<Widget> stackChildren = [];
          if (widget.background != null) {
            stackChildren.add(widget.background!);
          }
          if (widget.backgroundOverlayBuilder != null) {
            stackChildren.add(widget.backgroundOverlayBuilder!(progress));
          }
          stackChildren.addAll(children);

          return Stack(
            fit: StackFit.expand,
            children: stackChildren,
          );
        },
      ),
    );
  }
}

class AccordionSliverChild {
  final double expandedHeight;
  final double collapsedHeight;
  final int priority;
  final Widget Function(BuildContext context, Widget child) wrapperBuilder;
  final Widget Function(BuildContext context, double value) animatedBuilder;
  final Clip clipBehavior;

  AccordionSliverChild({
    required this.expandedHeight,
    required this.collapsedHeight,
    required this.priority,
    required this.wrapperBuilder,
    required this.animatedBuilder,
    this.clipBehavior = Clip.antiAlias,
  });

  /// Creates a child that animates and fades out when collapsing.
  factory AccordionSliverChild.vanish({
    required double height,
    required int priority,
    required Widget Function(BuildContext context, Widget child) wrapperBuilder,
    required Widget Function(BuildContext context, double value)
        animatedBuilder,
    Clip clipBehavior = Clip.antiAlias,
  }) {
    return AccordionSliverChild(
      expandedHeight: height,
      collapsedHeight: 0,
      priority: priority,
      wrapperBuilder: (context, child) => SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: wrapperBuilder(context, child)),
      animatedBuilder: animatedBuilder,
      clipBehavior: clipBehavior,
    );
  }

  /// Creates a static child that does not animate between expanded and collapsed states.
  factory AccordionSliverChild.static({
    required double height,
    required int priority,
    required Widget Function(BuildContext context) builder,
    Clip clipBehavior = Clip.antiAlias,
  }) {
    return AccordionSliverChild(
      expandedHeight: height,
      collapsedHeight: height,
      priority: priority,
      wrapperBuilder: (context, child) => builder(context),
      animatedBuilder: (context, value) => const SizedBox(),
      clipBehavior: clipBehavior,
    );
  }

  factory AccordionSliverChild.staticVanish({
    required double height,
    required int priority,
    required Widget Function(BuildContext context) builder,
    Clip clipBehavior = Clip.antiAlias,
  }) {
    return AccordionSliverChild(
      expandedHeight: height,
      collapsedHeight: 0,
      priority: priority,
      wrapperBuilder: (context, child) => SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: builder(context)),
      animatedBuilder: (context, value) => const SizedBox(),
      clipBehavior: clipBehavior,
    );
  }
}
