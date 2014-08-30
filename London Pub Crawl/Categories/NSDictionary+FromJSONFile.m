//
//  NSDictionary+FromJSONFile.m
//  PubCrawlLDN
//
//  Created by Daniel Hough on 08/04/2014.
//  Copyright (c) 2014 LondonPubCrawl. All rights reserved.
//

#import "NSDictionary+FromJSONFile.h"

@implementation NSDictionary (FromJSONFile)

+ (NSDictionary *)dictionaryWithContentsOfJSONFile:(NSString *)path {
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:[path stringByDeletingPathExtension] ofType:[path pathExtension]];
//    
//    //création d'un string avec le contenu du JSON
//    NSString *myJSON = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
//    
//    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[myJSON dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
//    return json;
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[path stringByDeletingPathExtension] ofType:[path pathExtension]];
    NSData* data = [NSData dataWithContentsOfFile:filePath];
    NSError *error;
    id result = [NSJSONSerialization JSONObjectWithData:data
                                                options:kNilOptions error:&error];
    // Be careful here. You add this as a category to NSDictionary
    // but you get an id back, which means that result
    // might be an NSArray as well!
    if (error != nil) return nil;
    return result;
}

@end
