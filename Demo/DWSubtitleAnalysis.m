//
//  DWSubtitleAnalysis.m
//  Demo
//
//  Created by zwl on 2019/1/8.
//  Copyright © 2019 com.bokecc.www. All rights reserved.
//

#import "DWSubtitleAnalysis.h"

static NSString *const kIndex = @"kIndex";
static NSString *const kStart = @"kStart";
static NSString *const kEnd = @"kEnd";
static NSString *const kText = @"kText";

@interface DWSubtitleAnalysis ()

@property(nonatomic,copy)NSURL * srtUrl;
@property(nonatomic,strong)NSMutableDictionary * responseDict;

@end

@implementation DWSubtitleAnalysis

-(instancetype)initWithSTRURL:(NSURL *)URL
{
    if (self == [super init]) {
        
        self.encodeing = 0;
        self.srtUrl = URL;
        
    }
    return self;
}

-(void)parse
{
    NSURLRequest *request = [NSURLRequest requestWithURL:self.srtUrl];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            
            /*
             GB 18030 == -2147482062
             */
            NSString *string=[[NSMutableString alloc] initWithData:data encoding:self.encodeing == 0 ? NSUTF8StringEncoding : -2147482062];
            
            NSScanner *scanner = [NSScanner scannerWithString:string];
            
            self.responseDict = [NSMutableDictionary dictionary];
            
            while (!scanner.isAtEnd) {
                
                NSString *indexString;
                [scanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet]
                                        intoString:&indexString];
                
                NSString *startString;
                [scanner scanUpToString:@" --> " intoString:&startString];
                [scanner scanString:@"-->" intoString:NULL];
                
                NSString *endString;
                [scanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet]
                                        intoString:&endString];
                
                
                
                NSString *textString;
                [scanner scanUpToString:@"\r\n\r\n" intoString:&textString];
                
                textString = [textString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                
                
                @try {
                    
                    NSRegularExpression *regExp = [NSRegularExpression regularExpressionWithPattern:@"[<|\\{][^>|\\^}]*[>|\\}]"
                                                                                            options:  NSRegularExpressionCaseInsensitive
                                                                                              error:nil];
                    
                    
                    textString = [regExp stringByReplacingMatchesInString:textString
                                                                  options:0
                                                                    range:NSMakeRange(0, textString.length)
                                                             withTemplate:@""];
                    
                } @catch (NSException *exception) {
                    
                } @finally {
                    
                }
                
                
                
                
                NSTimeInterval startInterval = [self timeFromString:startString];
                NSTimeInterval endInterval = [self timeFromString:endString];
                NSDictionary *tempInterval = @{
                                               kIndex : indexString,
                                               kStart : @(startInterval),
                                               kEnd : @(endInterval),
                                               kText : textString ? textString : @""
                                               };
                [self.responseDict setObject:tempInterval
                                      forKey:indexString];
                
            }
            
            
            
        }else{
            
        }
    }];
    [dataTask resume];
    
}

//-(NSDictionary *)subtitles
//{
//    return _responseDict;
//}

- (NSTimeInterval)timeFromString:(NSString *)timeString
{
    NSScanner *scanner = [NSScanner scannerWithString:timeString];
    
    int h, m, s, c;
    [scanner scanInt:&h];
    [scanner scanString:@":" intoString:NULL];
    [scanner scanInt:&m];
    [scanner scanString:@":" intoString:NULL];
    [scanner scanInt:&s];
    [scanner scanString:@"," intoString:NULL];
    [scanner scanInt:&c];
    
    return (h * 3600) + (m * 60) + s + (c / 1000.0);
}

- (NSString *)searchWithTime:(NSTimeInterval)currentPlaybackTime
{
    NSPredicate *initialPredicate = [NSPredicate predicateWithFormat:@"(%@ >= %K) AND (%@ <= %K)", @(currentPlaybackTime), kStart, @(currentPlaybackTime), kEnd];
    NSArray *objectsFound = [[self.responseDict allValues] filteredArrayUsingPredicate:initialPredicate];
    NSDictionary *lastFounded = (NSDictionary *)[objectsFound lastObject];
    
    if (lastFounded) {
        return [lastFounded objectForKey:kText];
    }
    
    return nil;
}


@end
