//
//  FEAdvDataPreviewViewController.m
//  BLEAssistant
//
//  Created by chenchanghua on 2026/1/21.
//  Copyright © 2026 feasycom. All rights reserved.
//

#import "FEAdvDataPreviewViewController.h"

@interface FEAdvDataPreviewViewController ()
@property (nonatomic, copy) NSString *text;
@end

@implementation FEAdvDataPreviewViewController

- (instancetype)initWithText:(NSString *)text {
    if (self = [super initWithNibName:nil bundle:nil]) {
        _text = [text copy];
        self.modalPresentationStyle = UIModalPresentationPopover;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    
    UITextView *tv = [[UITextView alloc] initWithFrame:self.view.bounds];
    tv.editable = NO;
    tv.selectable = YES;
    tv.alwaysBounceVertical = YES;
    tv.backgroundColor = [UIColor secondarySystemBackgroundColor];
    tv.font = [UIFont monospacedSystemFontOfSize:12 weight:UIFontWeightRegular];
    tv.text = self.text ?: @"(null)";
    tv.textContainerInset = UIEdgeInsetsMake(12, 12, 12, 12);
    
    tv.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:tv];
    
    self.preferredContentSize = CGSizeMake(320, 400);
}

@end

