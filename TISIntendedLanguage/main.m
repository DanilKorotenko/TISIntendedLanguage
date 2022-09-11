//
//  main.m
//  TISIntendedLanguage
//
//  Created by Danil Korotenko on 9/11/22.
//

#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>

static NSString * const kDictionaryFileName = @"TISIntendedLanguage.plist";

NSString *getDictionaryPath(void)
{
    NSString *executablePath = [[[NSProcessInfo processInfo] arguments]
        objectAtIndex:0];

    NSString *dictionaryPath = executablePath;
    dictionaryPath = [dictionaryPath stringByDeletingLastPathComponent];
    dictionaryPath = [dictionaryPath stringByAppendingPathComponent:
        kDictionaryFileName];

    return dictionaryPath;
}

NSDictionary *loadDictionaryFromFile(void)
{
    NSString *dictionaryPath = getDictionaryPath();

    if (nil == dictionaryPath)
    {
        return nil;
    }

    if (![[NSFileManager defaultManager] fileExistsAtPath:dictionaryPath])
    {
        return nil;
    }

    NSDictionary *result = [NSDictionary dictionaryWithContentsOfFile:
        dictionaryPath];
    return result;
}

NSMutableDictionary *prepareDictionary(void)
{
    NSMutableDictionary *intendedLagDict = nil;

    NSDictionary *dict = loadDictionaryFromFile();

    if (nil != dict)
    {
        intendedLagDict = [NSMutableDictionary dictionaryWithDictionary:dict];
    }
    else
    {
        intendedLagDict = [NSMutableDictionary dictionary];
    }

    return intendedLagDict;
}

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        NSLog(@"Hello, TISIntendedLanguage!");

        NSMutableDictionary *intendedLangDict = prepareDictionary();

        CFArrayRef list = TISCreateInputSourceList(NULL, true);

        for (int i = 0; i < CFArrayGetCount(list); i++)
        {
            TISInputSourceRef source = (TISInputSourceRef)CFArrayGetValueAtIndex(list, i);
            CFStringRef sourceIDRef =
                TISGetInputSourceProperty(source, kTISPropertyInputSourceID);
            NSString *sourceID = CFBridgingRelease(sourceIDRef);

            NSString *intendetLang = [intendedLangDict objectForKey:sourceID];

            if (nil == intendetLang)
            {
                [intendedLangDict setObject:@"" forKey:sourceID];
            }

            NSLog(@"%@\t%@", sourceID, intendetLang);
        }
        CFRelease(list);

        [intendedLangDict writeToFile:getDictionaryPath() atomically:YES];
    }
    return 0;
}
