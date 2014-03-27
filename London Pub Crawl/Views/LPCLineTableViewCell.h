//
//  LPCLineTableViewCell.h
//  London Pub Crawl
//
//  Created by Dan on 15/10/2013.
//  Copyright (c) 2013 LondonPubCrawl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LPCLineTableViewCell : UITableViewCell

@property (nonatomic) int lineIndex;
@property (strong, nonatomic) NSString *lineName;
@property (weak, nonatomic) IBOutlet UILabel *ownershipIndicatorLabel;

@end
