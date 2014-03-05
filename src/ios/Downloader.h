#import <Foundation/Foundation.h>


#import <Cordova/CDVPlugin.h>


@interface Downloader : CDVPlugin {
	NSMutableArray* params;
}

//TODO
//-(void) preload:(NSMutableArray*)paramArray withDict:(NSMutableDictionary*)options;
-(void) preload:(CDVInvokedUrlCommand*)command;
-(void) downloadComplete:(NSMutableArray*)paramArray;
-(void) downloadCompleteWithError:(NSMutableArray*)paramArray;
-(void) downloadFileFromUrlInBackgroundTask:(NSMutableArray*)paramArray;
-(void) downloadFileFromUrl:(NSMutableArray*)paramArray;
@end