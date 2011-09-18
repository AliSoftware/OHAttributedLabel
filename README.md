# About this classes

## OHAttributedLabel

This class allows you to use a **UILabel with NSAttributedStrings**, in order to **display styled text** with mixed style (mixed fonts, color, size, ...) in a unique label.

It is a subclass of UILabel, which adds an "attributedText" property. Use this property, instead of the "text" property, to set and get the NSAttributedString to display.

This class **also support hyperlinks and URLs**. It can **automatically detect links** in your text, color them and make them touchable; you can also **add "custom links" in your text** by attaching an URL to a range of your text and thus make it touchable, and even then catch the event of a touch on a link to act as you wish to.

## NSAttributedString additions 

In addition to this class, you will also find a category of NS(Mutable)AttributedString to ease creation and manipulation of common attributes of NSAttributedString (to easily change the font, style, color, ... of a range of the string). See the header file "NSAttributedString+Attributes.h" for a list of those comodity methods.


# How to use in your project

To use this classes in your project:

* include the "OHAttributedLabel" and "NSAttributedString+Attributes" header (.h) and source (.m) files in your Xcode project
* don't forget to import the CoreText framework in your project (otherwise you will have linker errors when you will compile)

# Sample code

See the "AttributedLabel Example" sample project for an usage example (including customization of the color of visited links in the OHAttributedLabel)

# Other documentation

There is no explicit documentation of the class yet (never had time to right one). But as I respect the standard naming conventions:

* The method names should be self-explanatory (hopefully)
* There are doxygen/javadoc-like documentation in the headers that should also help you describe the methods
* The sample code provided in this github repository tries to demonstrate quite every standard usages of this class, including text alignment, dynamically changing the style of a range of text, adding custom links, and catching the touch on links to change the default behavior.

Happy coding!