//
//  Copyright (c) 2011, 2012 Andreas Arvanitis.  All rights reserved.
//
//  Developed by: Andreas (Andy) Arvanitis
//                The Eero Programming Language
//                http://eerolanguage.org
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal with the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//    1. Redistributions of source code must retain the above copyright notice,
//       this list of conditions and the following disclaimers.
//
//    2. Redistributions in binary form must reproduce the above copyright
//       notice, this list of conditions and the following disclaimers in the
//       documentation and/or other materials provided with the distribution.
//
//    3. Neither the names of Andreas Arvanitis, The Eero Programming Language,
//       nor the names of its contributors may be used to endorse
//       or promote products derived from this Software without specific prior
//       written permission.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
//  CONTRIBUTORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  WITH THE SOFTWARE.

#import <Cocoa/Cocoa.h>
#import "XCFixin.h"


@interface XCFixin_XCodeCurrentLineHighlighter : NSObject
{
  @private
    Class         sourceEditorViewClass;
    NSDictionary* highlightColorAttributes;
    NSColor *pColor;
}
@end


@implementation XCFixin_XCodeCurrentLineHighlighter

static NSString* pAttributeName = @"XCFixinTempAttribute10";

- (id) init {
  self = [super init];
  if (self) {
    sourceEditorViewClass = Nil;    
    highlightColorAttributes = nil;
    pColor = nil;

    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    
    if ([NSRunningApplication currentApplication].finishedLaunching) {
      [self applicationReady:nil];
    }
    else {
      [notificationCenter addObserver: self
                             selector: @selector( applicationReady: )
                                 name: NSApplicationDidFinishLaunchingNotification
                               object: nil];

    }

    [notificationCenter addObserver: self
                           selector: @selector( frameChanged: )
                               name: NSViewFrameDidChangeNotification
                             object: nil];

    [notificationCenter addObserver: self
                           selector: @selector( selectionChanged: )
                               name: NSTextViewDidChangeSelectionNotification
                             object: nil];
  }
  return self;
}

- (void) dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSString*) highlightColorDefaultsKeyName {
  return @"CurrentLineHighlightColor";
}

- (NSString*) highlightColorMenuItemTitle {
  return @"Current Line Highlight Color...";
}

- (void) loadHighlightColor {
  NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];   

  NSData* colorAsData = [userDefaults objectForKey:[self highlightColorDefaultsKeyName]];

  if ( colorAsData != nil ) {
    NSColor* color = [NSKeyedUnarchiver unarchiveObjectWithData:colorAsData];
    pColor = color;

    highlightColorAttributes = 
        [NSMutableDictionary dictionaryWithObjectsAndKeys: color,
                                                    NSBackgroundColorAttributeName,
                                                    nil];
  }
}

- (void) saveHighlightColor:(NSColor*)color {
  NSData* colorAsData = [NSKeyedArchiver archivedDataWithRootObject:color];
  NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
  [userDefaults setObject:colorAsData forKey:[self highlightColorDefaultsKeyName]];
  pColor = color;
}

- (void) highlightLineInView:(id)view containingRange:(NSRange)range {
  @try {
    if (pColor)
    {
      NSString* pString = [view string];
      
      NSRange StringRange;
      StringRange.location = 0;
      StringRange.length = [pString length];
      
      NSRange CommonRange = NSIntersectionRange(StringRange, range);
      if (CommonRange.location == 0 && CommonRange.length == 0)
        return;
      NSRange LineRange = [pString lineRangeForRange:range];
      NSLayoutManager *layoutManager = [view layoutManager];
      [layoutManager addTemporaryAttribute: pAttributeName value: pColor forCharacterRange: LineRange];
      XCFixinUpdateTempAttributes(layoutManager, LineRange);
    }    
  }
  @catch ( NSException* exception ) {
    if ( [[exception name] isNotEqualTo:NSRangeException] ) {
      @throw exception;
    }
  }
  
}

- (void) removeHighlightFromLineInView:(id)view containingRange:(NSRange)range {
  @try {
    NSString* pString = [view string];
    
    NSRange StringRange;
    StringRange.location = 0;
    StringRange.length = [pString length];
    
    NSRange CommonRange = NSIntersectionRange(StringRange, range);
    if (CommonRange.location == 0 && CommonRange.length == 0)
      return;
    NSRange LineRange = [pString lineRangeForRange: CommonRange];
    NSLayoutManager *layoutManager = [view layoutManager];
    [layoutManager removeTemporaryAttribute: pAttributeName forCharacterRange: LineRange];
    XCFixinUpdateTempAttributes(layoutManager, LineRange);
  }
  @catch ( NSException* exception ) {
  if ( [[exception name] isNotEqualTo:NSRangeException] ) {
      @throw exception;
    }
  }
}

- (void) selectHighlightColor:(id)sender {
  NSColorPanel *colorPanel = [NSColorPanel sharedColorPanel];

  NSColor* color = [highlightColorAttributes objectForKey:NSBackgroundColorAttributeName];
  [colorPanel setColor:color];
  [colorPanel setTarget:self];
  [colorPanel setAction:@selector(changeColor:)];

  [[NSNotificationCenter defaultCenter] addObserver: self
                                           selector: @selector( colorPanelWillClose: )
                                               name: NSWindowWillCloseNotification
                                             object: colorPanel];
  [NSApp orderFrontColorPanel:nil];
}

- (IBAction)changeColor:(id)sender {
  NSColorPanel* colorPanel = [NSColorPanel sharedColorPanel];

  highlightColorAttributes = 
      [NSMutableDictionary dictionaryWithObjectsAndKeys: [colorPanel color],
                                                  NSBackgroundColorAttributeName, 
                                                  nil];
  [self saveHighlightColor:[colorPanel color]];
                                                    
  // Update window size (grow then back to what it was) in order to cause frame
  // change even. This is because we can't have a guaranteed valid reference to
  // the view. Kind of silly, but better than crashing.
  //
  id window = [NSApp mainWindow];
  NSRect frame = [window frame];      
  NSRect tempFrame = NSMakeRect( frame.origin.x, 
                                 frame.origin.y, 
                                 frame.size.width, 
                                 frame.size.height + 1.0 );

  [window setFrame:tempFrame display:YES];
  [window setFrame:frame display:YES];
}

- (void) colorPanelWillClose:(NSNotification*)notification {
  NSColorPanel *colorPanel = [NSColorPanel sharedColorPanel];

  [[NSNotificationCenter defaultCenter] removeObserver: self 
                                                  name: NSWindowWillCloseNotification 
                                                object: colorPanel];
  [colorPanel setTarget:nil];
  [colorPanel setAction:nil];
}

- (void) addItemToApplicationMenu {
  NSMenu* mainMenu = [NSApp mainMenu];
  NSMenu* editorMenu = [[mainMenu itemAtIndex:[mainMenu indexOfItemWithTitle:@"Editor"]] submenu];

//  XCFixinLog(@"%s: editor menu: %p.\n",__FUNCTION__, editorMenu);

  if ( editorMenu != nil) {
    if ([editorMenu itemWithTitle:[self highlightColorMenuItemTitle]] == nil) {
      XCFixinLog(@"%s: editor menu added.\n",__FUNCTION__);

      NSMenuItem* newItem = [NSMenuItem new];

      [newItem setTitle:[self highlightColorMenuItemTitle]];  // note: not localized
      [newItem setTarget:self];
      [newItem setAction:@selector( selectHighlightColor: )];
      [newItem setEnabled:YES];

      [editorMenu insertItem:newItem atIndex:[editorMenu numberOfItems]];
    }
/*    else
        XCFixinLog(@"%s: editor menu already added.\n",__FUNCTION__);*/
  }
  else
    XCFixinLog(@"%s: failed to add editor menu.\n",__FUNCTION__);
}

- (void) applicationReady:(NSNotification*)notification {
  sourceEditorViewClass = NSClassFromString(@"DVTSourceTextView");
  [self loadHighlightColor];
}

- (void) frameChanged:(NSNotification*)notification {
  id view = [notification object];

  //XCFixinLog(@"%s: frameChanged.\n",__FUNCTION__);
  
  if ([view isMemberOfClass: sourceEditorViewClass]) {

    [self addItemToApplicationMenu];

    [self highlightLineInView:view containingRange:[view selectedRange]];
  }
}

- (void) selectionChanged:(NSNotification*)notification {
  id view = [notification object];
  id OldSelectedRange = [[notification userInfo] objectForKey:@"NSOldSelectedCharacterRange"];
  if (OldSelectedRange != nil && view != nil && [view isMemberOfClass:sourceEditorViewClass]) {
    NSRange oldRange = [OldSelectedRange rangeValue];
    NSRange newRange = [view selectedRange];

    [self removeHighlightFromLineInView:view containingRange:oldRange];

    if ( newRange.length == 0 ) { // not a multi-line selection
      [self highlightLineInView:view containingRange:newRange];
    }
  }
}

+ (void) pluginDidLoad: (NSBundle*)plugin
{
  // Singleton instance
  static id highlighter = nil;

  XCFixinPreflight(false);

  highlighter = [[XCFixin_XCodeCurrentLineHighlighter alloc] init];            

  if (!highlighter) {
    XCFixinLog(@"%s: highlighter init failed.\n",__FUNCTION__);
  }

  XCFixinPostflight();
}

@end
