library accordion_sliver_app_bar;

import 'dart:developer';

import 'package:accordion_sliver_app_bar/core/extensions.dart';
import 'package:flutter/material.dart';


/// A widget that creates a dynamic sliver app bar with expandable and collapsible children.
/// The children expand and collapse based on their priority values.
class AccordionSliverAppBar extends StatefulWidget {
  AccordionSliverAppBar({super.key, required this.delegate})
      : assert(
            delegate.children.map((e) => e.priority).toSet().length ==
                delegate.children.length,
            'All children priorities must be unique.'),
        assert(
            delegate.children.every(
              (element) => element.priority >= 0,
            ),
            'All children priorities must be greater than or equal to 0.');

  /// Delegate that defines the behavior and configuration of the sliver app bar.
  final AccordionSliverDelegate delegate;

  @override
  State<AccordionSliverAppBar> createState() => _AccordionSliverAppBarState();
}

class _AccordionSliverAppBarState extends State<AccordionSliverAppBar> {
  /// Computes the total expanded height by summing the heights of all expanded children.
  double get expandedHeight => widget.delegate.children.fold(
        0.0,
        (previousValue, element) =>
            previousValue + element.expanded.preferredSize.height,
      );

  /// Computes the total collapsed height by summing the heights of all collapsed children.
  double get collapsedHeight => widget.delegate.children.fold(
        0.0,
        (previousValue, element) =>
            previousValue + element.collapsed.preferredSize.height,
      );

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      expandedHeight: expandedHeight -
          (widget.delegate.safeArea
              ? 0
              : MediaQuery.paddingOf(context).vertical),
      collapsedHeight: collapsedHeight -
          (widget.delegate.safeArea
              ? 0
              : MediaQuery.paddingOf(context).vertical),
      pinned: widget.delegate.pinned,
      floating: widget.delegate.floating,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.zero,
        expandedTitleScale: 1.0,
        title: SafeArea(
          bottom: widget.delegate.safeArea,
          top: widget.delegate.safeArea,
          left: widget.delegate.safeArea,
          right: widget.delegate.safeArea,
          child: _AccordionSliverChildrenList(
            delegate: widget.delegate,
          ),
        ),
      ),
    );
  }
}

/// A helper widget to manage the animations of the children in the sliver app bar.
class _AccordionSliverChildrenList extends StatefulWidget {
  const _AccordionSliverChildrenList({required this.delegate});
  final AccordionSliverDelegate delegate;

  @override
  State<_AccordionSliverChildrenList> createState() =>
      _AccordionSliverChildrenListState();
}

class _AccordionSliverChildrenListState
    extends State<_AccordionSliverChildrenList> {
  List<_SliverChildRange> shrinkPoints = [];

  double get expandedHeight => widget.delegate.children.fold(
        0.0,
        (previousValue, element) =>
            previousValue + element.expanded.preferredSize.height,
      );

  double get collapsedHeight => widget.delegate.children.fold(
        0.0,
        (previousValue, element) =>
            previousValue + element.collapsed.preferredSize.height,
      );

  /// Returns the list of children sorted by priority.
  List<AccordionSliverChild> get _sortedByPriority => [
        ...widget.delegate.children
      ]..sort((a, b) => a.priority.compareTo(b.priority));

  @override
  void initState() {
    _configure();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant _AccordionSliverChildrenList oldWidget) {
    _configure();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final lastPriorityCollapsed =
            _getPriorityOfLastCollapsingItem(constraints.maxHeight);
        log(lastPriorityCollapsed.toString());
        return Align(
          alignment: widget.delegate.animationAlignment,
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: widget.delegate.crossAxisAlignment,
              mainAxisAlignment: widget.delegate.mainAxisAlignment,
              children: widget.delegate.children.map((child) {
                final isExpanded = lastPriorityCollapsed == null
                    ? true
                    : child.priority > lastPriorityCollapsed;
                final animatedChild = AnimatedCrossFade(
                  firstChild: child.expanded.child,
                  secondChild: child.collapsed.child,
                  crossFadeState: isExpanded
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  duration: widget.delegate.duration,
                  layoutBuilder: widget.delegate.layoutBuilder ??
                      AnimatedCrossFade.defaultLayoutBuilder,
                  firstCurve: Curves.easeIn,
                  secondCurve: Curves.easeOut,
                  sizeCurve: Curves.decelerate,
                );
                if (child.wrapperBuilder != null) {
                  return AnimatedContainer(
                    duration: widget.delegate.duration,
                    width: isExpanded
                        ? child.expanded.preferredSize.width
                        : child.collapsed.preferredSize.width,
                    height: isExpanded
                        ? child.expanded.preferredSize.height
                        : child.collapsed.preferredSize.height,
                    child: Align(
                      alignment: widget.delegate.animationAlignment,
                      child: child.wrapperBuilder!(
                          context,
                          animatedChild,
                          isExpanded
                              ? child.expanded.preferredSize
                              : child.collapsed.preferredSize,
                          isExpanded),
                    ),
                  );
                }
                return animatedChild;
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  /// Determines the priority of the last child that is in a collapsed state.
  int? _getPriorityOfLastCollapsingItem(double currentHeight) {
    final firstExpandedIndex = shrinkPoints.indexWhere(
      (element) => element.expandsOnAndAfter <= currentHeight,
    );
    if (firstExpandedIndex == -1) {
      // All items are collapsed
      return _sortedByPriority.last.priority;
    }
    final newCollapsedItemIndex = firstExpandedIndex - 1;
    if (newCollapsedItemIndex < shrinkPoints.length &&
        newCollapsedItemIndex >= 0) {
      final newCollapsedItem = shrinkPoints[newCollapsedItemIndex];
      return newCollapsedItem.priority;
    }
    // All items are expanded
    return null;
  }

  /// Configures the shrink points based on the priorities of the children.
  void _configure() {
    for (var i = 0; i < _sortedByPriority.length; i++) {
      final collapsed = _sortedByPriority.splitAtNotContaining(i).first;
      final expanded = _sortedByPriority.splitAtNotContaining(i).last;
      final itemsMinSpaceToExpand = collapsed.fold(
            0.0,
            (previousValue, element) =>
                previousValue + element.collapsed.preferredSize.height,
          ) +
          expanded.fold(
            0.0,
            (previousValue, element) =>
                previousValue + element.expanded.preferredSize.height,
          ) +
          _sortedByPriority[i].expanded.preferredSize.height;
      shrinkPoints = shrinkPoints.addOrUpdateWhere(
          (e) => e.priority == _sortedByPriority[i].priority,
          (e) => (_SliverChildRange(
                priority: _sortedByPriority[i].priority,
                expandsOnAndAfter: itemsMinSpaceToExpand,
              )));
    }
    log(shrinkPoints.toString());
  }
}

/// A model representing a child in the accordion sliver app bar.
class AccordionSliverChild {
  final SizedSliverChild expanded;
  final SizedSliverChild collapsed;
  final Widget Function(
          BuildContext context, Widget child, Size size, bool isExpanded)?
      wrapperBuilder;

  /// The priority of the child.
  /// Higher priority numbers collapse later.
  final int priority;
  final bool isExpanded;

  AccordionSliverChild._({
    required this.expanded,
    required this.collapsed,
    required this.priority,
    this.isExpanded = true,
    this.wrapperBuilder,
  });

  AccordionSliverChild collapse() => copyWith(isExpanded: false);

  /// Creates a child that vanishes (becomes zero size) when collapsed.
  factory AccordionSliverChild.vanish({
    required SizedSliverChild expanded,
    required int priority,
  }) =>
      AccordionSliverChild._(
        expanded: expanded,
        collapsed: SizedSliverChild(
          preferredSize: Size.zero,
          child: const SizedBox(),
        ),
        priority: priority,
      );

  factory AccordionSliverChild({
    required SizedSliverChild expanded,
    required SizedSliverChild collapsed,
    required int priority,
    Widget Function(
            BuildContext context, Widget child, Size size, bool isExpanded)?
        wrapperBuilder,
  }) =>
      AccordionSliverChild._(
        expanded: expanded,
        collapsed: collapsed,
        priority: priority,
        wrapperBuilder: wrapperBuilder,
      );

  AccordionSliverChild copyWith(
          {SizedSliverChild? expanded,
          SizedSliverChild? collapsed,
          int? priority,
          bool? isExpanded}) =>
      AccordionSliverChild._(
        expanded: expanded ?? this.expanded,
        collapsed: collapsed ?? this.collapsed,
        priority: priority ?? this.priority,
        isExpanded: isExpanded ?? this.isExpanded,
      );
}

/// A helper class to manage the state and range of child expansions.
class _SliverChildRange {
  final double expandsOnAndAfter;
  final int priority;

  _SliverChildRange({required this.expandsOnAndAfter, required this.priority});

  @override
  String toString() {
    return '_SliverChildRange(expandsOnAndAfter: $expandsOnAndAfter, priority: $priority)';
  }
}

/// The delegate that defines the configuration for the accordion sliver app bar.
class AccordionSliverDelegate {
  final List<AccordionSliverChild> children;
  final bool safeArea;
  final bool floating;
  final bool pinned;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  final AlignmentGeometry animationAlignment;
  final AnimatedCrossFadeBuilder? layoutBuilder;
  final Duration duration;

  AccordionSliverDelegate({
    required this.children,
    this.safeArea = true,
    this.floating = false,
    this.pinned = false,
    this.layoutBuilder,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.animationAlignment = AlignmentDirectional.bottomCenter,
    required this.duration,
  });
}

/// A helper class to define a child with its size and widget.
class SizedSliverChild {
  final Widget child;
  final Size preferredSize;
  SizedSliverChild({required this.child, required this.preferredSize});
}
