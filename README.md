# Accordion Sliver App Bar

`AccordionSliverAppBar` is a customizable Flutter package that provides a SliverAppBar with dynamic accordion-style animations. It enables you to create SliverAppBars where sections can expand or collapse based on priorities, creating an engaging and responsive UI.


## Demo
<img src="https://raw.githubusercontent.com/mehrzut/accordion_sliver_app_bar/master/example/assets/demo.gif" alt="Accordion Sliver App Bar Demo" width="300"/>



## Features

- **Accordion behavior** for multiple stacked children
- **Vanish** animation for children that fade out when collapsed
- **Static** children that don't animate
- Optional **overlay builder** to layer a widget (e.g., color overlay) on top of the background

## Installation
Run command below to add package to `pubspec.yaml`:

```bash
flutter pub add accordion_sliver_app_bar
```


## Usage

For usage instructions and a complete example, check out the [example project](https://pub.dev/packages/accordion_sliver_app_bar/example).


## AccordionSliverAppBar Parameters
* background: A widget placed at the very back of the stack (e.g., a colored container or image).
* children: A list of AccordionSliverChild objects to stack.
* backgroundOverlayBuilder: Optional function that takes a progress (0.0–1.0) and returns a widget overlaying the background.
* floating: Determines if the SliverAppBar should float.

## AccordionSliverChild Parameters
* expandedHeight: The height of the child when fully expanded.
* collapsedHeight: The height of the child when collapsed.
* priority: Higher priority children are placed nearer to the top of the stack (expanded first).
* wrapperBuilder: Wraps the child in any additional widgets (e.g., containers or scroll views).
* animatedBuilder: Receives a progress parameter from 0.0 (collapsed) to 1.0 (expanded). Use this to animate child widgets.
* clipBehavior: How to clip content (defaults to Clip.antiAlias).

## AccordionSliverChild Additional factories
* static: The child has the same height expanded or collapsed (no animation).
* staticVanish: The child is fully visible expanded, and hidden collapsed, without intermediate animation.
* vanish: The child animates its height and can fade out as it collapses.


## Contributions
Contributions are welcome! Feel free to submit issues, feature requests, or pull requests on the [GitHub repository](https://github.com/mehrzut/accordion_sliver_app_bar).

## License
This package is released under the MIT License. See the LICENSE file for details.

## Support
If you find this package helpful, please star the repository and share your feedback!

