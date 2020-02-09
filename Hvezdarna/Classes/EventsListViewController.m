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
	// Set tint color of bar elements
	self.tintColor = [UIColor colorWithRed:0.310f green:0.510f blue:0.714f alpha:1.00f];

	// Hide text field subviews and add custom-styled background
	for (UITextField *field in self.allSubviews)
		if ([field isKindOfClass:[UITextField class]])
		{
			UIView *container = field;
			for (UIView *v in container.subviews)
				if ([NSStringFromClass(v.class) containsString:@"Background"])
					v.hidden = YES;
			UIView *background = [[UIView alloc] initWithFrame:container.bounds];
			background.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
			background.backgroundColor = [UIColor colorWithWhite:.94f alpha:1];
			background.layer.cornerRadius = (isIOS(11)) ? 10:4;
			[container insertSubview:background atIndex:0];
		}
}

- (void)setFrame:(CGRect)frame
{
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
		self.automaticallyAdjustsScrollViewInsets = NO;
		self.extendedLayoutIncludesOpaqueBars = NO;
		self.edgesForExtendedLayout = UIRectEdgeTop | UIRectEdgeBottom;

		self.tabBarItem.image = [UIImage imageNamed:@"programme"];
		_list = [ProgramList sharedList];
		_searchString = @"";
    }

    return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	self.view.backgroundColor = [UIColor whiteColor];
	_searchBar.clipsToBounds = NO;
//	CGFloat topOffset = kUINavigationBarHeight;
//	CGFloat bottomOffset = 0;
//	topOffset += kUIStatusBarHeight;
//	bottomOffset += kUITabBarHeight;
//	_tableView.contentInset = _tableView.scrollIndicatorInsets =
//		UIEdgeInsetsMake(topOffset, 0, bottomOffset, 0);

	object_setClass(_searchBar, [PositionedSearchBar class]);
	self.navigationItem.titleView = _searchBar;
	_searchBar.width = _searchBar.superview.width;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];

	self.navigationController.navigationBar.translucent = YES;
	self.navigationController.navigationBar.barTintColor = [UIColor colorWithWhite:.8 alpha:.8];

    NSIndexPath *selection = [_tableView indexPathForSelectedRow];

	if (selection)
		[_tableView deselectRowAtIndexPath:selection animated:YES];
}


#pragma mark -
#pragma mark Table view delegate


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 80.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 42.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	ProgramSectionView *view = [[ProgramSectionView alloc]
		initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 32)];

	NSInteger timestamp = [self.list dayAtIndex:section];

	NSString *title = [[NSString stringWithFormat:@"%@  %@",
		[Utils getLocalDayOfWeekStringFromTimestamp:timestamp],
		[Utils getLocalDateStringFromTimestamp:timestamp]]
		uppercaseString];

	[view setTitleText:title];

	return view;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.list numberOfEventsOnDayIndex:section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
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

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	if ([_searchBar isFirstResponder])
		[_searchBar resignFirstResponder];
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

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	[self.list processSearchWord:searchBar.text];
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
