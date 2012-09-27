//
//  TableViewDemoViewController.m
//  AttributedLabel Example
//
//  Created by Olivier Halligon on 31/08/12.
//
//

#import "TableViewDemoViewController.h"
#import <OHAttributedLabel/OHAttributedLabel.h>
#import "UIAlertView+Commodity.h"


@interface TableViewDemoViewController () <OHAttributedLabelDelegate>
@property(nonatomic, retain) NSArray* texts;
@end

static NSInteger const kAttributedLabelTag = 100;

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
        NSMutableArray* entries = [NSMutableArray arrayWithObjects:
                                   @"Visit http://www.apple.com now!",
                                   @"Go to http://www.foodreporter.net !",
                                   @"Start a search on http://www.google.com",
                                   nil];
        for(int i=0; i<20;++i)
        {
            [entries addObject:[NSString stringWithFormat:@"Call +1555-000-%04d from your iPhone", i]];
        }
        self.texts = entries;
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
        
        attrLabel = [[OHAttributedLabel alloc] initWithFrame:CGRectMake(10,10,300,tableView.rowHeight-20)];
        attrLabel.textAlignment = UITextAlignmentCenter;
        attrLabel.centerVertically = YES;
        attrLabel.font = [UIFont systemFontOfSize:16];
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
    attrLabel.text = [self.texts objectAtIndex:indexPath.row];
    return cell;
}

/////////////////////////////////////////////////////////////////////////////
#pragma mark - TableView Delegate
/////////////////////////////////////////////////////////////////////////////

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
