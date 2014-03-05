#import "Downloader.h"
#include <sys/xattr.h>

@implementation Downloader


-(CDVPlugin*) initWithWebView:(UIWebView*)theWebView
{
    self = (Downloader*)[super initWithWebView:theWebView];
    return self;
}

//
// entry point to  the javascript plugin for PhoneGap
//

//TODO
//-(void) preload:(NSMutableArray*)paramArray withDict:(NSMutableDictionary*)options {
-(void) preload:(CDVInvokedUrlCommand*)command {
	/*
    TODO
	NSLog(@"in Downloader.preload",nil);
	NSString * sourceUrl = [paramArray objectAtIndex:0];
	NSString * fileName = [paramArray objectAtIndex:1];
	NSString * dirName = [paramArray objectAtIndex:2];
	NSString * Forced = [paramArray objectAtIndex:3];
	*/
    NSLog(@"in Downloader.preload",nil);
	NSString * sourceUrl = [command.arguments objectAtIndex:0];
	NSString * fileName = [command.arguments objectAtIndex:1];
	NSString * dirName = [command.arguments objectAtIndex:2];
	NSString * Forced = [command.arguments objectAtIndex:3];

	//NSString * completionCallback = [command.arguments objectAtIndex:2];

	params = [[NSMutableArray alloc] initWithCapacity:4];
	[params addObject:sourceUrl];
	[params addObject:fileName];
	[params addObject:dirName];
	[params addObject:Forced];

	[self downloadFileFromUrl:params];
    [params release];
}

//
// call to excute the download in a background thread
//
-(void) downloadFileFromUrl:(NSMutableArray*)paramArray
{
	NSLog(@"in Downloader.downloadFileFromUrl",nil);
	[self performSelectorInBackground:@selector(downloadFileFromUrlInBackgroundTask:) withObject:paramArray];
}

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL {
    const char* filePath = [[URL path] fileSystemRepresentation];

    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;

    int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);

	NSLog(@"SET BACKUP ATTRIBUTE: %d", result);

	return (result == 0);
}

//
// downloads the file in the background and saves it to the local documents
// directory for the application
//
-(void) downloadFileFromUrlInBackgroundTask:(NSMutableArray*)paramArray
{
	NSLog(@"in Downloader.downloadFileFromUrlInBackgroundTask",nil);
	NSString * sourceUrl = [paramArray objectAtIndex:0];
	NSString * dirName = [paramArray objectAtIndex:2];
	NSString * Forced = [paramArray objectAtIndex:3];

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    dirName = [dirName stringByReplacingPercentEscapesUsingEncoding: NSASCIIStringEncoding];
	dirName = [dirName stringByReplacingOccurrencesOfString: @"Documents/" withString: @""];

	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	dirName = [[paths objectAtIndex:0] stringByAppendingPathComponent:dirName];
	NSString * filePath = [[dirName stringByAppendingString: @"/"] stringByAppendingString: [paramArray objectAtIndex:1]];

	[paramArray addObject:filePath];

	NSFileManager *fileManager= [NSFileManager defaultManager];
	if(![fileManager fileExistsAtPath:filePath] || [Forced boolValue]) {
		NSLog(@"DOWNLOAD STARTING", nil);
	    NSData* theData = [NSData dataWithContentsOfURL: [NSURL URLWithString:sourceUrl] ];

		BOOL isDir;
		if([fileManager fileExistsAtPath:dirName isDirectory:&isDir]) {
			NSLog(@"DIRECTORY EXISTS: %@", dirName);

		}
		else{
			if([fileManager createDirectoryAtPath:dirName withIntermediateDirectories:YES attributes:nil error:NULL])
			{
				NSURL *dbURLDir = [NSURL URLWithString:dirName];
				if([self addSkipBackupAttributeToItemAtURL:dbURLDir]) {
					NSLog(@"Successfully set NOT BACK UP attribute: %@", dirName);
				}
				else {
					NSLog(@"Error while set NOT BACK UP attribute: %@", dirName);
				}

				NSLog(@"Successfully created folder %@", dirName);
			}
			else {
				NSLog(@"Error: Create folder failed %@", dirName);
			}
		}

		NSError *error =[[[NSError alloc]init] autorelease];


		BOOL response = [theData writeToFile:filePath options:NSDataWritingFileProtectionNone error:&error];


		if ( response == NO ) {
			//NSLog(@"file save result %@", [error localizedFailureReason]);

		// send our results back to the main thread
			[self performSelectorOnMainThread:@selector(downloadCompleteWithError:)
							   withObject:paramArray waitUntilDone:YES];

		} else {
			NSURL *dbURLFile = [NSURL URLWithString:filePath];
			if([self addSkipBackupAttributeToItemAtURL:dbURLFile]) {
				NSLog(@"Successfully set NOT BACK UP attribute: %@", filePath);
			}
			else {
				NSLog(@"Error while set NOT BACK UP attribute: %@", filePath);
			}

			NSLog(@"No Error, file saved successfully", nil);

		// send our results back to the main thread
			[self performSelectorOnMainThread:@selector(downloadComplete:)
							   withObject:paramArray waitUntilDone:YES];

		}
	} else {
		[self performSelectorOnMainThread:@selector(downloadComplete:)
							   withObject:paramArray waitUntilDone:YES];
	}

	[pool drain];
}

//
// calls the predefined callback in the ui to indicate completion
//
-(void) downloadComplete:(NSMutableArray*)paramArray {
	NSLog(@"in Downloader.downloadComplete",nil);
	NSString * jsCallBack = [NSString stringWithFormat:@"window.plugins.downloader.complete('%@', '%@');",[paramArray objectAtIndex:0],[paramArray objectAtIndex:4]];
	[self writeJavascript: jsCallBack];
}

//
// calls the predefined callback in the ui to indicate completion with error
//
-(void) downloadCompleteWithError:(NSMutableArray*)paramArray {
	NSLog(@"in Downloader.Error",nil);
	NSString * jsCallBack = [NSString stringWithFormat:@"window.plugins.downloader.error('%@', '%@');",[paramArray objectAtIndex:0],[paramArray objectAtIndex:4]];
	[self writeJavascript: jsCallBack];
}

- (void)dealloc
{
	if (params) {
		[params release];
	}
    [super dealloc];
}


@end