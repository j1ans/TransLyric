#import "lycRootListController.h"
#import <Foundation/Foundation.h>
#include <notify.h>

@implementation lycRootListController

- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
    }
    return _specifiers;
}

- (void)github {
    NSURL *url = [NSURL URLWithString:@"https://github.com/j1ans"];
    [UIApplication.sharedApplication openURL:url options:@{} completionHandler:nil];
}


@end
