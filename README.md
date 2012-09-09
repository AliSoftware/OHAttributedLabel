# About these classes

### OHAttributedLabel

This class allows you to use a** `UILabel` with `NSAttributedString`s**, in order to **display styled text** with mixed style (mixed fonts, color, size, ...) in a unique label. It is a subclass of `UILabel`, which adds an `attributedText` property. Use this property, instead of the `text` property, to set and get the `NSAttributedString` to display.

This class **also support hyperlinks and URLs**. It can **automatically detect links** in your text, color them and make them touchable; you can also **add "custom links" in your text** by attaching an URL to a range of your text and thus make it touchable, and even then catch the event of a touch on a link to act as you wish to.

### NSAttributedString and NSTextChecking additions

In addition to this `OHAttributedLabel` class, you will also find a category of NS(Mutable)AttributedString to ease creation and manipulation of common attributes of NSAttributedString (to easily change the font, style, color, ... of a range of the string). See the header file `NSAttributedString+Attributes.h` for a list of those comodity methods.

There is also a category for `NSTextCheckingResult` that adds the `extendedURL` property. This property returns the same value as the `URL` value for standard link cases, and return a formatted Maps URL for `NSTextCheckingTypeAddress` link types, that will open Google Maps in iOS version before 6.0 and the Apple's Maps application in iOS 6.0 and later.

### UIApperance support ###

The `OHAttributedLabel` class support the `UIAppearance` proxy API (available since iOS5). See selectors and properties marked using the `UI_APPEARANCE_SELECTOR` in the header.

This means that if you are targetting iOS5, you can customize all of your `OHAttributedLabel` links color and underline style to fit your application design, only in one call at the beginning of your application, instead of having to customize these for each instance.

For example, your could implement this in your `application:didFinishLoadingWithOptions:` delegate method to make **all** your `OHAttributedLabel` instances in your **whole app** display links in green and without underline instead of the default underlined blue:

    - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
    {
        [ [OHAttributedLabel appearance] setLinkColor:[UIColor colorWithRed:0.0 green:0.4 blue:0.0 alpha:1.0] ];
        [ [OHAttributedLabel appearance] setLinkUnderlineStyle:kCTUnderlineStyleNone ];
        return YES;
    }

----


# How to use in your project

To use this classes in your project:

* include the "OHAttributedLabel" and "NSAttributedString+Attributes" header (.h) and source (.m) files in your Xcode project
* **Don't forget to import the CoreText framework** in your project (otherwise you will have linker errors when you will compile)

# ARC Support

This project is compatible with both ARC and non-ARC projects.

# Sample code & Other documentation

There is no explicit docset or documentation of the class yet sorry (never had time to write one), but

* The method names should be self-explanatory (hopefully) as I respect the standard ObjC naming conventions.
* There are doxygen/javadoc-like documentation in the headers that should also help you describe the methods
* The provided example should also demonstrate quite every typical usages — including justifying the text,
dynamically changing the style/attributes of a range of text, adding custom links, make special links with a custom behavior (like catching @mention and #hashtags), and customizing the appearance/color of links.

# ChangeLog — Revisions History

The [_ChangeLog_](http://github.com/AliSoftware/OHAttributedLabel/wiki/Revisions-History) is maintained as a [wiki page accessible here](http://github.com/AliSoftware/OHAttributedLabel/wiki/Revisions-History).

# Projects that use this class

Here is a non-exhaustive list of [the projects that use this class](http://github.com/AliSoftware/OHAttributedLabel/wiki/They-use-this-class) (for those who told me about it)
Feel free to contact me if you use this class so we can cross-reference our projects and quote your app in this dedicated wiki page!