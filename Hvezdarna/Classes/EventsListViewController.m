//
//  EventsListViewController.m
//  Hvezdarna
//
//  Created by Michal Zelinka in 2013
//  Copyright (c) 2013- Michal Zelinka. All rights reserved.
//

#import "EventsListViewController.h"
#import "EventsListSectionView.h"
#import "EventsListCellView.h"
#import "EventsListViewModel.h"
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


@interface EventsListViewController ()
	<UITableViewDelegate, UITableViewDataSource,
#if !TARGET_OS_TV
	 UISearchDisplayDelegate,
#endif
	 UISearchBarDelegate>

@property (nonatomic, strong) EventsListViewModel *model;
@property (nonatomic, copy) NSArray<CalendarDay *> *displayedCalendar;

@end


#pragma mark - Implementation


@implementation EventsListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
	{
		__weak __auto_type ws = self;

		_model = [EventsListViewModel new];
		_model.updateHandler = ^{
			[ws reloadData];
		};

		self.title = @"Program";
		self.tabBarItem.image = [UIImage imageNamed:@"tab-calendar"];

		self.automaticallyAdjustsScrollViewInsets = NO;
		self.extendedLayoutIncludesOpaqueBars = NO;
		self.edgesForExtendedLayout = UIRectEdgeTop | UIRectEdgeBottom;

		[self reloadData];
	}

	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	_searchBar.clipsToBounds = NO;
//	CGFloat topOffset = kUINavigationBarHeight;
//	CGFloat bottomOffset = 0;
//	topOffset += kUIStatusBarHeight;
//	bottomOffset += kUITabBarHeight;
//	_tableView.contentInset = _tableView.scrollIndicatorInsets =
//		UIEdgeInsetsMake(topOffset, 0, bottomOffset, 0);

	object_setClass(_searchBar, [PositionedSearchBar class]);
	self.navigationItem.titleView = _searchBar;
//	_searchBar.width = _searchBar.superview.width;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

#if !TARGET_OS_TV
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
#endif

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
	NSInteger timestamp = _displayedCalendar[section].ID;

	NSString *title = [[NSString stringWithFormat:@"%@  %@",
		[Utils getLocalDayOfWeekStringFromTimestamp:timestamp],
		[Utils getLocalDateStringFromTimestamp:timestamp]]
		uppercaseString];

#if TARGET_OS_IOS == 1
	EventsListSectionView *view = [[EventsListSectionView alloc]
		initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 32)];

	[view setTitleText:title];
#else
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, 240, 44)];
	label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	label.textColor = [UIColor grayColor];
	label.font = [UIFont boldSystemFontOfSize:30];
	label.text = title;
	[view addSubview:label];
#endif

	return view;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return _displayedCalendar[section].events.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	NSInteger count = _displayedCalendar.count;

	tableView.hidden = (count == 0);

	return count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	EventsListCellView *cell = [tableView dequeueReusableCellWithIdentifier:@"program"];

	if (cell == nil) {
		if (!nibForCells)
			nibForCells = [UINib nibWithNibName:@"EventsListCellView" bundle:nil];
		NSArray *topLevelObjects = [nibForCells instantiateWithOwner:self options:nil];
		cell = [topLevelObjects objectAtIndex:0];
	}

	cell.event = _displayedCalendar[indexPath.section].events[indexPath.row];

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	__auto_type delegate = _delegate;

	EventsListCellView *cell = (EventsListCellView*)[tableView cellForRowAtIndexPath:indexPath];
	Event *event = cell.event;

	if (!delegate || !event) return;

	if ([delegate respondsToSelector:@selector(eventsListDidSelectEventToDisplay:)])
		[delegate eventsListDidSelectEventToDisplay:event];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	if ([_searchBar isFirstResponder])
		[_searchBar resignFirstResponder];
}

- (void)reloadData
{
	NSString *term = _searchBar.text;
	_displayedCalendar = [_model calendarForSearchTerm:term];
	[_tableView reloadData];
}


#if TARGET_OS_IOS == 1

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

	if (searchBar.text.length == 0)
		[self reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	[self reloadData];
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[searchBar setShowsCancelButton:NO animated:YES];
	[searchBar resignFirstResponder];
	[self reloadData];
}

#endif

@end
