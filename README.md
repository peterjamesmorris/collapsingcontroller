collapsingcontroller
====================

An abstract subclass of UIViewController with collapsing bar behavior.

The CollapsingNavigationViewController is abstract subclass of UIViewController, which will collapse the bars of it's parent UINavigationController and UITabBarController when a scrollview it is the delegate of is scrolled downwards. It will reposition the bars on the screen when a scrollview it is the delegate of is scrolled upwards.
 
If a segue is performed, as part of the preparation CollapsingNavigationViewController will reveal the navigation bar and tab bar if they are hidden. If you override prepareForSegue in your subclass, you must call the superclass' implementation before doing any further customization.

Provides a property, shouldHideTabBarWhenScrolling, which can be set to false to stop the tab bar from being collapsed during scrolling.

CollapsingNavigationViewController must be made a UIScrollViewDelegate or a UITableViewDelegate for the collapsing functionality to work.
 
If you wish to override the UIScrollViewDelegate methods scrollViewDidScroll or scrollViewDidEndDragging in your subclass, then you must call the superclass implementation of these methods first
 
Also overrides viewWillTransitionToSize, call super class implementation in your subclass if you wish to override this method.
