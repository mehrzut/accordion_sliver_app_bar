import 'package:flutter/material.dart';

class AccordionSliverAppBar extends StatefulWidget {
  final Widget? background;
  final List<AccordionSliverChild> delegates;
  final Widget Function(double progress)? backgroundOverlayBuilder;
  final bool floating;

  const AccordionSliverAppBar({
    super.key,
    this.background,
    required this.delegates,
    this.backgroundOverlayBuilder,
    this.floating = false,
  });

  @override
  State<AccordionSliverAppBar> createState() => _AccordionSliverAppBarState();
}

class _AccordionSliverAppBarState extends State<AccordionSliverAppBar> {
  List<AccordionSliverChild>? _delegates;
  Map<AccordionSliverChild, double>? _previousHeights;
  Map<AccordionSliverChild, Map<double, Widget>> _widgetCache = {};

  void _calculatePreviousHeights() {
    if (widget.delegates.isEmpty) {
      _previousHeights = {};
      return;
    }

    List<AccordionSliverChild> sortedDelegates = List.from(_delegates!);
    sortedDelegates.sort((a, b) => b.priority.compareTo(a.priority));

    double cumulativeSum = 0;
    _previousHeights = {};
    for (var delegate in sortedDelegates) {
      _previousHeights![delegate] = cumulativeSum;
      cumulativeSum += delegate.expandedHeight - delegate.collapsedHeight;
    }
  }

  @override
  void initState() {
    super.initState();
    _delegates = widget.delegates;
    _calculatePreviousHeights();
  }

  @override
  void didUpdateWidget(covariant AccordionSliverAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.delegates != _delegates) {
      _delegates = widget.delegates;
      _calculatePreviousHeights();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double totalExpandedHeight = widget.delegates
        .fold(0.0, (sum, delegate) => sum + delegate.expandedHeight);
    final double totalCollapsedHeight = widget.delegates
        .fold(0.0, (sum, delegate) => sum + delegate.collapsedHeight);

    return SliverAppBar(
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

          // Calculate current heights and progresses for each delegate
          List<double> currentHeights = [];
          List<double> progresses = [];
          for (var delegate in widget.delegates) {
            double previousHeights = _previousHeights![delegate]!;
            double heightDiff =
                delegate.expandedHeight - delegate.collapsedHeight;
            double delegateProgress;
            if (expansionAmount < previousHeights) {
              currentHeights.add(delegate.collapsedHeight);
              delegateProgress = 0;
            } else if (expansionAmount < previousHeights + heightDiff) {
              double additionalExpansion = expansionAmount - previousHeights;
              currentHeights
                  .add(delegate.collapsedHeight + additionalExpansion);
              delegateProgress = additionalExpansion / heightDiff;
            } else {
              currentHeights.add(delegate.expandedHeight);
              delegateProgress = 1;
            }
            progresses.add(delegateProgress);
          }

          // Calculate top positions for each delegate
          List<double> tops = [];
          double cumulativeTop = 0;
          for (double height in currentHeights) {
            tops.add(cumulativeTop);
            cumulativeTop += height;
          }

          // Create Positioned widgets for each delegate
          List<Widget> delegateWidgets =
              widget.delegates.asMap().entries.map((entry) {
            int index = entry.key;
            var delegate = entry.value;
            double top = tops[index];
            double height = currentHeights[index];
            double progress = progresses[index];

            Widget child;
            if (progress == 0 || progress == 1) {
              if (_widgetCache.containsKey(delegate) &&
                  (_widgetCache[delegate]?.containsKey(progress) ?? false)) {
                child = _widgetCache[delegate]![progress]!;
              } else {
                Widget newWidget = delegate.animatedBuilder(context, progress);
                _widgetCache[delegate] ??= {};
                _widgetCache[delegate]![progress] = newWidget;
                child = newWidget;
              }
            } else {
              child = delegate.animatedBuilder(context, progress);
            }

            return Positioned(
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
            );
          }).toList();

          // Create Stack with background, optional overlay, and delegates
          List<Widget> stackChildren = [];
          if (widget.background != null) {
            stackChildren.add(widget.background!);
          }
          if (widget.backgroundOverlayBuilder != null) {
            stackChildren.add(
              widget.backgroundOverlayBuilder!(progress),
            );
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
      wrapperBuilder: wrapperBuilder,
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
      wrapperBuilder: (context, child) => builder(context),
      animatedBuilder: (context, value) => const SizedBox(),
      clipBehavior: clipBehavior,
    );
  }
}
