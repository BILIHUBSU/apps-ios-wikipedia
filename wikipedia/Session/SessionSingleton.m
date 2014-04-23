//  Created by Monte Hurd on 12/6/13.
//  Copyright (c) 2013 Wikimedia Foundation. Provided under MIT-style license; please copy and modify!

#import "SessionSingleton.h"

@implementation SessionSingleton

+ (SessionSingleton *)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {

        self.keychainCredentials = [[KeychainCredentials alloc] init];
        self.zeroConfigState = [[ZeroConfigState alloc] init];
        self.zeroConfigState.disposition = false;

//TODO: figure out what to do with these:
        // Wiki language character sets that iOS doesn't seem to render properly...
        self.unsupportedCharactersLanguageIds = [@"my am km dv lez arc got ti" componentsSeparatedByString:@" "];

    }
    return self;
}

-(NSURL *)urlForDomain:(NSString *)domain
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"https://%@.m.%@/w/api.php", domain, [self site]]];
}

-(NSString *)searchApiUrl
{
    return [NSString stringWithFormat:@"https://%@.m.%@/w/api.php", [self domain], [self site]];
}

-(void)setDomain:(NSString *)domain
{
    [[NSUserDefaults standardUserDefaults] setObject:domain forKey:@"Domain"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSString *)domain
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"Domain"];
}

-(void)setDomainName:(NSString *)domainName
{
    [[NSUserDefaults standardUserDefaults] setObject:domainName forKey:@"DomainName"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSString *)domainName
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"DomainName"];
}

-(void)setSite:(NSString *)site
{
    [[NSUserDefaults standardUserDefaults] setObject:site forKey:@"Site"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSString *)site
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"Site"];
}

-(void)setCurrentArticleTitle:(NSString *)currentArticleTitle
{
    [[NSUserDefaults standardUserDefaults] setObject:currentArticleTitle forKey:@"CurrentArticleTitle"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSString *)currentArticleTitle
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentArticleTitle"];
}

-(void)setCurrentArticleDomain:(NSString *)currentArticleDomain
{
    [[NSUserDefaults standardUserDefaults] setObject:currentArticleDomain forKey:@"CurrentArticleDomain"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSString *)currentArticleDomain
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentArticleDomain"];
}

-(NSString *)currentArticleDomainName
{
    return [self domainNameForCode:self.currentArticleDomain];
}

-(NSString *)domainNameForCode:(NSString *)code
{
    NSError *error = nil;
    NSData *fileData = [NSData dataWithContentsOfFile:[self bundledLanguagesJsonPath] options:0 error:&error];
    if (error) return nil;
    error = nil;
    NSArray *result = [NSJSONSerialization JSONObjectWithData:fileData options:0 error:&error];
    if (!error) {
        for (NSDictionary *d in result) {
            if ([d[@"code"] isEqualToString:code]) {
                return d[@"name"];
            }
        }
        return nil;
    }else{
        return nil;
    }
}

- (NSString *)bundledLanguagesJsonPath
{
    return [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/Languages/languages.json"];
}

-(NSMutableArray *)getBundledLanguagesJson
{
    NSError *error = nil;
    NSData *fileData = [NSData dataWithContentsOfFile:[[SessionSingleton sharedInstance] bundledLanguagesJsonPath] options:0 error:&error];
    if (error) return [@[] mutableCopy];
    error = nil;
    NSArray *result = [NSJSONSerialization JSONObjectWithData:fileData options:0 error:&error];
    return (error) ? [@[] mutableCopy]: [result mutableCopy];
}

@end