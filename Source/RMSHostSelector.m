//
//  RMSHostSelector.m
//
// Copyright (c) 2013 RoleModel Software, Inc
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "RMSHostSelector.h"

#ifndef RMS_HOST_KEY
#define RMS_HOST_KEY ""
#endif

#ifndef ELog
#define ELog NSLog
#endif

#ifndef DLog
#define DLog NSLog
#endif

static NSString * const RMSDefaultHostKey = @"RMSDefaultHostKey"; // for NSUserDefaults
static NSString * const RMSHostSelectorException = @"RMSHostSelectorException";

@interface RMSHostSelector ()

@property (nonatomic, strong) RMSHostSelectCompletionBlock completionBlock;
@property (nonatomic, strong) NSArray *hostKeys;
@property (nonatomic, strong) NSDictionary *hosts;
@property (nonatomic, strong) NSString *selectedHost;   // Value stored in NSUserDefaults and tracks the selection in the UI

// configuredHost reflects the value for the preprocessor macro RMS_USE_HOST
// or, in the case where only a single host is defined, the value of the
// single host. RMS_USE_HOST is checked before the single-value case.
@property (nonatomic, strong) NSString *configuredHost;


@end

@implementation RMSHostSelector

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        NSString *hostPlistPath = [[NSBundle mainBundle] pathForResource:@"Hosts" ofType:@"plist"];

        if (hostPlistPath == nil) {
            @throw [NSException exceptionWithName:RMSHostSelectorException
                                           reason:@"Hosts.plist file is missing"
                                         userInfo:nil];
        }

        _hosts = [NSDictionary dictionaryWithContentsOfFile:hostPlistPath];
        _hostKeys = [[_hosts allKeys] sortedArrayUsingSelector:@selector(description)];
        
        NSString *configuredHostKey = [NSString stringWithUTF8String:RMS_HOST_KEY];
        if ([configuredHostKey length] > 0) {
            ELog(@"Looking for host key '%@'", configuredHostKey);
            _configuredHost = _hosts[configuredHostKey];
            if (_configuredHost == nil) {
                @throw [NSException exceptionWithName:RMSHostSelectorException
                                               reason:@"Host specified by RMS_HOST_KEY not found in Hosts.plist file"
                                             userInfo:nil];
            }
        }

        if (_configuredHost == nil && [_hostKeys count] == 1) {
            _configuredHost = _hosts[_hostKeys[0]];
            ELog(@"Using only host found: '%@'", _configuredHost);
        }
    }

    return self;
}

- (id)init {
    return [self initWithStyle:UITableViewStylePlain];
}

- (void)viewDidLoad {
    self.navigationItem.title = @"Select Host";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(doneAction:)];
}

- (void)doneAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
    self.completionBlock(self.selectedHost);
}

- (NSString *)selectedHost {
    NSString *selectedHost = [[NSUserDefaults standardUserDefaults] stringForKey:RMSDefaultHostKey];
    if (selectedHost == nil && [self.hostKeys count] > 0) {
        selectedHost = self.hosts[self.hostKeys[0]];
    }
    return selectedHost;
}

- (void)setSelectedHost:(NSString *)selectedHost {
    [[NSUserDefaults standardUserDefaults] setObject:selectedHost forKey:RMSDefaultHostKey];
}

- (BOOL)hasConfiguredHost {
    return [self.configuredHost length] > 0;
}

- (void)selectHostWithBlock:(RMSHostSelectCompletionBlock)completionBlock {
    self.completionBlock = completionBlock;

    if ([self hasConfiguredHost]) {
        self.completionBlock(self.configuredHost);
    } else {
        UIApplication *application = [UIApplication sharedApplication];
        UIWindow *keyWindow = [application keyWindow];
        UIViewController *rootViewController = [keyWindow rootViewController];

        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self];

        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
        }
        [rootViewController presentViewController:navigationController animated:YES completion:NULL];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.hostKeys count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    NSString *hostKey = self.hostKeys[indexPath.row];
    NSString *hostValue = self.hosts[hostKey];

    cell.textLabel.text = hostKey;
    cell.detailTextLabel.text = hostValue;

    cell.accessoryType = [hostValue isEqualToString:self.selectedHost] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedHost = self.hosts[self.hostKeys[indexPath.row]];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
