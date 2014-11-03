# Depreciation warning!

Unfortunately, I **no longer have time to maintain this class**. Moreover, as since iOS6, `UILabel` now natively support `NSAttributedStrings`, **this class starts to be quite obsolete now**, and maintaining it requires a lot of work for little benefit with recent projects all supporting iOS6+.

If you still need some advanced support for `NSAttributedString` and stuff that iOS does not support natively yet, **I strongly recommand the [`DTCoreText`](https://github.com/Cocoanetics/DTCoreText) library** by @Cocoanetics as a replacement — which is a way more complete framework that my own library and let you do much more stuff.

_Note: If you are willing to take the lead and continue to make it evolve, feel free to contact me so I can give you some GIT access ton continue to maintain it._

---

_Table of Contents_

* [About these classes](#about-these-classes)
  * [`OHAttributedLabel`](#ohattributedlabel)
  * [`NSAttributedString` and `NSTextChecking` Additions](#nsattributedstring-and-nstextchecking-additions)
  * [`OHASMarkupParsers` and simple markup to build your attributed strings easily](#ohasmarkupparsers-and-simple-markup-to-build-your-attributed-strings-easily)
  * [`UIAppearance` support](#uiappearance-support)
* [How to use in your project](#how-to-use-in-your-project)
* [Sample code & Other documentation](#sample-code--other-documentation)
* [License & Credits](#license--credits)
* [ChangeLog — Revisions History](#changelog-%E2%80%94-revisions-history)
* [Projects that use this class](#projects-that-use-this-class)

----

# About these classes

### OHAttributedLabel

This class allows you to use a `UILabel` with `NSAttributedStrings`, in order to **display styled text** with various style (mixed fonts, color, size, ...) in a unique label. It is a subclass of `UILabel` which adds an `attributedText` property. Use this property, instead of the `text` property, to set and get the `NSAttributedString` to display.

> Note: This class is compatible with iOS4.3+ and has been developped before the release of the iOS6 SDK (before Apple added support for `NSAttributedLabel` in the `UILabel` class itself). It can still be used with the iOS6 SDK (the `attributedText` property hopefully match the one chosen by Apple) if you need support for eariler iOS versions or for the additional features it provides.

This class **also support hyperlinks and URLs**. It can **automatically detect links** in your text, color them and make them touchable; you can also **add "custom links" in your text** by attaching an URL to a range of your text and thus make it touchable, and even then catch the event of a touch on a link to act as you wish to.

### NSAttributedString and NSTextChecking additions

In addition to this `OHAttributedLabel` class, you will also find a category of `NS(Mutable)AttributedString` to ease creation and manipulation of common attributes of `NSAttributedString` (to easily change the font, style, color, ... of a range of the string). See the header file `NSAttributedString+Attributes.h` for a list of those comodity methods.

Example:

```objc
// Build an NSAttributedString easily from a NSString
NSMutableAttributedString* attrStr = [NSMutableAttributedString attributedStringWithString:txt];
// Change font, text color, paragraph style
[attrStr setFont:[UIFont fontWithName:@"Helvetica" size:18]];
[attrStr setTextColor:[UIColor grayColor]];

OHParagraphStyle* paragraphStyle = [OHParagraphStyle defaultParagraphStyle];
paragraphStyle.textAlignment = kCTJustifiedTextAlignment;
paragraphStyle.lineBreakMode = kCTLineBreakByWordWrapping;
paragraphStyle.firstLineHeadIndent = 30.f; // indentation for first line
paragraphStyle.lineSpacing = 3.f; // increase space between lines by 3 points
[attrStr setParagraphStyle:paragraphStyle];

// Change the color and bold of only one part of the string
[attrStr setTextColor:[UIColor redColor] range:NSMakeRange(10,3)];
[attrStr setTextBold:YES range:NSMakeRange(10,8)];

// Add a link to a given portion of the string
[attrStr setLink:someNSURL range:NSMakeRange(8,20)];
```
    
There is also a category for `NSTextCheckingResult` that adds the `extendedURL` property. This property returns the same value as the `URL` value for standard link cases, and return a formatted Maps URL for `NSTextCheckingTypeAddress` link types, that will open Google Maps in iOS version before 6.0 and the Apple's Maps application in iOS 6.0 and later.

### OHASMarkupParsers and simple markup to build your attributed strings easily

The library also comes with very simple tag parsers to help you build `NSAttributedStrings` easily using very simple tags.

* the class `OHASBasicHTMLParser` can parse simple HTML tags like `<b>` and `<u>` to make bold and underlined text, change the font color using `<font color='…'>`, etc
* the class `OHASBasicMarkupParser` can parse simple markup like `*bold text*`, `_underlined text_` and change the font color using markup like `{red|some red text}` or `{#ff6600|Yeah}`.

        // Example 1: parse HTML in attributed string
        basicMarkupLabel.attributedText = [OHASBasicHTMLParser attributedStringByProcessingMarkupInAttributedString:basicMarkupLabel.attributedText];
    
        // Example 2: parse basic markup in string
        NSAttributedString* as = [OHASBasicMarkupParser attributedStringByProcessingMarkupInString:@"Hello *you*!"];

        // Example 3: //process markup in-place in a mutable attributed string
        NSMutableAttributedString* mas = [NSMutableAttributedString attributedStringWithString:@"Hello *you*!"];
        [OHASBasicMarkupParser processMarkupInAttributedString:mas];

_Note that `OHASBasicHTMLParser` is intended to be a very simple tool only to help you build attributed string easier: this is not intended to be a real and complete HTML interpreter, and will never be. For improvements of this feature, like adding other tags or markup languages, refer to [issue #88](http://github.com/AliSoftware/OHAttributedLabel/issues/88))_

### UIAppearance support

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

There are three possible methods to include these classes in your project:

1. Using [Cocoapods](http://cocoapods.org):
    * add `pod "OHAttributedLabel"` to your Podfile

2. Include OHAttributedLabel in your project:
    * Include the `OHAttributedLabel.xcodeproj` project in your Xcode4 workspace
    * Build this `OHAttributedLabel.xcodeproj` project once for the "iOS Device" (not the simulator) _(1)_
    * Add `libOHAttributedLabel.a` **and `CoreText.framework`** to your **"Link Binary With Libraries"** Build Phase of your app project.
    * Select the `libOHAttributedLabel.a` that has just been added to your app project in your Project Navigator on the left, and change the "Location" dropdown in the File Inspector to **"Relative to Build Products"** _(1)_
    * Add the **`-ObjC` flag in the "Other Linker Flags"** Build Setting (if not present already)

3. Add `libOHAttributedLabel.a` and headers in your project
    * `cd OHAttributedLabel` 
    * `make clean && make` (nb. **rvm** users may need to ```CC= && make clean && make```)
    * copy the contents of the `build/Release-Combined` directory to you project (eg. `ThirdParty/OHAttributedLabel`)
    * Add `libOHAttributedLabel.a` **and `CoreText.framework`** to your **"Link Binary With Libraries"** Build Phase of your app project.
    * Add the OHAttributedLabel headers to your **"Header Search Path"** in Build Settings (eg. `"$(SRCROOT)/ThirdParty/OHAttributedLabel/include/**"`)
    * Add the **`-ObjC` flag in the "Other Linker Flags"** Build Setting (if not present already)


Then in your application code, when you want to make use of OHAttributedLabel methods, you only need to import the headers with `#import <OHAttributedLabel/OHAttributedLabel.h>` or `#import <OHAttributedLabel/NSAttributedString+Attributes.h>` etc.

> _(1) Note: These two steps are only necessary to avoid a bug in Xcode4 that would otherwise make Xcode fail to detect implicit dependencies between your app and the lib._

For more details and import/linking troubleshooting, please see the [dedicated page](https://github.com/AliSoftware/OHAttributedLabel/wiki/How-to-use).


# Sample code & Other documentation

There is no explicit docset or documentation of the class yet sorry (never had time to write one), but

* The method names should be self-explanatory (hopefully) as I respect the standard ObjC naming conventions.
* There are doxygen/javadoc-like documentation in the headers that should also help you describe the methods
* The provided example ("AttributedLabel Example.xcworkspace") should also demonstrate quite every typical usages — including justifying the text, dynamically changing the style/attributes of a range of text, adding custom links, make special links with a custom behavior (like catching @mention and #hashtags), and customizing the appearance/color of links.

# License & Credits

`OHAttributedLabel` is published under the MIT license.
It has been created and developped by me (O.Halligon), but I'd like to thank all the [contributors](https://github.com/AliSoftware/OHAttributedLabel/graphs/contributors) too, including @mattjgalloway, @stigi and @jparise among others.

# ChangeLog — Revisions History

The [_ChangeLog_](http://github.com/AliSoftware/OHAttributedLabel/wiki/Revisions-History) is maintained as a [wiki page accessible here](http://github.com/AliSoftware/OHAttributedLabel/wiki/Revisions-History).

# Projects that use this class

Here is a non-exhaustive list of [the projects that use this class](http://github.com/AliSoftware/OHAttributedLabel/wiki/They-use-this-class) (for those who told me about it)
Feel free to contact me if you use this class so we can cross-reference our projects and quote your app in this dedicated wiki page!
