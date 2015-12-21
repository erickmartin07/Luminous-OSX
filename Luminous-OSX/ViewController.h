//
//  ViewController.h
//  Luminous-OSX
//
//  Created by Erick Martin on 11/11/15.
//  Copyright © 2015 Erick Martin. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum{
    StateTypeModelHeader = 0,
    StateTypeModelMain = 1,
    StateTypeDatabase = 2
}StateType;

@interface ViewController : NSViewController

@property (strong) IBOutlet NSTextField *modelNameTextField;
@property (strong) IBOutlet NSTextField *primaryKeyTextField;
@property (strong) IBOutlet NSTextView *inputTextView;
@property (strong) IBOutlet NSTextView *resultTextView;
@property (strong) IBOutlet NSSegmentedControl *stateSegmented;
@property (nonatomic, retain) NSMutableArray *resultArray;

@property (strong) IBOutlet NSButton *generateButton;
- (IBAction)generateTapped:(id)sender;
- (IBAction)changeState:(id)sender;

@end

