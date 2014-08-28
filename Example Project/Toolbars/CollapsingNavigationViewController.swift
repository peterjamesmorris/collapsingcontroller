//
//  CollapsingNavigationViewController.swift
//
//  Created by Pete Morris on 26/08/2014.
//  Copyright (c) 2014 Mumsnet. All rights reserved.
//

import UIKit

public var isOS7OrBelow: Bool {
        let systemVersion: NSString = UIDevice.currentDevice().systemVersion
        return systemVersion.floatValue < 8
}

private extension UIScrollView {

    var isBouncing: Bool {

        return (self.contentOffset.y < -self.contentInset.top)
                || (self.contentOffset.y > self.contentSize.height - self.frame.size.height + self.contentInset.bottom)
                ? true : false

    }

}

extension UINavigationController {

    private var statusBarFrame: CGRect {

        return UIApplication.sharedApplication().statusBarFrame

    }

    private var statusBarHeight: CGFloat {
        
        return isOS7OrBelow ? 20 : statusBarFrame.size.height // Hack for iOS7 and below - UIApplication.statusBarFrame does not respect orientation, and there is no access to status bar bounds

    }

    private var yPointForFullyHiddenNavigationBar: CGFloat {

        if UIApplication.sharedApplication().statusBarHidden {

            return -self.navigationBar.frame.size.height

        }
        
        if isOS7OrBelow {
            return -self.navigationBar.frame.size.height + 20 // Hack for iOS7 and below - UIApplication.statusBarFrame does not respect orientation, and there is no access to status bar bounds
        } else {
            return -self.navigationBar.frame.size.height + statusBarFrame.size.height
        }

    }

    /* Returns the appropriate alpha value for the current navigationBar y coordinate
        The higher the y coordinate, the higher the alpha value. Will return 1.0 if the
        navigation bar's full height is visible on screen, and 0.0 the navigation bar's
        height is fully hidden offscreen */
    private var itemsAlpha: CGFloat {

        switch UIApplication.sharedApplication().statusBarHidden {
            
            case true:
                return 1.0

            default:

                if self.navigationBar.frame.origin.y == statusBarHeight {

                    return 1.0

                } else {

                    return ((self.navigationBar.frame.origin.y + self.navigationBar.frame.size.height) - statusBarHeight) / self.navigationBar.frame.size.height

                }

        }

    }

    private var isNavigationBarHidden: Bool {

        return self.navigationBar.frame.origin.y == yPointForFullyHiddenNavigationBar ? true : false

    }
    
    /* Moves the nevigation bar by the number of points specified along it's y axis.
        Does not allow movement beyond a strict set of bounds, which define the y axis
        of the navigation defined by the yPosition of the bar in its fully hidden offscreen
        state, and it's fully visible onscreen state. Movement only inbetweem these bounds is
        processed.
        Also sets the alpha of all titles and navigation items to a suitable value; fading them
        out as the bar hides, and fading them in as it appears */
    private func moveNavigationBarByYPoints(numberOfYPoints: CGFloat) {

        var navigationBarFrame = self.navigationBar.frame
        let scrollingDown = numberOfYPoints > 0 ? true : false

        navigationBarFrame.origin.y -= numberOfYPoints

        if scrollingDown && navigationBarFrame.origin.y < yPointForFullyHiddenNavigationBar {

            navigationBarFrame.origin.y = yPointForFullyHiddenNavigationBar

        }

        if !scrollingDown && navigationBarFrame.origin.y > statusBarHeight {

            navigationBarFrame.origin.y = statusBarHeight

        }

        self.navigationBar.frame = navigationBarFrame
        self.setTitleTextAlpha()
        self.setItemsAlpha()

    }

    /* If the navigation bar is halfway offscreen, will animate it to its fully
       hidden position. If the navigation bar is less than half hidden, will animate
       it to its fully visible state. If allowBarToHide is true, will always animate
       bar to its fully visible state, regardless of its current position */
    private func animateNavigationBarIntoPosition(#allowBarToHide: Bool) {

        var navigationBarFrame = self.navigationBar.frame

        // if navigation bar is over halfway offscreen, hide it fully. Else, reveal whole bar.

        switch UIApplication.sharedApplication().statusBarHidden {

            case true:

                if navigationBarFrame.origin.y < -(navigationBarFrame.size.height / 2) && allowBarToHide {

                    navigationBarFrame.origin.y = yPointForFullyHiddenNavigationBar

                } else {

                    navigationBarFrame.origin.y = statusBarHeight

                }

            default:

                if navigationBarFrame.origin.y < (statusBarFrame.origin.y + statusBarHeight) - (navigationBarFrame.size.height / 2) && allowBarToHide {

                    navigationBarFrame.origin.y = yPointForFullyHiddenNavigationBar

                } else {

                    navigationBarFrame.origin.y = statusBarHeight

                }

        }

        UIView.animateWithDuration(0.1, animations: {

            self.navigationBar.frame = navigationBarFrame
            self.setTitleTextAlpha()
            self.setItemsAlpha()

        })

    }

    private func setTitleTextAlpha() {
  
        var titleAttributes = self.navigationBar.titleTextAttributes

        if titleAttributes != nil {

            if let oldColor = titleAttributes[NSForegroundColorAttributeName] as? UIColor {

                titleAttributes[NSForegroundColorAttributeName] = oldColor.colorWithAlphaComponent(self.itemsAlpha)

            }

        } else {

            titleAttributes = [NSForegroundColorAttributeName: UIColor.blackColor().colorWithAlphaComponent(self.itemsAlpha)]

        }

        self.navigationBar.titleTextAttributes = titleAttributes

    }

    private func setItemsAlpha() {

        if let currentTintColor = self.navigationBar.tintColor {

            self.navigationBar.tintColor = currentTintColor.colorWithAlphaComponent(self.itemsAlpha)

        }
    }

    override public func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator!) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        coordinator.animateAlongsideTransition({ coordinator in
 
            self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.blackColor()]

        }, completion:nil)
    }
    
}

extension UITabBarController {

    private var yPointForFullyHiddenTabBar: CGFloat {

        return yPointForFullyVisibileTabBar + self.tabBar.frame.size.height

    }

    private var yPointForFullyVisibileTabBar: CGFloat {

        return self.view.bounds.size.height - self.tabBar.frame.size.height

    }

    /* Adds numberOfYPoints to the tabBar's current y coordinate. Movement is
       restrict between a stict set of bounds, which are defined by the tab bars default
       fully onscreen position, and its fully offscreen position. Movement outside of these
       bounds will not be processed. */
    private func moveTabBarByYPoints(numberOfYPoints: CGFloat) {

        var tabBarFrame = self.tabBar.frame;
        let scrollingDown = numberOfYPoints > 0 ? true : false
        tabBarFrame.origin.y = tabBarFrame.origin.y + numberOfYPoints

        if !scrollingDown && tabBarFrame.origin.y < yPointForFullyVisibileTabBar {

            tabBarFrame.origin.y = yPointForFullyVisibileTabBar

        }

        if scrollingDown && tabBarFrame.origin.y > yPointForFullyHiddenTabBar {

            tabBarFrame.origin.y = yPointForFullyHiddenTabBar

        }

        self.tabBar.frame = tabBarFrame

    }

    /* If hidden is true, will animate the tabBar into its fully hidden offscreen state.
       If hidden is false, will animate the tabBar into its fully visible onscreen state. */
    private func animateTabBarIntoPosition(#hidden: Bool) {

        var tabBarFrame = self.tabBar.frame

        if hidden {

            tabBarFrame.origin.y = yPointForFullyHiddenTabBar

        } else {

            tabBarFrame.origin.y = yPointForFullyVisibileTabBar

        }

        UIView.animateWithDuration(0.1, animations: { self.tabBar.frame = tabBarFrame })
    }

    override public func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator!) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        let newYPosition = size.height - self.tabBar.frame.size.height
        var tabBarFrame = self.tabBar.frame
        tabBarFrame.origin.y = newYPosition
        tabBarFrame.size.width = size.width
        coordinator.animateAlongsideTransition({ coordinator in self.tabBar.frame = tabBarFrame }, completion:nil)
    }

}

/* An abstract subclass of UIViewController with collapsing bar behavior.
 
   The CollapsingNavigationViewController is abstract subclass of UIViewController, which will collapse the bars
   of it's parent UINavigationController and UITabBarController when a scrollview it is the delegate of is scrolled
   downwards. It will reposition the bars on the screen when a scrollview it is the delegate of is scrolled upwards.
 
   If a segue is performed, as part of the preparation CollapsingNavigationViewController will reveal the navigation bar
   and tab bar if they are hidden. If you override prepareForSegue in your subclass, you must call the superclass' implementation
   before doing any further customization.
   
   Provides a property, shouldHideTabBarWhenScrolling, which can be set to false to stop the tab bar
   from being collapsed during scrolling.
 
   CollapsingNavigationViewController must be made a UIScrollViewDelegate or
   a UITableViewDelegate for the collapsing functionality to work.
 
   If you wish to override the UIScrollViewDelegate methods scrollViewDidScroll or scrollViewDidEndDragging in your subclass,
   then you must call the superclass implementation of these methods first
 
   Also overrides viewWillTransitionToSize, call super class implementation in your subclass if you wish to override this method.
 
 */
class CollapsingNavigationViewController: UIViewController, UIScrollViewDelegate {

    var shouldHideTabBarWhenScrolling: Bool = true
    private var previousScrollViewOffset: CGPoint = CGPoint(x: 0,y: 0)
    private var shouldAllowBarsToCollapse: Bool = true

    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        super.willRotateToInterfaceOrientation(toInterfaceOrientation, duration: duration)
        shouldAllowBarsToCollapse = false
        self.revealAllBars()
    }

    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        super.didRotateFromInterfaceOrientation(fromInterfaceOrientation)
    }

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator!) {

        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        shouldAllowBarsToCollapse = false

    }

    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {

        super.prepareForSegue(segue, sender: sender)
        self.revealAllBars()

    }

    func scrollViewDidScrollToTop(scrollView: UIScrollView!) {

        self.revealAllBars()

    }


    func scrollViewDidScroll(scrollView: UIScrollView!) {

        // if scrollView offset is not bouncing at top or bottom of content, and
        // user is currently scrolling or content offset is still moving

        if  !scrollView.isBouncing && shouldAllowBarsToCollapse && (scrollView.tracking != false || scrollView.decelerating != false) {

            let yPointsMoved = scrollView.contentOffset.y - previousScrollViewOffset.y
            self.navigationController?.moveNavigationBarByYPoints(yPointsMoved)

            if (shouldHideTabBarWhenScrolling == true) {

                self.tabBarController?.moveTabBarByYPoints(yPointsMoved)

            }

        }

        previousScrollViewOffset = scrollView.contentOffset
    }

    func scrollViewWillBeginDragging(scrollView: UIScrollView!) {

        shouldAllowBarsToCollapse = true

    }

    func scrollViewDidEndDragging(scrollView: UIScrollView!, willDecelerate decelerate: Bool) {

        // if scrollview offset is not changing

        if (decelerate == false) {

            if let statusBarFrameHeight = self.navigationController?.statusBarHeight {

                let enoughSpaceForNavBarToExpand = scrollView.contentOffset.y >= -statusBarFrameHeight ? true : false
                self.navigationController?.animateNavigationBarIntoPosition(allowBarToHide: enoughSpaceForNavBarToExpand)

            }

            if (shouldHideTabBarWhenScrolling) {

                self.tabBarController.animateTabBarIntoPosition(hidden: self.navigationController.isNavigationBarHidden)

            }

        }
    }


    private func revealAllBars() {

        self.navigationController?.animateNavigationBarIntoPosition(allowBarToHide: false)
        self.tabBarController?.animateTabBarIntoPosition(hidden: false)

    }


}

