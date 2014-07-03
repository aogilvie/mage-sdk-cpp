//
//  ViewController.m
//  mage-app
//
//  Created by Ally on 7/1/14.
//  Copyright (c) 2014 Wizcorp. All rights reserved.
//

#import "ViewController.h"
#include <MAGE/MAGE.h>
#include <iostream>

@interface ViewController ()

@end

@implementation ViewController

using namespace mage;
using namespace std;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self outputText:@"loading..."];
    
    // Setup button listenter
    [self.connectBtn addTarget:self action:@selector(connect) forControlEvents:UIControlEventTouchUpInside];
    
    // Setup last accessed url
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *savedURL = [defaults objectForKey:@"savedInputText"];
    if (savedURL) {
        self.inputURLTextField.text = savedURL;
    }
    
    [self outputText:@"...loaded."];
}

- (void)outputText:(NSString *)appendText {

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // on iPad
        
        NSString *outputText = self.outputTextViewIPad.text;
        self.outputTextViewIPad.text = [outputText stringByAppendingString:
                                    [NSString stringWithFormat:@"\n> \n> %@", appendText]];
    } else {
        // on iPhone

        NSString *outputText = self.outputTextView.text;
        self.outputTextView.text = [outputText stringByAppendingString:
                                    [NSString stringWithFormat:@"\n> \n> %@", appendText]];
    }
}

- (void)connect {
    // Get text field content
    NSString *url = self.inputURLTextField.text;
    
    // Store in user defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.inputURLTextField.text forKey:@"savedInputText"];
    [defaults synchronize];
    
    const char *urlChar = [url UTF8String];
    
    mage::RPC client("game", urlChar);
    
	//
	// MAGE works with JSON-RPC: so
	// we create variables for the request's
	// parameters as well as for the response
	//
	Json::Value params;
	Json::Value res;
    
	//
	// I put things in my Json::Value.
	//
	params["somethings"] = "test";
	params["one"]["two"]["three"] = 4;
    
	//
	// We make the call
	//
	// 1. If it succeed, we get a Json::Value
	// 2. If there is a connection or transport error, you will get a MageRPCError
	// 3. If the module's user command returns an error, you will get a MageErrorMessage
	//
	try {
		res = client.Call("mymodule.mycommand", params);
		cout << "mymodule.mycommand: " << res << endl;
        // [self outputText:[NSString stringWithFormat:@"mymodule.mycommand: %s", res]];
	} catch (mage::MageRPCError e) {
		cerr << "An RPC error has occured: "  << e.what() << " (code " << e.code() << ")" << endl;
        [self outputText:[NSString stringWithFormat:@"An RPC error has occured: %s (code %i)", e.what(), e.code()]];
	} catch (mage::MageErrorMessage e) {
		cerr << "mymodule.mycommand responded with an error: "  << e.code() << endl;
        NSString *msg = [NSString stringWithUTF8String:e.code().c_str()];
        [self outputText:[NSString stringWithFormat:@"mymodule.mycommand responded with an error code: %@", msg]];
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
