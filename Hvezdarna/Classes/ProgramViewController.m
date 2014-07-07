//
//  ProgramViewController.m
//  Hvezdarna
//
//  Created by Michal Zelinka in 2013
//  Copyright (c) 2013- Michal Zelinka. All rights reserved.
//

#import "ProgramViewController.h"
#import "ProgramDetailViewController.h"
#import "ProgramSectionView.h"
#import "ProgramCellView.h"
#import "Program.h"
#import "ProgramList.h"
#import "Utils.h"

@interface ProgramViewController () <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic,strong) ProgramList *list;
@property(nonatomic,copy) NSString *search_string;

@end


#pragma mark - Implementation


@implementation ProgramViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
	{
		self.title = @"Program";
		if (isIOS7) {
			self.automaticallyAdjustsScrollViewInsets = NO;
			self.extendedLayoutIncludesOpaqueBars = NO;
			self.edgesForExtendedLayout = UIRectEdgeNone;
		}

		self.tabBarItem.image = [UIImage imageNamed:@"programme"];
		self.list                 = [[ProgramList alloc] init];
		self.search_string        = @"";
    }

    return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	if (isIOS7) {
		self.view.backgroundColor = [UIColor colorWithRed:199/255.0 green:199/255.0 blue:204/255.0 alpha:1.0];
		_searchBar.top += kUIStatusBarHeight;
		_searchBar.backgroundImage = [UIImage new];
		_searchBar.backgroundColor = self.view.backgroundColor;
		_tableView.frame = self.view.bounds;
		_tableView.top += kUIStatusBarHeight;
		_tableView.height -= kUIStatusBarHeight-49;
		_tableView.contentInset = _tableView.scrollIndicatorInsets =
			UIEdgeInsetsMake(44, 0, 49, 0);
	}

//	_searchBar.backgroundImage = [UIImage imageNamed:@"navigation"];
//	[self.searchDisplayController setActive:self.searchWasActive];
//	[self.searchDisplayController.searchBar setSelectedScopeButtonIndex:self.savedScopeButtonIndex];
//	[self.searchDisplayController.searchBar setText:savedSearchTerm];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

	if (isIOS7)
		[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    [self.navigationController setNavigationBarHidden:YES animated:YES]; // ??
    
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
	return 32;
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
			ProgramDetailViewController *detail = _splitViewController.delegate;
			[detail.choose_event setText:@"Žádná představení"];
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

	ProgramDetailViewController *vc = [[ProgramDetailViewController alloc] initWithNibName:@"ProgramDetailViewController" bundle:nil];

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
		[searchBar setText:_search_string];
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
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
	_search_string = [searchBar_ text];
    [searchBar_ setShowsCancelButton:NO animated:YES];
    [searchBar_ resignFirstResponder];
	[self.list processSearchWord:[searchBar_ text]];
	[_tableView reloadData];
}


@end
