//
//  LPCOptionsCell.h
//  London Pub Crawl
//
//  Created by Daniel Hough on 06/01/2014.
//  Copyright (c) 2014 LondonPubCrawl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LPCOptionsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *optionsImageView;
- (IBAction)happilyButtonClicked:(id)sender;
- (IBAction)helpButtonClicked:(id)sender;

@end
