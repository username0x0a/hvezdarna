//
//  EventsListViewController.m
//  Hvezdarna
//
//  Created by Michal Zelinka in 2013
//  Copyright (c) 2013- Michal Zelinka. All rights reserved.
//

#import "EventsListViewController.h"
#import "EventDetailViewController.h"
#import "ProgramSectionView.h"
#import "ProgramCellView.h"
#import "Program.h"
#import "ProgramList.h"
#import "Utils.h"

#import <objc/runtime.h>


@interface PositionedSearchBar : UISearchBar
@end

@implementation PositionedSearchBar

- (void)customize
{
	if (isIOS7)
	{
		// Set tint color of bar elements
		self.tintColor = [UIColor colorWithRed:0.310f green:0.510f blue:0.714f alpha:1.00f];

		// Hide text field subviews and add custom-styled background
		for (UITextField *field in self.allSubviews)
			if ([field isKindOfClass:[UITextField class]])
			{
				UIView *container = field;
				for (UIView *v in container.subviews)
					v.hidden = YES;
				UIView *background = [[UIView alloc] initWithFrame:container.bounds];
				background.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
				background.backgroundColor = [UIColor whiteColor];
				background.layer.cornerRadius = 4;
				[container addSubview:background];
			}
	}

	else
	{
		// Just remove the bar background
		[self.subviews.firstObject removeFromSuperview];
	}
}

- (void)setFrame:(CGRect)frame
{
	if (!isIOS(8))
		[super setFrame:CGRectMake(0, 0, 320, frame.size.height)];
	else
		super.frame = frame;

	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[self customize];
	});
}

@end


@interface EventsListViewController () <UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate, UISearchBarDelegate>

@property(nonatomic,strong) ProgramList *list;
@property(nonatomic,copy) NSString *searchString;

@end


#pragma mark - Implementation


@implementation EventsListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
	{
		self.title = @"Program";
		if (isIOS7) {
			self.automaticallyAdjustsScrollViewInsets = NO;
			self.extendedLayoutIncludesOpaqueBars = NO;
			self.edgesForExtendedLayout = UIRectEdgeTop | UIRectEdgeBottom;
		}

		self.tabBarItem.image = [UIImage imageNamed:@"programme"];
		_list = [[ProgramList alloc] init];
		_searchString = @"";
    }

    return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	self.view.backgroundColor = [UIColor whiteColor];
	_searchBar.clipsToBounds = NO;
	CGFloat topOffset = kUINavigationBarHeight;
	CGFloat bottomOffset = 0;
	if (isIOS7) topOffset += kUIStatusBarHeight;
	if (isIOS7) bottomOffset += kUITabBarHeight;
	_tableView.contentInset = _tableView.scrollIndicatorInsets =
		UIEdgeInsetsMake(topOffset, 0, bottomOffset, 0);

	object_setClass(_searchBar, [PositionedSearchBar class]);
	self.navigationItem.titleView = _searchBar;
	_searchBar.width = _searchBar.superview.width;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

	if (isIOS7)
		[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];

	if (isIOS7) {
		self.navigationController.navigationBar.translucent = YES;
		self.navigationController.navigationBar.barTintColor = [UIColor colorWithWhite:.8 alpha:.8];
	}

    NSIndexPath *selection = [_tableView indexPathForSelectedRow];

    if (selection)
        [_tableView deselectRowAtIndexPath:selection animated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


#pragma mark -
#pragma mark Table view delegate


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
	}
	else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
		return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
	}
	return NO;
}
- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 68.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 31.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	ProgramSectionView *view = [[ProgramSectionView alloc]
		initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 32)];

	NSInteger timestamp = [self.list dayAtIndex:section];


	view.title.text = [[NSString stringWithFormat:@"%@   %@",
		[Utils getLocalDayOfWeekStringFromTimestamp:timestamp],
		[Utils getLocalDateStringFromTimestamp:timestamp]]
		uppercaseString];

	return view;
}


- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.list numberOfEventsOnDayIndex:section];
}

- (int)numberOfSectionsInTableView:(UITableView *)tableView
{
	NSInteger count = [self.list numberOfDays];

	if (isIPhone())
		[tableView setHidden:(count == 0)];
	else if (isIPad()) {
		if (count == 0) {
//			EventDetailViewController *detail = _splitViewController.delegate;
//			[detail.choose_event setText:@"Žádná představení"];
		}
	}
	
	return count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ProgramCellView     *cell   = (ProgramCellView*)[tableView dequeueReusableCellWithIdentifier:@"program"];
    if (cell == nil) {
        if (nibForCells == nil) {
			nibForCells = [UINib nibWithNibName:@"ProgramCellView" bundle:nil];
		}
		NSArray *topLevelObjects = [nibForCells instantiateWithOwner:self options:nil];
		cell = [topLevelObjects objectAtIndex:0];
    }

	[cell setProgram:[self.list programOnDayIdx:[indexPath section] atIdx:[indexPath row]]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	ProgramCellView *cell = (ProgramCellView*)[tableView cellForRowAtIndexPath:indexPath];

	EventDetailViewController *vc = [[EventDetailViewController alloc] initWithNibName:@"EventDetailViewController" bundle:nil];

	vc.program = cell.program;

	if (isIPhone())
		[self.navigationController pushViewController:vc animated:YES];

	else if (isIPad())
	{
		///// FIXXXXXX THIIIIIISSSS STUFFFFFFF!.,:!
		[self.splitViewController viewWillAppear:YES];
		[self.splitViewController viewWillDisappear:YES];
		NSMutableArray *viewControllerArray = [[NSMutableArray alloc] initWithArray:[[self.splitViewController.viewControllers objectAtIndex:1] viewControllers]];
		[viewControllerArray removeLastObject];
		[viewControllerArray addObject:vc];
		self.splitViewController.delegate = vc;
		[[self.splitViewController.viewControllers objectAtIndex:1] setViewControllers:viewControllerArray animated:NO];
		[self.splitViewController viewWillAppear:YES];
	}
}


#pragma mark -
#pragma mark Search bar delegate


- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];

	if ([searchBar text].length == 0) {
		[self.list processSearchWord:searchBar.text];
		[_tableView reloadData];
	}
	else
		[searchBar setText:_searchString];
}

- (void)filterContentForSearchText:(NSString *)searchText scope:(NSString *)scope {
	NSLog(@"Filter content");
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
	return YES;
}

- (void)searchBar:(UISearchBar *)searchBar_ textDidChange:(NSString *)searchText {
	[self.list processSearchWord:[searchBar_ text]];
	[_tableView reloadData];
}

- (void) searchBarResultsListButtonClicked:(UISearchBar *)searchBar {
	NSLog(@"ResultsList");
}
- (void) searchBarBookmarkButtonClicked:(UISearchBar *)searchBar {
	NSLog(@"Bookmark");
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar_ {
	_searchString = [searchBar_ text];
    [searchBar_ setShowsCancelButton:NO animated:YES];
    [searchBar_ resignFirstResponder];
	[self.list processSearchWord:[searchBar_ text]];
	[_tableView reloadData];
}


@end
