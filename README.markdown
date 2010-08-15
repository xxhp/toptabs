# toptabs

Currently a work in progress. I'm taking an old-ish tab bar implementation and updating it with a Chrome-like UI and support for multiple windows.

The current issues are (in approximate order of importance):

* The previous version had tabs of a fixed size, and when you added too many tabs, they got pushed to an overflow menu. In contrast, Chrome just makes tabs smaller and smaller and never pushed them into an overflow menu. I find Chrome's way considerably better, since I can't accidentally push old tabs into the overflow and then lose them.
 * It shouldn't be too difficult to do this, we just have to write a method to resize tabs to fit and only call it when creating new tabs, when moving the cursor outside the tab bar, when closing the leftmost tab and when closing tabs programatically or from the keyboard.
* The tab bar was never intended to be used across multiple windows, and is heavily reliant on NSTabView to keep track of things. There needs to be a controller that coordinates all the different tab bars (conceivably you might want multiple session controllers, for example one to handle incognito-mode tab bars and one to handle normal-mode tab bars).
* While the code was designed to be reusable, it still requires some plumbing work to get it integrated into an app. This is somewhat unavoidable, since there's so many different ways to use a tab bar. There needs to be a proper delegate to collect all the plumbing into one place.
* The code is messy, uncommented and commonly wrong. But also open source :)
* The nice theme we have right now is made up of rasters and not vectors.

Feel free to fork or patch any of the issues. You can consider the code licensed under whatever makes you feel happy.

![Screenshot](http://fileability.net/snaps/awesometabs.png)