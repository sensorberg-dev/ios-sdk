# Sensorberg Objective-C Style Guide

This style guide outlines the coding conventions of the iOS team at Sensorberg, based on the great [New York Times objective-c style guide](https://github.com/SBimes/objetive-c-style-guide).

Thanks to all of [contributors](https://github.com/SBimes/objective-c-style-guide/contributors).

## Introduction

Here are some of the documents from Apple that informed the style guide. If something isn't mentioned here, it's probably covered in great detail in one of these:

* [The Objective-C Programming Language](http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/ObjectiveC/Introduction/introObjectiveC.html)
* [Cocoa Fundamentals Guide](https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/CocoaFundamentals/Introduction/Introduction.html)
* [Coding Guidelines for Cocoa](https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/CodingGuidelines/CodingGuidelines.html)
* [iOS App Programming Guide](http://developer.apple.com/library/ios/#documentation/iphone/conceptual/iphoneosprogrammingguide/Introduction/Introduction.html)

## Table of Contents

* [Code Formatting in Xcode](#code-formatting-in-xcode)
* [Dot-Notation Syntax](#dot-notation-syntax)
* [Spacing](#spacing)
* [Conditionals](#conditionals)
  * [Ternary Operator](#ternary-operator)
* [Error handling](#error-handling)
* [Methods](#methods)
* [Variables](#variables)
* [Blocks](#blocks)
* [Naming](#naming)
* [Comments](#comments)
* [Init & Dealloc](#init-and-dealloc)
* [Literals](#literals)
* [CGRect Functions](#cgrect-functions)
* [Constants](#constants)
* [Enumerated Types](#enumerated-types)
* [Bitmasks](#bitmasks)
* [Private Properties](#private-properties)
* [Image Naming](#image-naming)
* [Booleans](#booleans)
* [Singletons](#singletons)
* [Imports](#imports)
* [Class header file structure](#class-header-file-structure)
* [Class implementation file structure](#class-implementation-file-structure)
* [Xcode Project](#xcode-project)
* [Testing](#testing)
* [Code organization / App architecture](#code-organization)

##Code Formatting in Xcode

All rules outlined here are enforced by the code beautifier [Uncrustify](https://github.com/bengardner/uncrustify). We do not do a fully automatic code beautification in the background. You have to trigger code formatting/beautification yourself. In order to do this install Uncrustifiy and the corresponding Xcode plugin:

* install uncrustify via brew:
	* $brew install uncrustify
* for Xcode you can use the [BBUncrustifyPlugin](https://github.com/benoitsan/BBUncrustifyPlugin-Xcode)
(after installing the plugin you can add a short cut for convenience (see [here] (https://github.com/travisjeffery/ClangFormat-Xcode) just set 'Menu Title' to 'Format Selected Lines')

If you have installed Uncrustify and the Xcode plugin, you should format the code you have changed by selecting those lines and choose 'Edit -> Format Code -> Format Selected Lines' from the menu or use the short cut that you have created.

## Dot-Notation Syntax

Dot-notation should **always** be used for accessing and mutating properties. Bracket notation is preferred in all other instances.

**For example:**
```objc
view.backgroundColor = [UIColor orangeColor];
[UIApplication sharedApplication].delegate;
```

**Not:**
```objc
[view setBackgroundColor:[UIColor orangeColor]];
UIApplication.sharedApplication.delegate;
```

## Spacing

* Indent using 4 spaces. Never indent with tabs. Be sure to set this preference in Xcode.
* Method braces and other braces (`if`/`else`/`switch`/`while` etc.) always open on the next line than the statement and end on a new line.

**For example:**
```objc
if (user.isHappy) 
{
    //Do something
}
else
{
    //Do something else
}
```
* There should be exactly one blank line between methods to aid in visual clarity and organization. Whitespace within methods should separate functionality, but often there should probably be new methods.
* `@synthesize` and `@dynamic` should each be declared on new lines in the implementation.

## Conditionals

Conditional bodies should always use braces even when a conditional body could be written without braces (e.g., it is one line only) to prevent [errors](https://github.com/SBimes/objective-c-style-guide/issues/26#issuecomment-22074256). These errors include adding a second line and expecting it to be part of the if-statement. Another, [even more dangerous defect](http://programmers.stackexchange.com/a/16530) may happen where the line "inside" the if-statement is commented out, and the next line unwittingly becomes part of the if-statement. In addition, this style is more consistent with all other conditionals, and therefore more easily scannable.

**For example:**
```objc
if (!error) 
{
    return success;
}
```

**Not:**
```objc
if (!error)
    return success;
```

or

```objc
if (!error) return success;
```

### Ternary Operator

The Ternary operator, ? , should only be used when it increases clarity or code neatness. A single condition is usually all that should be evaluated. Evaluating multiple conditions is usually more understandable as an if statement, or refactored into instance variables.

**For example:**
```objc
result = a > b ? x : y;
```

**Not:**
```objc
result = a > b ? x = c > d ? c : d : y;
```

## Error handling

When methods return an error parameter by reference, switch on the returned value, not the error variable.

**For example:**
```objc
NSError *error;
if (![self trySomethingWithError:&error]) 
{
    // Handle Error
}
```

**Not:**
```objc
NSError *error;
[self trySomethingWithError:&error];
if (error) {
    // Handle Error
}
```

Some of Apple’s APIs write garbage values to the error parameter (if non-NULL) in successful cases, so switching on the error can cause false negatives (and subsequently crash).

## Methods

In method signatures, there should be a space after the scope (-/+ symbol). There should be a space between the method segments.

**For Example**:
```objc
- (void)setExampleText:(NSString *)text image:(UIImage *)image;
```
## Variables

Variables should be named as descriptively as possible. Single letter variable names should be avoided except in `for()` loops.

Asterisks indicating pointers belong with the variable, e.g., `NSString *text` not `NSString* text` or `NSString * text`, except in the case of constants.

Property definitions should be used in place of naked instance variables whenever possible. Direct instance variable access should be avoided except in initializer methods (`init`, `initWithCoder:`, etc…), `dealloc` methods and within custom setters and getters. For more information on using Accessor Methods in Initializer Methods and dealloc, see [here](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/MemoryMgmt/Articles/mmPractical.html#//apple_ref/doc/uid/TP40004447-SW6).

**For example:**

```objc
@interface SBSection: NSObject

@property (nonatomic) NSString *headline;

@end
```

**Not:**

```objc
@interface SBSection : NSObject {
    NSString *headline;
}
```

#### Variable Qualifiers

When it comes to the variable qualifiers [introduced with ARC](https://developer.apple.com/library/ios/releasenotes/objectivec/rn-transitioningtoarc/Introduction/Introduction.html#//apple_ref/doc/uid/TP40011226-CH1-SW4), the qualifier (`__strong`, `__weak`, `__unsafe_unretained`, `__autoreleasing`) should be placed *in front of the variable* type, e.g., `__weak NSString *text`. 

##Blocks

###How to refer to self inside a block

1. *using the keyword ```self``` directly inside the block*
	
	This should be applied only when the block is not assigned to a property, otherwise it will lead to a retain cycle.
	This is OK:
	
	```objc
	dispatch_block_t completionHandler = ^{
    	NSLog(@"%@", self);
	}
	
	MyViewController *myController = [[MyViewController alloc] init...];
	[self presentViewController:myController
                       animated:YES
                     completion:completionHandler];
	```
	
	This is not OK because it leads to a retain cycle (assuming that the ```completionHandler``` property has the ```copy``` modifier:
	
	```objc
	self.completionHandler = ^{
    	NSLog(@"%@", self);
	}

	MyViewController *myController = [[MyViewController alloc] init...];
	[self presentViewController:myController
   	                   animated:YES
                    completion:self.completionHandler];
	```

2. *declaring a ```__weak``` reference to ```self``` outside the block and referring to the object via this weak reference inside the block* 
	
	This should be applied when the block is assigned to a property and self is referenced only once and the block has a single statement:
	
	```objc
	__weak typeof(self) weakSelf = self;
	
	self.completionHandler = ^{
    	NSLog(@"%@", weakSelf);
	};

	MyViewController *myController = [[MyViewController alloc] init...];
	[self presentViewController:myController
                      animated:YES
                    completion:self.completionHandler];
	```
	
3. *declaring a __weak reference to self outside the block and creating a __strong reference to self using the weak reference inside the block*

	This should be applied when the block is assigned to a property and self is referenced more the once and the block has more than a statement:

	```objc
	__weak typeof(self) weakSelf = self;
	
	myObj.myBlock =  ^{
	
	    __strong typeof(self) strongSelf = weakSelf;
	    
	    if (strongSelf) 
	    {
	      [strongSelf doSomething];
	      [strongSelf doSomethingElse];
	    }
	    else 
	    {
	        // Probably nothing...
	        return;
	    }
	};
	```
	
	Check [this](http://albertodebortoli.github.io/blog/2013/08/03/objective-c-blocks-caveat/) out for more details and the 'why'.

## Naming

Apple naming conventions should be adhered to wherever possible, especially those related to [memory management rules](https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/MemoryMgmt/Articles/MemoryMgmt.html) ([NARC](http://stackoverflow.com/a/2865194/340508)).

Long, descriptive method and variable names are good.

**For example:**

```objc
UIButton *settingsButton;
```

**Not**

```objc
UIButton *setBut;
```

A prefix (e.g. `SB`) should always be used for class names. Constants should be prefixed additionally with a lowercase `k`. Prefixes may be omitted for Core Data entity names. Constants should be camel-case with all words capitalized and prefixed by the related class name for clarity.

**For example:**

```objc
static const NSTimeInterval kSBAlbumViewControllerNavigationFadeAnimationDuration = 0.3;
```

**Not:**

```objc
static const NSTimeInterval fadetime = 1.7;
```

Properties and local variables should be camel-case with the leading word being lowercase.

Instance variables should be camel-case with the leading word being lowercase, and should be prefixed with an underscore. This is consistent with instance variables synthesized automatically by LLVM. **If LLVM can synthesize the variable automatically, then let it.**

**For example:**

```objc
@synthesize descriptiveVariableName = _descriptiveVariableName;
```

**Not:**

```objc
id varnm;
```

## Comments

When they are needed, comments should be used to explain **why** a particular piece of code does something. Any comments that are used must be kept up-to-date or deleted.

```objc
//this is a one line comment
```

```objc
/*
 * Use a block comment if one line is not
 * sufficient to explain yourself.
 *
 * If you need more than three lines,
 * think about in how far your code can be simplified.
 */
```

## init and dealloc

`init` methods should be placed at the top of the implementation, directly after the `@synthesize` and `@dynamic` statements. `dealloc` should be placed directly below the `init` methods of any class.

`init` methods should be structured like this:

```objc
- (instancetype)init 
{    
    if ((self = [super initDesignatedInitializer]))
    {
        // Custom initialization
    }

    return self;
}
```

The designated initializer should be marked with the `NS_DESIGNATED_INITIALIZER` attribute in the header.

**Example:**

```objc
- (instancetype) initWithName: (NSString *) name NS_DESIGNATED_INITIALIZER;
```

If  `NS_DESIGNATED_INITIALIZER` is not available (iOS < 8), you may redefine it for the project:

```objc
// Re-Adds NS_DESIGNATED_INITIALIZER macro, see https://gist.github.com/steipete/9482253
#ifndef NS_DESIGNATED_INITIALIZER
#if __has_attribute(objc_designated_initializer)
#define NS_DESIGNATED_INITIALIZER __attribute((objc_designated_initializer))
#else
#define NS_DESIGNATED_INITIALIZER
#endif
#endif
```


## Literals

`NSString`, `NSDictionary`, `NSArray`, and `NSNumber` literals should be used whenever creating immutable instances of those objects. Pay special care that `nil` values not be passed into `NSArray` and `NSDictionary` literals, as this will cause a crash.

**For example:**

```objc
NSArray *names = @[@"Brian", @"Matt", @"Chris", @"Alex", @"Steve", @"Paul"];
NSDictionary *productManagers = @{@"iPhone" : @"Kate", @"iPad" : @"Kamal", @"Mobile Web" : @"Bill"};
NSNumber *shouldUseLiterals = @YES;
NSNumber *buildingZIPCode = @10018;
```

**Not:**

```objc
NSArray *names = [NSArray arrayWithObjects:@"Brian", @"Matt", @"Chris", @"Alex", @"Steve", @"Paul", nil];
NSDictionary *productManagers = [NSDictionary dictionaryWithObjectsAndKeys: @"Kate", @"iPhone", @"Kamal", @"iPad", @"Bill", @"Mobile Web", nil];
NSNumber *shouldUseLiterals = [NSNumber numberWithBool:YES];
NSNumber *buildingZIPCode = [NSNumber numberWithInteger:10018];
```

## CGRect Functions

When accessing the `x`, `y`, `width`, or `height` of a `CGRect`, always use the [`CGGeometry` functions](http://developer.apple.com/library/ios/#documentation/graphicsimaging/reference/CGGeometry/Reference/reference.html) instead of direct struct member access. From Apple's `CGGeometry` reference:

> All functions described in this reference that take CGRect data structures as inputs implicitly standardize those rectangles before calculating their results. For this reason, your applications should avoid directly reading and writing the data stored in the CGRect data structure. Instead, use the functions described here to manipulate rectangles and to retrieve their characteristics.

**For example:**

```objc
CGRect frame = self.view.frame;

CGFloat x = CGRectGetMinX(frame);
CGFloat y = CGRectGetMinY(frame);
CGFloat width = CGRectGetWidth(frame);
CGFloat height = CGRectGetHeight(frame);
```

**Not:**

```objc
CGRect frame = self.view.frame;

CGFloat x = frame.origin.x;
CGFloat y = frame.origin.y;
CGFloat width = frame.size.width;
CGFloat height = frame.size.height;
```

## Constants

Constants are preferred over in-line string literals or numbers, as they allow for easy reproduction of commonly used variables and can be quickly changed without the need for find and replace. Constants should be declared as `static` constants and not `#define`s unless explicitly being used as a macro.
They must be prefixed with 'k'.

**For example:**

```objc
static NSString * const kSBAboutViewControllerCompanyName = @"Sensorberg GmbH";

static const CGFloat kSBImageThumbnailHeight = 50.0;
```

**Not:**

```objc
#define CompanyName @"Sensorberg GmbH"

#define thumbnailHeight 2
```

## Enumerated Types

When using `enum`s, it is recommended to use the new fixed underlying type specification because it has stronger type checking and code completion. The SDK now includes a macro to facilitate and encourage use of fixed underlying types — `NS_ENUM()`

**Example:**

```objc
typedef NS_ENUM(NSInteger, SBAdRequestState) {
    SBAdRequestStateInactive,
    SBAdRequestStateLoading
};
```

## Bitmasks

When working with bitmasks, use the `NS_OPTIONS` macro.

**Example:**

```objc
typedef NS_OPTIONS(NSUInteger, SBAdCategory) {
  SBAdCategoryAutos      = 1 << 0,
  SBAdCategoryJobs       = 1 << 1,
  SBAdCategoryRealState  = 1 << 2,
  SBAdCategoryTechnology = 1 << 3
};
```

## Private Properties

Private properties should be declared in class extensions (anonymous categories) in the implementation file of a class. Named categories (such as `SBPrivate`, `private`) should never be used unless extending another class.

**For example:**

```objc
@interface SBAdvertisement ()

@property (nonatomic, strong) GADBannerView *googleAdView;
@property (nonatomic, strong) ADBannerView *iAdView;
@property (nonatomic, strong) UIWebView *adXWebView;

@end
```

## Image Naming

Image names should be named consistently to preserve organization and developer sanity. They should be named as one camel case string with a description of their purpose, followed by the un-prefixed name of the class or property they are customizing (if there is one), followed by a further description of color and/or placement, and finally their state.

**For example:**

* `RefreshBarButtonItem` / `RefreshBarButtonItem@2x` and `RefreshBarButtonItemSelected` / `RefreshBarButtonItemSelected@2x`
* `ArticleNavigationBarWhite` / `ArticleNavigationBarWhite@2x` and `ArticleNavigationBarBlackSelected` / `ArticleNavigationBarBlackSelected@2x`.

Images that are used for a similar purpose should be grouped in respective groups in the image catalog.

## Booleans

Since `nil` resolves to `NO` it is unnecessary to compare it in conditions. Never compare something directly to `YES`, because `YES` is defined to 1 and a `BOOL` can be up to 8 bits.

This allows for more consistency across files and greater visual clarity.

**For example:**

```objc
if (!someObject) 
{

}
```

**Not:**

```objc
if (someObject == nil) {
}
```

-----

**For a `BOOL`, here are two examples:**

```objc
if (isAwesome)
if (![someObject boolValue])
```

**Not:**

```objc
if (isAwesome == YES) // Never do this.
if ([someObject boolValue] == NO)
```

-----

If the name of a `BOOL` property is expressed as an adjective, the property can omit the “is” prefix but specifies the conventional name for the get accessor, for example:

```objc
@property (assign, getter=isEditable) BOOL editable;
```
Text and example taken from the [Cocoa Naming Guidelines](https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/CodingGuidelines/Articles/NamingIvarsAndTypes.html#//apple_ref/doc/uid/20001284-BAJGIIJE).

## Singletons

Singleton objects should use a thread-safe pattern for creating their shared instance.
```objc
+ (instancetype)sharedInstance {
   static id sharedInstance = nil;

   static dispatch_once_t onceToken;
   dispatch_once(&onceToken, ^{
      sharedInstance = [[self alloc] init];
   });

   return sharedInstance;
}
```
This will prevent [possible and sometimes prolific crashes](http://cocoasamurai.blogspot.com/2011/04/singletons-your-doing-them-wrong.html).

## Imports

If there is more than one import statement, group the statements [together](http://ashfurrow.com/blog/structuring-modern-objective-c). Commenting each group is optional. Import system stuff first then your project's header.

Note: For modules use the [@import](http://clang.llvm.org/docs/Modules.html#using-modules) syntax.

```objc
// Frameworks
@import QuartzCore;

#import <tgmath.h>

// Models
#import "SBUser.h"

// Views
#import "SBButton.h"
#import "SBUserView.h"
```

## Class header file structure

The header file of a class should be structured as follows.

1. Imports
2. Forward declarations (use them as much as possible to speed up compilation)
3. Constant declarations
4. Delegate protocol definitions
5. Class Declaration

```objc

@import Framework;

#import <SystemImport.h>

#import "ProjectImport.h"

@class ClassForwardDeclaration
@protocol ProtocolForwardDeclaration

#pragma mark - constatnts

extern NSString * const kConstant;

#pragma mark - delegates

@protocol SBAwesomeDelegate

- (void)justDoIt;

@end

#pragma mark -

@interface SBClass : NSObject <SBSomeProtocol>

//properties

//methods

@end

```

## Class implementation file structure

The implementation file of a class should be structured as follows.

1. Imports
2. Constant definitions
3. Private declarations
4. Implementation
	5. @synthesize
	6. initializers
	7. dealloc
	8. public method implementations
	9. private method implementations

```objc
#import <SystemStuff.h>

#import "ProjectStuff.h"

#pragma mark - constants

NSString * const kConstant = @"OMFG";

#pragma mark - private

@interface SBClass ()
//private properties
@end

#pragma mark - 

@implementation SBClass

@synthesize property = _property;

- (id)init
{

}

- (void)dealloc
{

}

#pragma mark - public

//implementations for public methods

#pragma mark - private

//implementations for private methods

@end
```


## Xcode project

The physical files should be kept in sync with the Xcode project files in order to avoid file sprawl. Any Xcode groups created should be reflected by folders in the filesystem. Code should be grouped not only by type, but also by feature for greater clarity.

When possible, always turn on "Treat Warnings as Errors" in the target's Build Settings and enable as many [additional warnings](http://boredzo.org/blog/archives/2009-11-07/warnings) as possible. If you need to ignore a specific warning, use [Clang's pragma feature](http://clang.llvm.org/docs/UsersManual.html#controlling-diagnostics-via-pragmas).

###Code organization

[This document](CodeStructure.md) describes how we organize our code.

## Testing

We encourage you to write unit tests. Use dependency injection where possible and separate business logic from UI-Logic. Views and ViewControllers should contain as view logic as possible. The Datasource for UITableViews and UICollectionViews should be always extracted to an external, well tested class.

Use code coverage tools to make sure you test as much as possible.

### OCMock Style

Prefer OCMock functions over OCMock methods, because OCMock specific
code is better distinguishable from application code:

:+1: `OCMStub([mock someMethod]).andReturn(anObject);`

:-1: `[[[mock stub] andReturn:anObject] someMethod];`


# Other Objective-C Style Guides

If ours doesn't fit your tastes, have a look at some other style guides:

* [Google](http://google-styleguide.googlecode.com/svn/trunk/objcguide.xml)
* [GitHub](https://github.com/github/objective-c-conventions)
* [Adium](https://trac.adium.im/wiki/CodingStyle)
* [Sam Soffes](https://gist.github.com/soffes/812796)
* [CocoaDevCentral](http://cocoadevcentral.com/articles/000082.php)
* [Luke Redpath](http://lukeredpath.co.uk/blog/my-objective-c-style-guide.html)
* [Marcus Zarra](http://www.cimgf.com/zds-code-style-guide/)
