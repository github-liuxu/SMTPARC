//
//  ViewController.m
//  SMTPARC
//
//  Created by 刘东旭 on 2018/10/28.
//  Copyright © 2018年 刘东旭. All rights reserved.
//

#import "ViewController.h"
#import "SKPSMTPMessage.h"
#import "NSData+Base64Additions.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)send:(id)sender {
    
    SKPSMTPMessage *testMsg = [[SKPSMTPMessage alloc] init];
    testMsg.fromEmail = @"xxxxxx@163.com";
    
    testMsg.toEmail = @"xxxxxx@163.com";
    //    testMsg.bccEmail = [defaults objectForKey:@"bccEmal"];
    testMsg.relayHost = @"smtp.163.com";
    
    testMsg.requiresAuth = YES;
    
    if (testMsg.requiresAuth) {
        testMsg.login = @"xxxxxx@163.com";
        
        testMsg.pass = @"xxxxxx";
        
    }
    
    testMsg.wantsSecure = YES; // smtp.gmail.com doesn't work without TLS!
    
    
    testMsg.subject = @"first class";
    //testMsg.bccEmail = @"testbcc@test.com";
    
    // Only do this for self-signed certs!
    // testMsg.validateSSLChain = NO;
    testMsg.delegate = self;
    
    NSString *content = [NSString stringWithCString:"hello class" encoding:NSUTF8StringEncoding];
    NSDictionary *plainPart = @{kSKPSMTPPartContentTypeKey : @"text/plain", kSKPSMTPPartMessageKey : content, kSKPSMTPPartContentTransferEncodingKey : @"8bit"};
    
    
    NSString *vcfPath = [[NSBundle mainBundle] pathForResource:@"aa" ofType:@"txt"];
    NSData *vcfData = [NSData dataWithContentsOfFile:vcfPath];
    
    NSDictionary *vcfPart = [NSDictionary dictionaryWithObjectsAndKeys:@"text/directory;\r\n\tx-unix-mode=0644;\r\n\tname=\"aa.txt\"",kSKPSMTPPartContentTypeKey,
                             @"attachment;\r\n\tfilename=\"aa.txt\"",kSKPSMTPPartContentDispositionKey,[vcfData encodeBase64ForData],kSKPSMTPPartMessageKey,@"base64",kSKPSMTPPartContentTransferEncodingKey,nil];
    
    testMsg.parts = [NSArray arrayWithObjects:plainPart,vcfPart,nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [testMsg send];
    });
    
}

- (void)messageSent:(SKPSMTPMessage *)message
{
    NSLog(@"message sent");
}

- (void)messageFailed:(SKPSMTPMessage *)message error:(NSError *)error
{
    
    NSLog(@"error(%ld): %@", [error code], [error localizedDescription]);
}

@end
