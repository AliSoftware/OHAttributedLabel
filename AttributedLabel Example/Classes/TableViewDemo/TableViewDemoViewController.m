//
//  TableViewDemoViewController.m
//  AttributedLabel Example
//
//  Created by Olivier Halligon on 31/08/12.
//
//

#import "TableViewDemoViewController.h"
#import <OHAttributedLabel/OHAttributedLabel.h>
#import <OHAttributedLabel/NSAttributedString+Attributes.h>
#import <OHAttributedLabel/OHASBasicMarkupParser.h>
#import "UIAlertView+Commodity.h"


@interface TableViewDemoViewController () <OHAttributedLabelDelegate>
@property(nonatomic, retain) NSArray* texts;
@end

static NSInteger const kAttributedLabelTag = 100;
static CGFloat const kLabelWidth = 300;
static CGFloat const kLabelVMargin = 10;

@implementation TableViewDemoViewController
@synthesize texts = _texts;

/////////////////////////////////////////////////////////////////////////////
#pragma mark - Init/Dealloc
/////////////////////////////////////////////////////////////////////////////

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
        NSMutableArray* plainEntries = [NSMutableArray arrayWithObjects:
                                   @"Visit http://www.apple.com *now*!",
                                   @"Go to http://www.foodreporter.net to *{red|share your food}* with millions of users!",
                                   @"Start a search on http://www.google.com right now",
                                   nil];
        for(int i=0; i<20;++i)
        {
            [plainEntries addObject:[NSString stringWithFormat:@"Call +1555-000-%04d from your iPhone", i]];
        }
        [plainEntries insertObject:@"Lorem ipsum dolor sit amet, consectetur adipiscing elit." \
         "Etiam pretium mi eget lectus tincidunt semper. Phasellus placerat, lorem quis laoreet." atIndex:13];
        
        NSMutableArray* formattedEntries = [NSMutableArray arrayWithCapacity:plainEntries.count];
        NSArray* randomColors = [NSArray arrayWithObjects:[UIColor redColor], [UIColor orangeColor],
                                 [UIColor colorWithRed:0 green:0.6 blue:0 alpha:1],
                                 [UIColor blueColor], [UIColor darkTextColor], nil];
        NSUInteger idx = 0;
        for(NSString* plainEntry in plainEntries)
        {
            NSMutableAttributedString* mas = [NSMutableAttributedString attributedStringWithString:plainEntry];
            [mas setFont:[UIFont systemFontOfSize: (idx < 13) ? 18 : 16]];
            [mas setTextColor:[randomColors objectAtIndex:(idx%5)]];
            [mas setTextAlignment:kCTTextAlignmentCenter lineBreakMode:kCTLineBreakByWordWrapping];
            [OHASBasicMarkupParser processMarkupInAttributedString:mas];
            [formattedEntries addObject:mas];
            ++idx;
        }
        self.texts = formattedEntries;
        [self.tableView reloadData];
    }
    return self;
}

#if ! __has_feature(objc_arc)
- (void)dealloc
{
    self.texts = nil;
    [super dealloc];
}
#endif


/////////////////////////////////////////////////////////////////////////////
#pragma mark - TableView DataSource
/////////////////////////////////////////////////////////////////////////////

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.texts count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* const kCellIdentifier = @"SomeCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    OHAttributedLabel* attrLabel = nil;
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
        
        attrLabel = [[OHAttributedLabel alloc] initWithFrame:CGRectMake(10,kLabelVMargin,kLabelWidth,tableView.rowHeight-2*kLabelVMargin)];
        attrLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        attrLabel.centerVertically = YES;
        attrLabel.automaticallyAddLinksForType = NSTextCheckingAllTypes;
        attrLabel.delegate = self;
        attrLabel.highlightedTextColor = [UIColor whiteColor];
        attrLabel.tag = kAttributedLabelTag;
        [cell addSubview:attrLabel];
        
#if ! __has_feature(objc_arc)
        [attrLabel release];
        [cell autorelease];
#endif
    }
    
    attrLabel = (OHAttributedLabel*)[cell viewWithTag:kAttributedLabelTag];
    attrLabel.attributedText = [self.texts objectAtIndex:indexPath.row];
    return cell;
}

/////////////////////////////////////////////////////////////////////////////
#pragma mark - TableView Delegate
/////////////////////////////////////////////////////////////////////////////

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSAttributedString* attrStr = [self.texts objectAtIndex:indexPath.row];
    CGSize sz = [attrStr sizeConstrainedToSize:CGSizeMake(kLabelWidth, CGFLOAT_MAX)];
    return sz.height + 2*kLabelVMargin;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    OHAttributedLabel* attrLabel = (OHAttributedLabel*)[cell viewWithTag:kAttributedLabelTag];
    
    // Detect first link and open it
    NSTextCheckingResult* firstLink = [attrLabel.linksDataDetector firstMatchInString:attrLabel.text options:0 range:NSMakeRange(0, attrLabel.text.length)];
    
    [[UIApplication sharedApplication] openURL:firstLink.extendedURL];
}

/////////////////////////////////////////////////////////////////////////////
#pragma mark - OHAttributedLabel Delegate Method
/////////////////////////////////////////////////////////////////////////////

-(BOOL)attributedLabel:(OHAttributedLabel *)attributedLabel shouldFollowLink:(NSTextCheckingResult *)linkInfo
{
    if ([[UIApplication sharedApplication] canOpenURL:linkInfo.extendedURL])
    {
        return YES;
    }
    else
    {
        // Unsupported link type (especially phone links are not supported on Simulator, only on device)
        [UIAlertView showWithTitle:@"Link tapped" message:[NSString stringWithFormat:@"Should open link: %@", linkInfo.extendedURL]];
        return NO;
    }
}

@end
