//
//  ViewController.m
//  SMBTestProj
//
//  Created by Demian Steelstone on 18.01.17.
//  Copyright © 2017 test. All rights reserved.
//

#import "ViewController.h"

#import "bdsm.h"

#import <arpa/inet.h>
#import <SystemConfiguration/SystemConfiguration.h>

@interface ViewController ()

@property (nonatomic,assign) smb_session *session;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    NSString *hostName = @"NETBIOSNAME";
    NSString *userName = @"USERNAME";
    NSString *password = @"PASSWORD";
    NSString *ipAddress = @"IPAddress";
    
    NSString *shareName = @"SHARENAME";
    
    NSString *srcPath = @"\\Downloads\\\\1.txt";
    NSString *dstPath = @"\\Downloads\\\\2.txt";
    
    struct in_addr addr;
    inet_aton(ipAddress.UTF8String, &addr);
    
    smb_session *session = smb_session_new();
    
    self.session = session;
    
    int r = smb_session_connect(session, hostName.UTF8String, addr.s_addr, SMB_TRANSPORT_TCP);
    
    if (r)
    {
        [self logResult:r];
        return;
    }
    
    smb_session_set_creds(session, hostName.UTF8String, userName.UTF8String, password.UTF8String);
    
    smb_tid treeID;
    
    r = smb_session_login(session);
    
    if (r)
    {
        [self logResult:r];
        return;
    }
    
    r = smb_tree_connect(session, shareName.UTF8String, &treeID);
    if (r)
    {
        [self logResult:r];
        return;
    }
    
    r = smb_file_mv(session,treeID,srcPath.UTF8String,dstPath.UTF8String);
    if (r)
    {
        [self logResult:r];
        return;
    }
}

-(void)logResult:(int)r
{
    if (r == -2)
    {
        uint32_t code = smb_session_get_nt_status(self.session);
        NSLog(@"Failed with result %i. NT Code %i",r, code);
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
