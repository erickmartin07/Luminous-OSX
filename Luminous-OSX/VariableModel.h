//
//  VariableModel.h
//  Luminous
//
//  Created by Erick Martin on 7/23/15.
//  Copyright (c) 2015 Erick Martin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VariableModel : NSObject

@property(nonatomic, copy) NSString *variableName;
@property(nonatomic, copy) NSString *variableType;
@property(nonatomic, copy) NSString *variableAssignType;
@property(nonatomic, copy) NSString *variablePrimitive;
@property(nonatomic, copy) NSString *variableDict;
@property(nonatomic, copy) NSString *variableFMResultSet;
@property(nonatomic, copy) NSString *variableEncode;
@property(nonatomic, copy) NSString *variableDecode;
@property(nonatomic, copy) NSString *variableDefault;

-(id)initWithString:(NSString *)str;
@end
