#import "DWMediaSubtitle.h"

static NSString *const kIndex = @"kIndex";
static NSString *const kStart = @"kStart";
static NSString *const kEnd = @"kEnd";
static NSString *const kText = @"kText";

@interface DWMediaSubtitle ()

@property (strong, nonatomic)NSString *srtPath;
@property (strong, nonatomic)NSMutableDictionary *subtitles;

@end

@implementation DWMediaSubtitle

- (id)initWithSRTPath:(NSString *)path
{
    self = [super init];
    if (self) {
        _srtPath = [path copy];
    }
    
    return self;
}


- (void)requestSTRURL:(NSURL *)URL didComplete:(void(^)(NSError *error,NSMutableDictionary *dictionary))completeBlock{
   
    
   NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSString *string=[[NSMutableString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            NSScanner *scanner = [NSScanner scannerWithString:string];
            
            self.subtitles = [NSMutableDictionary dictionary];
            
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
                
                
                NSRegularExpression *regExp = [NSRegularExpression regularExpressionWithPattern:@"[<|\\{][^>|\\^}]*[>|\\}]"
                                                                                        options:  NSRegularExpressionCaseInsensitive
                                                                                          error:nil];
                
                
                textString = [regExp stringByReplacingMatchesInString:textString
                                                              options:0
                                                                range:NSMakeRange(0, textString.length)
                                                         withTemplate:@""];
                
                
                NSTimeInterval startInterval = [self timeFromString:startString];
                NSTimeInterval endInterval = [self timeFromString:endString];
                NSDictionary *tempInterval = @{
                                               kIndex : indexString,
                                               kStart : @(startInterval),
                                               kEnd : @(endInterval),
                                               kText : textString ? textString : @""
                                               };
                [self.subtitles setObject:tempInterval
                                   forKey:indexString];
                
            }
            
            if (completeBlock) {
                
                completeBlock(nil,self.subtitles);
            }
            
            
        }else{
            
            if (completeBlock) {
                
                completeBlock(error,nil);
            }
        }
    }];
    [dataTask resume];
    
    
    
}


- (BOOL)start
{
    if (!self.srtPath) {
        [self setErrorWithString:@"path (null)"];
        return NO;
    }
    
    return [self parse];
}

- (BOOL)parse
{
    NSError *error = nil;
    NSString *content = [NSString stringWithContentsOfFile:self.srtPath
                                                  encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        self.error = error;
        return NO;
    }
    
    NSScanner *scanner = [NSScanner scannerWithString:content];
    
    self.subtitles = [NSMutableDictionary dictionary];
    
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
        
        NSError *error = nil;
        NSRegularExpression *regExp = [NSRegularExpression regularExpressionWithPattern:@"[<|\\{][^>|\\^}]*[>|\\}]"
                                                                                options:NSRegularExpressionCaseInsensitive
                                                                                  error:&error];
        if (error) {
            self.error = error;
            return NO;
        }
        
        textString = [regExp stringByReplacingMatchesInString:textString
                                                      options:0
                                                        range:NSMakeRange(0, textString.length)
                                                 withTemplate:@""];
        
        
        NSTimeInterval startInterval = [self timeFromString:startString];
        NSTimeInterval endInterval = [self timeFromString:endString];
        NSDictionary *tempInterval = @{
                                       kIndex : indexString,
                                       kStart : @(startInterval),
                                       kEnd : @(endInterval),
                                       kText : textString ? textString : @""
                                       };
        [self.subtitles setObject:tempInterval
                                forKey:indexString];
        
    }
    NSLog(@"self.subtitles: %@", self.subtitles);
    
    return YES;
}

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
    NSArray *objectsFound = [[self.subtitles allValues] filteredArrayUsingPredicate:initialPredicate];
    NSDictionary *lastFounded = (NSDictionary *)[objectsFound lastObject];
    
    if (lastFounded) {
        return [lastFounded objectForKey:kText];
    }
    
    return nil;
}

- (void)setErrorWithString:(NSString *)description
{
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:description forKey:NSLocalizedDescriptionKey];
    self.error = [NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:userInfo];
}

@end
