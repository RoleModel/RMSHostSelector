//
//  RMSViewController.m
//  Host Selector Demo
//
//  Created by Tony Ingraldi on 10/16/13.
//  Copyright (c) 2013 RoleModel Software. All rights reserved.
//

#import "RMSViewController.h"
#import "RMSHostSelector.h"

@interface RMSViewController ()

@property (nonatomic, weak) IBOutlet UILabel *hostLabel;

@end

@implementation RMSViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleApplicationFinishedLaunchingNotification:)
                                                 name:UIApplicationDidFinishLaunchingNotification
                                               object:[UIApplication sharedApplication]];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)handleApplicationFinishedLaunchingNotification:(NSNotification *)notification {
    RMSHostSelector *hostSelector = [[RMSHostSelector alloc] init];
    [hostSelector selectHostWithBlock:^(NSString *selectedHost){
        self.hostLabel.text = selectedHost;
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

}

@end
