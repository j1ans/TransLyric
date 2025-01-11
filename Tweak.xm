#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import <dlfcn.h>
#import <AVFoundation/AVPlayer.h>
#include <roothide.h>

@interface MPModelLyrics : NSObject
- (void)setTTML:(NSString *)ttml;
@end

@interface TTMLParser : NSObject <NSXMLParserDelegate>
@property (nonatomic, strong) NSString *xmlLang;
@end


static BOOL enabled;
static BOOL enabledrecord;
static BOOL ShouldSkipTTML;
static NSString *displayMode;

NSString *GlobalArtistName;
NSString *GlobalSongTitle;

@implementation TTMLParser

- (void)parseTTML:(NSString *)ttmlString {
    NSData *data = [ttmlString dataUsingEncoding:NSUTF8StringEncoding];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    parser.delegate = self;
    [parser parse];
}

// 解析根节点开始
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName 
    attributes:(NSDictionary<NSString *, NSString *> *)attributeDict {
    
    if ([elementName isEqualToString:@"tt"]) {
        self.xmlLang = attributeDict[@"xml:lang"];
        NSLog(@"xml:lang = %@", self.xmlLang);
        if([self.xmlLang isEqualToString:@"zh-Hant"]){
            ShouldSkipTTML =  true;
        }else if([self.xmlLang isEqualToString:@"zh-Hans"]){
            ShouldSkipTTML =  true;
        }else{
            ShouldSkipTTML =  false;
        }
    }
}

@end

// 声明函数指针类型
typedef void (*MRMediaRemoteGetNowPlayingInfo_t)(dispatch_queue_t queue, void(^block)(CFDictionaryRef info));

// 函数指针和符号地址
MRMediaRemoteGetNowPlayingInfo_t MRMediaRemoteGetNowPlayingInfo;
CFStringRef kMRMediaRemoteNowPlayingInfoTitle;
CFStringRef kMRMediaRemoteNowPlayingInfoArtist;

// 加载符号方法
void loadMediaRemoteSymbols() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        void *handle = dlopen("/System/Library/PrivateFrameworks/MediaRemote.framework/MediaRemote", RTLD_LAZY);
        if (handle) {
            MRMediaRemoteGetNowPlayingInfo = (MRMediaRemoteGetNowPlayingInfo_t)dlsym(handle, "MRMediaRemoteGetNowPlayingInfo");
            kMRMediaRemoteNowPlayingInfoTitle = *(CFStringRef *)dlsym(handle, "kMRMediaRemoteNowPlayingInfoTitle");
            kMRMediaRemoteNowPlayingInfoArtist = *(CFStringRef *)dlsym(handle, "kMRMediaRemoteNowPlayingInfoArtist");
            
            if (!MRMediaRemoteGetNowPlayingInfo || !kMRMediaRemoteNowPlayingInfoTitle || !kMRMediaRemoteNowPlayingInfoArtist) {
                NSLog(@"Failed to load MediaRemote symbols");
            } else {
                NSLog(@"MediaRemote symbols loaded successfully");
            }
        } else {
            NSLog(@"Failed to load MediaRemote.framework");
        }
    });
}

// Base64 编码
NSString *base64Encode(NSString *input) {
    NSData *data = [input dataUsingEncoding:NSUTF8StringEncoding];
    return [data base64EncodedStringWithOptions:0];
}

// Hook 歌词处理逻辑
%hook MPModelLyrics
- (void)setTTML:(NSString *)ttml {

TTMLParser *parser = [TTMLParser new];
[parser parseTTML:ttml];
if(ShouldSkipTTML){
    NSLog(@"find need skip ttml,skipping");
    %orig;
}else{

if(enabled){

    __block NSString *resultTTML = ttml;

    if (MRMediaRemoteGetNowPlayingInfo) {
        // 添加 50ms 延迟等待播放信息更新
        usleep(50000);
        
        dispatch_semaphore_t infoSemaphore = dispatch_semaphore_create(0);
        
        // 获取播放信息
        MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef info) {
            if (info) {
                NSDictionary *infoDict = (__bridge NSDictionary *)info;
                NSString *artist = [infoDict objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtist];
                NSString *title = [infoDict objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoTitle];
                
                if (artist) {
                    GlobalArtistName = [artist copy];
                    NSLog(@"[MRMediaRemoteGetNowPlayingInfo]GlobalArtistName -> %@", GlobalArtistName);
                }
                if (title) {
                    GlobalSongTitle = [title copy];
                    NSLog(@"[MRMediaRemoteGetNowPlayingInfo]GlobalSongTitle -> %@", GlobalSongTitle);
                }
            } else {
                NSLog(@"No Now Playing Info");
            }
            dispatch_semaphore_signal(infoSemaphore);
        });
        
        // 等待获取信息完成
        dispatch_semaphore_wait(infoSemaphore, DISPATCH_TIME_FOREVER);
    }

   if (ttml) {
        NSString *base64ttml = base64Encode(ttml);
        NSString *base64GlobalArtistName = base64Encode(GlobalArtistName ? GlobalArtistName : @"");
        NSString *base64GlobalSongTitle = base64Encode(GlobalSongTitle ? GlobalSongTitle : @"");
        //NSLog(@"Hooked TTML Lyrics");
        NSURL *url = [NSURL URLWithString:@"https://shsh.iakb.org/lyric.php"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setHTTPMethod:@"POST"];
        
        NSMutableData *body = [NSMutableData data];
        NSString *boundary = @"----WebKitFormBoundary7MA4YWxkTrZu0gW";
        [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
        if([displayMode isEqualToString:@"bg"]){
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"disabled_bg\"\r\n\r\n%@\r\n", @"0"] dataUsingEncoding:NSUTF8StringEncoding]];    
        }else if([displayMode isEqualToString:@"line"]){
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"disabled_bg\"\r\n\r\n%@\r\n", @"1"] dataUsingEncoding:NSUTF8StringEncoding]];    
        }
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"artist\"\r\n\r\n%@\r\n", base64GlobalArtistName] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"title\"\r\n\r\n%@\r\n", base64GlobalSongTitle] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"ttml\"\r\n\r\n%@\r\n", base64ttml] dataUsingEncoding:NSUTF8StringEncoding]];

        [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPBody:body];
        
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error) {
                NSLog(@"Request failed: %@", error.localizedDescription);
            } else {
                NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"Server Response: %@", responseString);
                resultTTML = responseString;
            }
            dispatch_semaphore_signal(semaphore);
        }];
        
        [task resume];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);


        

        
    } else {
        NSLog(@"TTML content is nil");
    }

    if ([resultTTML isEqualToString:@"false"]) {
        %orig;
    } else {
        %orig(resultTTML);
    }
  }else{
    %orig;
  }
}
}
%end

%hook AVPlayer 
-(BOOL)isMuted {
    if(enabledrecord){
        return FALSE;
    }else{
        return %orig;
    }
	
}

-(void)setMuted:(BOOL)arg1 {
    if(enabledrecord){
        %orig(FALSE);
    }else{
        %orig;
    }
	
}
%end


%ctor { //初始化
    NSString* pref_path = [NSString stringWithCString:jbroot("/var/mobile/Library/Preferences/com.akeboshi.translyricpref.plist") encoding:NSUTF8StringEncoding];
    NSDictionary *const prefs = [NSDictionary dictionaryWithContentsOfFile:pref_path];
    enabled = [[prefs objectForKey:@"EnabledTweak"] boolValue];
    enabledrecord = [[prefs objectForKey:@"EnabledRecord"] boolValue];
    displayMode = [prefs objectForKey:@"TransLyricShow"];
    loadMediaRemoteSymbols();

}