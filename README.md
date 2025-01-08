# Accordion Sliver App Bar

`AccordionSliverAppBar` is a customizable Flutter package that provides a SliverAppBar with dynamic accordion-style animations. It enables you to create SliverAppBars where sections can expand or collapse based on priorities, creating an engaging and responsive UI.


## Demo
<img src="https://raw.githubusercontent.com/mehrzut/accordion_sliver_app_bar/master/assets/demo.gif" alt="Accordion Sliver App Bar Demo" width="300"/>



## Features
- Accordion-style SliverAppBar with custom animations.
- Supports expanded and collapsed states for child widgets.
- Customizable priorities to determine collapse order.
- Full control over alignment, layout, and animation duration.
- Compatible with SafeArea for proper layout handling.

## Installation
Run command below to add package to `pubspec.yaml`:

```bash
flutter pub add accordion_sliver_app_bar
```

Then run:

```bash
flutter pub get
```

## Usage

Here is a basic example of how to use the `AccordionSliverAppBar`:

```dart
import 'package:flutter/material.dart';
import 'package:accordion_sliver_app_bar/accordion_sliver_app_bar.dart';

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          AccordionSliverAppBar(
            delegate: AccordionSliverDeligate(
              children: [
                AccordionSliverChild(
                  expanded: SizedSliverChild(
                    child: Container(color: Colors.blue, height: 200),
                    preferredSize: Size(double.infinity, 200),
                  ),
                  collapsed: SizedSliverChild(
                    child: Container(color: Colors.blue, height: 100),
                    preferredSize: Size(double.infinity, 100),
                  ),
                  priority: 1,
                ),
                AccordionSliverChild(
                  expanded: SizedSliverChild(
                    child: Container(color: Colors.red, height: 200),
                    preferredSize: Size(double.infinity, 200),
                  ),
                  collapsed: SizedSliverChild(
                    child: Container(color: Colors.red, height: 100),
                    preferredSize: Size(double.infinity, 100),
                  ),
                  priority: 2,
                ),
              ],
              duration: Duration(milliseconds: 300),
              pinned: true,
              floating: false,
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => ListTile(title: Text('Item #$index')),
              childCount: 50,
            ),
          ),
        ],
      ),
    );
  }
}
```

## API Reference

### AccordionSliverAppBar
The main widget that acts as a container for the accordion SliverAppBar.

#### Constructor
- `AccordionSliverAppBar({Key? key, required AccordionSliverDeligate delegate})`

### AccordionSliverDeligate
Defines the behavior and layout of the accordion.

#### Properties
- `children` (List<AccordionSliverChild>): The child widgets with their expanded and collapsed states.
- `safeArea` (bool): Whether to respect the SafeArea. Default is `true`.
- `floating` (bool): Whether the app bar should float. Default is `false`.
- `pinned` (bool): Whether the app bar should be pinned. Default is `false`.
- `duration` (Duration): Animation duration for state changes.
- `animationAlignment` (AlignmentGeometry): Alignment for the animations.

### AccordionSliverChild
Represents each collapsible/expandable item in the SliverAppBar.

#### Constructor
- `AccordionSliverChild({required SizedSliverChild expanded, required SizedSliverChild collapsed, required int priority, Widget Function(BuildContext context, Widget child, Size size, bool isExpanded)? wrapperBuilder})`

#### Properties
- `expanded` (SizedSliverChild): Expanded state widget.
- `collapsed` (SizedSliverChild): Collapsed state widget.
- `priority` (int): Determines the collapse/expand order.

### SizedSliverChild
Defines a child widget with a preferred size.

#### Constructor
- `SizedSliverChild({required Widget child, required Size preferredSize})`

## Customization
You can control various aspects of the accordion, such as:
- Animation alignment and duration.
- Priority-based collapse order.
- Wrapping each child with custom builders.

## Contributions
Contributions are welcome! Feel free to submit issues, feature requests, or pull requests on the [GitHub repository](https://github.com/mehrzut/accordion_sliver_app_bar).

## License
This package is released under the MIT License. See the LICENSE file for details.

## Support
If you find this package helpful, please star the repository and share your feedback!

