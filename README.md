# About these classes

### OHAttributedLabel

This class allows you to use a **UILabel with NSAttributedStrings**, in order to **display styled text** with mixed style (mixed fonts, color, size, ...) in a unique label. It is a subclass of UILabel, which adds an "attributedText" property. Use this property, instead of the "text" property, to set and get the NSAttributedString to display.

This class **also support hyperlinks and URLs**. It can **automatically detect links** in your text, color them and make them touchable; you can also **add "custom links" in your text** by attaching an URL to a range of your text and thus make it touchable, and even then catch the event of a touch on a link to act as you wish to.

### NSAttributedString additions 

In addition to this class, you will also find a category of NS(Mutable)AttributedString to ease creation and manipulation of common attributes of NSAttributedString (to easily change the font, style, color, ... of a range of the string). See the header file "NSAttributedString+Attributes.h" for a list of those comodity methods.


# How to use in your project

To use this classes in your project:

* include the "OHAttributedLabel" and "NSAttributedString+Attributes" header (.h) and source (.m) files in your Xcode project
* **Don't forget to import the CoreText framework** in your project (otherwise you will have linker errors when you will compile)

# ARC Support

This project is compatible with ARC since its version of August 16th, 2012.

# Sample code & Other documentation

There is no explicit documentation of the class yet (never had time to write one).

Anyway, **see the "AttributedLabel Example" sample project** which tries to demonstrate quite every standard usage of this class — including text alignment, dynamically changing the style of a range of text, adding custom links, catching the touch on links to change the default behavior, and customizing the appearance/color of links.

For everything else… UTSL ;-)

* The method names should be self-explanatory (hopefully) as I respect the standard ObjC naming conventions.
* There are doxygen/javadoc-like documentation in the headers that should also help you describe the methods
