## 0.0.8

* Added `safeArea` parameter to `AccordionSliverAppBar` to control whether the safe area is added to the app bar.

## 0.0.7

* Updated README

## 0.0.6

* Moved demo gif file to example
* Bug fix

## 0.0.5

#### New Features and Enhancements
* Built-in safe area handling ensures consistent behavior across devices.
* Custom animation support via `animatedBuilder` in `AccordionSliverChild` allows for flexible child transitions.
* Added `background` and `backgroundOverlayBuilder` for enhanced visual customization.
* A widget cache improves performance by storing rendered widgets for different states.
* Introduced a new `staticVanish` factory method for `AccordionSliverChild`, enabling static children that vanish when collapsed.

#### Breaking Changes
* The constructor no longer accepts a delegate, requiring direct property updates.
* `AccordionSliverChild` now uses `expandedHeight`, `collapsedHeight`, and other new properties, necessitating updates to child definitions.
* Factory methods for `AccordionSliverChild` have new signatures, requiring adjustments in usage.

## 0.0.4

* Some bug fixes
* Added `AccordionSliverChild.static` to make an static child
* In `AccordionSliverChild.vanish` changed the name of child from `expanded` to `child`
* Added `backgroundBuilder` to `AccordionSliverDelegate` for background customization

## 0.0.3

* initial release.

