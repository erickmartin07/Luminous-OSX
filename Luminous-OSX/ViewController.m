//
//  ViewController.m
//  Luminous-OSX
//
//  Created by Erick Martin on 11/11/15.
//  Copyright © 2015 Erick Martin. All rights reserved.
//

#import "ViewController.h"
#import "VariableModel.h"

@implementation ViewController

@synthesize modelNameTextField, inputTextView, resultTextView, resultArray;
@synthesize primaryKeyTextField;

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (IBAction)changeState:(id)sender {
    [self generateTapped:nil];
}

- (void)writeStringToFile:(NSString*)aString withFileName:(NSString *)fileName{
    
    // Build the path, and create if needed.
    NSString* filePath = [NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* fileAtPath = [filePath stringByAppendingPathComponent:fileName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileAtPath]) {
        [[NSFileManager defaultManager] createFileAtPath:fileAtPath contents:nil attributes:nil];
    }
    
    // The main act...
    [[aString dataUsingEncoding:NSUTF8StringEncoding] writeToFile:fileAtPath atomically:NO];
}


- (IBAction)generateTapped:(id)sender {
    
    [self arrayOfVariableWithString:inputTextView.string];
    
    [self writeStringToFile:[self createModelHeader] withFileName:[NSString stringWithFormat:@"%@.h", modelNameTextField.stringValue]];
    [self writeStringToFile:[self createModelMain] withFileName:[NSString stringWithFormat:@"%@.m", modelNameTextField.stringValue]];

    resultTextView.string = [self createDatabaseStringWithIdString:primaryKeyTextField.stringValue];
    
    [[NSPasteboard generalPasteboard] clearContents];
    [[NSPasteboard generalPasteboard] setString:resultTextView.string forType:NSStringPboardType];
    
}

-(NSArray *)arrayOfVariableWithString:(NSString *)inputStr{
    self.resultArray = [NSMutableArray array];
    
    NSMutableArray *data = [[inputStr componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]] mutableCopy];
    
    for(NSString *string in data){
        VariableModel *varModel = [[VariableModel alloc] initWithString:string];
        
        if(![varModel.variableName isEqualToString:@""] && varModel.variableName){
            [resultArray addObject:varModel];
        }
    }
    return resultArray;
}

-(NSString *)createModelMain{
    
    NSString *dictionaryString = @"";
    NSString *fmResultString = @"";
    NSString *encodeResultString = @"";
    NSString *decodeResultString = @"";
    
    for(VariableModel *varModel in resultArray){
        
        //Dict Result
        NSString *dictString = [NSString stringWithFormat:
                                @"            self.%@ = [self %@:jsonDict[@\"%@\"]];\n", varModel.variableName, varModel.variableDict, varModel.variableName];
        
        if([varModel.variableType isEqualToString:@"NSDate"]){
            dictString = [NSString stringWithFormat:
                                @"            self.%@ = [jsonDict objectForKey:@\"%@\"];\n", varModel.variableName, varModel.variableName];
        }
        
        
        dictionaryString = [dictionaryString stringByAppendingString:dictString];

        if(![varModel.variableType isEqualToString:@"NSArray"] && ![varModel.variableType isEqualToString:@"NSSet"]){
            
            //FM Result
            NSString *fmString = [NSString stringWithFormat:
                                  @"            self.%@ = [result %@:@\"%@\"];\n", varModel.variableName, varModel.variableFMResultSet, varModel.variableName];
            
            fmResultString = [fmResultString stringByAppendingString:fmString];
            
            //Decode Result
            NSString *decodeStr = [NSString stringWithFormat:
                                   @"           self.%@ = [decoder %@:@\"%@\"];\n", varModel.variableName, varModel.variableDecode, varModel.variableName];
            decodeResultString = [decodeResultString stringByAppendingString:decodeStr];
            
            
            //Encode Result
            NSString *encodeStr = [NSString stringWithFormat:
                                   @"           [encoder %@:self.%@ forKey:@\"%@\"];\n", varModel.variableEncode, varModel.variableName, varModel.variableName];
            encodeResultString = [encodeResultString stringByAppendingString:encodeStr];
        }
    }
    
    NSString *resultString = [NSString stringWithFormat:@"//Copy BaseModel From Spylight\n\n\n"
                              "#import \"%@.h\"\n"
                              "@implementation %@\n\n"
                              "-(id)initWithDictionary:(NSDictionary *)jsonDict{\n"
                              "     if(self=[super init]){\n"
                              "%@"
                              "     }\n"
                              "     return self;\n}\n"
                              "\n\n"
                              "-(id)initWithFMResultSet:(FMResultSet *)result{\n"
                              "    if(self = [super init]){\n"
                              "%@"
                              "     }\n"
                              "     return self;\n}\n"
                              "\n\n"
                              "-(id)initWithCoder:(NSCoder *)decoder{\n"
                              "     if(self=[super init]){\n"
                              "%@"
                              "     }\n"
                              "     return self;\n}\n"
                              "\n\n"
                              "-(void)encodeWithCoder:(NSCoder *)encoder{\n"
                              @"%@"
                              "}\n"
                              "\n@end"
                              ,modelNameTextField.stringValue, modelNameTextField.stringValue, dictionaryString, fmResultString, decodeResultString, encodeResultString];
    
    return resultString;
}

-(NSString *)createModelHeader{
    NSString *variableString = @"";
    
    for(VariableModel *varMod in resultArray){
        
        if(![varMod.variableName isEqualToString:@""] && varMod.variableName){
            NSString *varInString = [NSString stringWithFormat:@"@property (nonatomic, %@) %@%@%@;\n", varMod.variableAssignType, varMod.variableType, varMod.variablePrimitive, varMod.variableName];
        
            variableString = [variableString stringByAppendingString:varInString];
        }
    }
    
    
    NSString *resultString = [NSString stringWithFormat:@""
                              "#import <Foundation/Foundation.h>\n"
                              "#import <CoreData/CoreData.h>\n\n\n"
                              "@interface %@ : BaseModel\n\n"
                              "-(id)initWithDictionary:(NSDictionary *)jsonDict;\n"
                              "-(id)initWithFMResultSet:(FMResultSet *)result;\n"
                              "-(id)initWithCoder:(NSCoder *)decoder;\n"
                              "-(void)encodeWithCoder:(NSCoder *)encoder;\n\n"
                              "%@"
                              "\n@end", modelNameTextField.stringValue, variableString];
    
    return resultString;
    
}

-(NSString *)createDatabaseStringWithIdString:(NSString *)idString{
    
    NSString *variableNameString = @"";
    NSString *questionMarkString = @"";
    NSString *objectString = @"";
    
    for(int i = 0; i < resultArray.count; i++){
        
        VariableModel *varModel = (VariableModel *)resultArray[i];
        
        if(![varModel.variableType isEqualToString:@"NSArray"] && ![varModel.variableType isEqualToString:@"NSSet"]){
            variableNameString = [variableNameString stringByAppendingString:
                                  [NSString stringWithFormat:@"%@%@", varModel.variableName, i<resultArray.count-1?@",":@""]];
            
            questionMarkString = [questionMarkString stringByAppendingString:
                                  [NSString stringWithFormat:@"?%@", i<resultArray.count-1?@",":@""]];
            
            objectString = [objectString stringByAppendingString:
                            [NSString stringWithFormat:@"%@%@",varModel.variableDefault, i<resultArray.count-1?@",":@""]
                            ];
        }
    }
    
    NSString *updateStr = [NSString stringWithFormat:@"         "
                           "success = [db executeUpdate:@\"INSERT INTO %@(%@) values(%@)\", "
                           "%@];", modelNameTextField.stringValue, variableNameString, questionMarkString, objectString];
    
    NSString *resultString = [NSString stringWithFormat:@"#pragma mark - %@\n\n"
                              
                              "-(BOOL)update%@:(%@ *)obj{\n"
                              "     __block BOOL success = NO;\n\n"
                              "     [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {\n\n"
                              "         [db executeUpdate:@\"DELETE FROM '%@' WHERE %@=?\",@(obj.%@)];\n"
                              "%@\n"
                              "     }];\n"
                              "     return success;\n"
                              "}\n\n"
                              
                              "-(NSArray *)getAll%@s{\n"
                              "     __block NSMutableArray *result = [NSMutableArray array];\n\n"
                              "     [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {\n\n"
                              "         FMResultSet *rs = [db executeQuery:@\"SELECT * FROM %@\"];\n\n"
                              "         while([rs next]) {\n"
                              "             %@ *%@ = [[%@ alloc] initWithFMResultSet:rs];\n"
                              "             [result addObject:%@];\n"
                              "         }\n"
                              "     }];\n\n"
                              "     return result;\n"
                              "}\n\n"
                              
                              "-(void)deleteAll%@s{\n"
                              "     [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {\n"
                              "         [db executeUpdate:@\"DELETE FROM %@\"];\n"
                              "     }];\n"
                              "}\n\n\n"
                              
                              "-(%@ *)get%@ById:(NSString *)primaryId{\n"
                              "     __block %@ *result = nil;\n\n"
                              "     [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {\n\n"
                              "         NSString *queryString = [NSString stringWithFormat:@\"SELECT * FROM %@ WHERE %@='%%@'\", primaryId];\n"
                              "         FMResultSet *rs = [db executeQuery:queryString];\n"
                              "         if([rs next]) {\n"
                              "             result = [[%@ alloc] initWithFMResultSet:rs];\n"
                              "         }\n"
                              "     }];\n\n"
                              "     return result;\n"
                              "}",
                              
                              //pragma mark
                              modelNameTextField.stringValue,
                              
                              //for UpdateObject
                              modelNameTextField.stringValue, modelNameTextField.stringValue,
                              modelNameTextField.stringValue, idString, idString, updateStr,
                              
                              //for GetAllObjects
                              modelNameTextField.stringValue,
                              modelNameTextField.stringValue,
                              modelNameTextField.stringValue, [modelNameTextField.stringValue lowercaseString], modelNameTextField.stringValue,
                              [modelNameTextField.stringValue lowercaseString],
                              
                              //for DeleteAllObjects
                              modelNameTextField.stringValue, modelNameTextField.stringValue,
                              
                              //for GetObjectById
                              modelNameTextField.stringValue, modelNameTextField.stringValue,
                              modelNameTextField.stringValue,
                              modelNameTextField.stringValue, idString,
                              modelNameTextField.stringValue
                              ];
    
    return resultString;
}

@end
