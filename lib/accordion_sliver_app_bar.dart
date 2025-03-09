import 'package:flutter/material.dart';

class AccordionSliverAppBar extends StatefulWidget {
  final Widget? background;
  final List<AccordionSliverChild> children;
  final Widget Function(double progress)? backgroundOverlayBuilder;
  final bool floating;

  const AccordionSliverAppBar({
    super.key,
    this.background,
    required this.children,
    this.backgroundOverlayBuilder,
    this.floating = false,
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

    // Create a safe area delegate. Its height is fixed (static) and it returns nothing.
    final safeAreaDelegate = AccordionSliverChild.static(
      height: safeAreaHeight,
      priority: 10000, // a high priority to ensure it is at the top
      builder: (context) => const SizedBox.shrink(),
    );

    // Combine the safe area delegate with the provided delegates.
    final combinedDelegates = <AccordionSliverChild>[
      safeAreaDelegate,
      ...widget.children,
    ];

    // Calculate the total expanded and collapsed heights based on combined delegates.
    final double totalExpandedHeight = combinedDelegates.fold(
      0.0,
      (sum, delegate) => sum + delegate.expandedHeight,
    );
    final double totalCollapsedHeight = combinedDelegates.fold(
      0.0,
      (sum, delegate) => sum + delegate.collapsedHeight,
    );

    // Calculate previous heights for each delegate.
    final previousHeights = <AccordionSliverChild, double>{};
    final sortedDelegates = List<AccordionSliverChild>.from(combinedDelegates)
      ..sort((a, b) => b.priority.compareTo(a.priority));
    double cumulativeSum = 0;
    for (var delegate in sortedDelegates) {
      previousHeights[delegate] = cumulativeSum;
      cumulativeSum += delegate.expandedHeight - delegate.collapsedHeight;
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

          // Calculate current heights and progress for each delegate.
          List<double> currentHeights = [];
          List<double> progresses = [];
          for (var delegate in combinedDelegates) {
            final double previous = previousHeights[delegate] ?? 0.0;
            final double heightDiff =
                delegate.expandedHeight - delegate.collapsedHeight;
            double delegateProgress;
            if (expansionAmount < previous) {
              currentHeights.add(delegate.collapsedHeight);
              delegateProgress = 0;
            } else if (expansionAmount < previous + heightDiff) {
              final double additionalExpansion = expansionAmount - previous;
              currentHeights
                  .add(delegate.collapsedHeight + additionalExpansion);
              delegateProgress = additionalExpansion / heightDiff;
            } else {
              currentHeights.add(delegate.expandedHeight);
              delegateProgress = 1;
            }
            progresses.add(delegateProgress);
          }

          // Calculate top positions for each delegate.
          List<double> tops = [];
          double cumulativeTop = 0;
          for (double height in currentHeights) {
            tops.add(cumulativeTop);
            cumulativeTop += height;
          }

          // Create Positioned widgets for each delegate.
          List<Widget> delegateWidgets = [];
          for (int index = 0; index < combinedDelegates.length; index++) {
            final delegate = combinedDelegates[index];
            final double top = tops[index];
            final double height = currentHeights[index];
            final double delegateProgress = progresses[index];

            Widget child;
            if (delegateProgress == 0 || delegateProgress == 1) {
              if (_widgetCache.containsKey(delegate) &&
                  (_widgetCache[delegate]?.containsKey(delegateProgress) ??
                      false)) {
                child = _widgetCache[delegate]![delegateProgress]!;
              } else {
                Widget newWidget =
                    delegate.animatedBuilder(context, delegateProgress);
                _widgetCache[delegate] ??= {};
                _widgetCache[delegate]![delegateProgress] = newWidget;
                child = newWidget;
              }
            } else {
              child = delegate.animatedBuilder(context, delegateProgress);
            }

            delegateWidgets.add(
              Positioned(
                key: ValueKey(delegate),
                top: top,
                left: 0,
                right: 0,
                height: height,
                child: delegate.wrapperBuilder(
                  context,
                  SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    clipBehavior: delegate.clipBehavior,
                    child: child,
                  ),
                ),
              ),
            );
          }

          // Build the stack containing background, optional overlay, and all delegate widgets.
          List<Widget> stackChildren = [];
          if (widget.background != null) {
            stackChildren.add(widget.background!);
          }
          if (widget.backgroundOverlayBuilder != null) {
            stackChildren.add(widget.backgroundOverlayBuilder!(progress));
          }
          stackChildren.addAll(delegateWidgets);

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
