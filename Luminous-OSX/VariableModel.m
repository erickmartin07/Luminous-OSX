//
//  VariableModel.m
//  Luminous
//
//  Created by Erick Martin on 7/23/15.
//  Copyright (c) 2015 Erick Martin. All rights reserved.
//

#import "VariableModel.h"

@implementation VariableModel

@synthesize variableName, variableType, variableAssignType, variablePrimitive;
@synthesize variableDict, variableDecode, variableEncode, variableFMResultSet;
@synthesize variableDefault;

-(id)initWithString:(NSString *)str{
    if(self = [super init]){
        
        NSArray *array = [str componentsSeparatedByString:@" "];
        if(array.count == 2){
            self.variableType = array[0];
            
            NSString *compareStr = [array[0] lowercaseString];
            self.variableName = array[1];
            self.variablePrimitive = @" *";
            self.variableAssignType = @"retain";
            self.variableDict = @"idFromAnyObject";
            self.variableDecode = @"decodeObjectForKey";
            self.variableEncode = @"encodeObject";
            self.variableDefault = [NSString stringWithFormat:@"obj.%@",self.variableName];
            
            if([compareStr isEqualToString:@"nsstring"]){
                
                self.variableType = @"NSString";
                self.variableAssignType = @"copy";
                self.variablePrimitive = @" *";
                self.variableDict = @"stringFromJSONObject";
                self.variableFMResultSet = @"stringForColumn";
                
            }else if([compareStr isEqualToString:@"nsdate"]){
                
                self.variableType = @"NSDate";
                self.variableFMResultSet = @"dateForColumn";
                
            }else if([compareStr isEqualToString:@"nsarray"]){
                
                self.variableType = @"NSArray";
                
            }else if([compareStr isEqualToString:@"nsset"]){
                
                self.variableType = @"NSSet";
                
            }else if([compareStr isEqualToString:@"int"] || [compareStr isEqualToString:@"nsnumber"] || [compareStr isEqualToString:@"nsinteger"]){
                
                self.variableType = @"int";
                self.variableAssignType = @"assign";
                self.variablePrimitive = @" ";
                self.variableDict = @"intFromJSONObject";
                self.variableFMResultSet = @"intForColumn";
                self.variableDecode = @"decodeIntForKey";
                self.variableEncode = @"encodeInt";
                self.variableDefault = [NSString stringWithFormat:@"@(obj.%@)",self.variableName];
                
            }else if([compareStr isEqualToString:@"float"]){
                
                self.variableType = @"float";
                self.variableAssignType = @"assign";
                self.variablePrimitive = @" ";
                self.variableDict = @"floatFromJSONObject";
                self.variableFMResultSet = @"doubleForColumn";
                self.variableDecode = @"decodeFloatForKey";
                self.variableEncode = @"encodeFloat";
                self.variableDefault = [NSString stringWithFormat:@"@(obj.%@)",self.variableName];
                
            }else if([compareStr isEqualToString:@"bool"]){
                
                self.variableType = @"bool";
                self.variableAssignType = @"assign";
                self.variablePrimitive = @" ";
                self.variableDict = @"boolFromJSONObject";
                self.variableFMResultSet = @"boolForColumn";
                self.variableDecode = @"decodeBoolForKey";
                self.variableEncode = @"encodeBool";
                self.variableDefault = [NSString stringWithFormat:@"@(obj.%@)",self.variableName];
                
            }
        }
        
    }
    return self;
}

@end
