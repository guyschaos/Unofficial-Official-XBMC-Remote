//
//  HostManagementViewController.m
//  XBMC Remote
//
//  Created by Giovanni Messina on 13/5/12.
//  Copyright (c) 2012 Korec s.r.l. All rights reserved.
//

#import "HostManagementViewController.h"
#import "HostViewController.h"
#import "AppDelegate.h"
#import "GlobalData.h"
#import "MasterViewController.h"
#import "mainMenu.h"

@interface HostManagementViewController ()

@end

@implementation HostManagementViewController

@synthesize hostController;

// TO BE OPTIMIZED: TO BE CHANGED FROM THE DEPENDENCIES FROM (MasterViewController *)controller TO NOTIFICATIONS FROM THE APPDELEGATE
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil masterController:(MasterViewController *)controller{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        masterViewController = controller;
    }
    return self;
}

#pragma mark - Button Mamagement

-(IBAction)addHost:(id)sender{
    self.hostController=nil;
    self.hostController = [[HostViewController alloc] initWithNibName:@"HostViewController" bundle:nil];
    AppDelegate *del = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [del.navigationController pushViewController:self.hostController animated:YES];
}

-(void)modifyHost:(NSIndexPath *)item{
    self.hostController=nil;
    self.hostController = [[HostViewController alloc] initWithNibName:@"HostViewController" bundle:nil] ;
    self.hostController.detailItem=item;
    AppDelegate *del = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [del.navigationController pushViewController:self.hostController animated:YES];
}

#pragma mark - Table view methods & data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    AppDelegate *mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([mainDelegate.arrayServerList count] == 0 && !tableView.editing) {
        return 1; 
    }
    return [mainDelegate.arrayServerList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=nil;
    cell = [tableView dequeueReusableCellWithIdentifier:@"serverListCell"];
    [[NSBundle mainBundle] loadNibNamed:@"serverListCellView" owner:self options:NULL];
    if (cell==nil){
        cell = serverListCell;
    }
    AppDelegate *mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([mainDelegate.arrayServerList count] == 0){
        [(UIImageView*) [cell viewWithTag:1] setHidden:TRUE];
        UILabel *cellLabel=(UILabel*) [cell viewWithTag:2];
        UILabel *cellIP=(UILabel*) [cell viewWithTag:3];
        cellLabel.textAlignment=UITextAlignmentCenter;
        [cellLabel setText:@"No saved hosts found"];
        [cellIP setText:@""];
        CGRect frame=cellLabel.frame;
        frame.origin.x=10;
        frame.origin.y=0;
        frame.size.width=300;
        frame.size.height=44;
        cellLabel.frame=frame;
        cell.accessoryType=UITableViewCellAccessoryNone;
        return cell;
    }
    else{
        [(UIImageView*) [cell viewWithTag:1] setHidden:FALSE];
        UILabel *cellLabel=(UILabel*) [cell viewWithTag:2];
        UILabel *cellIP=(UILabel*) [cell viewWithTag:3];
        cellLabel.textAlignment=UITextAlignmentLeft;
        NSDictionary *item=[mainDelegate.arrayServerList objectAtIndex:indexPath.row];
        [cellLabel setText:[item objectForKey:@"serverDescription"]];
        [cellIP setText:[item objectForKey:@"serverIP"]];
        CGRect frame=cellLabel.frame;
        frame.origin.x=66;
        frame.size.width=142;
        cellLabel.frame=frame;
        NSIndexPath *selection = [serverListTableView indexPathForSelectedRow];
        if (selection && indexPath.row == selection.row){
            cell.accessoryType=UITableViewCellAccessoryCheckmark;
        }
        else {
            cell.accessoryType=UITableViewCellAccessoryNone;
        }
    }
    return cell;
}

-(void)selectServerAtIndexPath:(NSIndexPath *)indexPath{
    storeServerSelection = indexPath;
    AppDelegate *mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSDictionary *item = [mainDelegate.arrayServerList objectAtIndex:indexPath.row];
    masterViewController.obj.serverDescription = [item objectForKey:@"serverDescription"];
    masterViewController.obj.serverUser = [item objectForKey:@"serverUser"];
    masterViewController.obj.serverPass = [item objectForKey:@"serverPass"];
    masterViewController.obj.serverIP = [item objectForKey:@"serverIP"];
    masterViewController.obj.serverPort = [item objectForKey:@"serverPort"];
    masterViewController.obj.preferTVPosters = [[item objectForKey:@"preferTVPosters"] boolValue];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        int thumbWidth = 320;
        int tvshowHeight = 61;
        if (masterViewController.obj.preferTVPosters==YES){
            thumbWidth = 53;
            tvshowHeight = 76;
        }
        [[self parentViewController] setTitle:@""];
        mainMenu *menuItem=[masterViewController.mainMenu objectAtIndex:2];
        menuItem.thumbWidth=thumbWidth;
        menuItem.rowHeight=tvshowHeight;
    }
    [masterViewController changeServerStatus:NO infoText:@"No connection"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    AppDelegate *mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([mainDelegate.arrayServerList count] == 0){
        [serverListTableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else{
        [masterViewController setFirstRun:NO];
        NSIndexPath *selection = [serverListTableView indexPathForSelectedRow];
        if (storeServerSelection && selection.row == storeServerSelection.row){
            UITableViewCell *cell = [serverListTableView cellForRowAtIndexPath:indexPath];
            [serverListTableView deselectRowAtIndexPath:selection animated:YES];
            cell.accessoryType = UITableViewCellAccessoryNone;
            storeServerSelection = nil;
            masterViewController.obj.serverDescription = @"";
            masterViewController.obj.serverUser = @"";
            masterViewController.obj.serverPass = @"";
            masterViewController.obj.serverIP = @"";
            masterViewController.obj.serverPort = @"";
            [masterViewController changeServerStatus:NO infoText:@"No connection"];
            NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
            if (standardUserDefaults) {
                [standardUserDefaults setObject:[NSNumber numberWithInt:-1] forKey:@"lastServer"];
                [standardUserDefaults synchronize];
            }
            
        }
        else{
            UITableViewCell *cell = [serverListTableView cellForRowAtIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [self selectServerAtIndexPath:indexPath];
            NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
            if (standardUserDefaults) {
                [standardUserDefaults setObject:[NSNumber numberWithInt:indexPath.row] forKey:@"lastServer"];
                [standardUserDefaults synchronize];
            }
        }
    }
}
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [serverListTableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType=UITableViewCellAccessoryNone;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (aTableView.editing) {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
	if (editingStyle == UITableViewCellEditingStyleDelete){
        AppDelegate *mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [mainDelegate.arrayServerList removeObjectAtIndex:indexPath.row];
        [mainDelegate saveServerList];
        if (storeServerSelection){
            NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
            if (indexPath.row<storeServerSelection.row){
                storeServerSelection=[NSIndexPath  indexPathForRow:storeServerSelection.row-1 inSection:storeServerSelection.section];
                if (standardUserDefaults) {
                    [standardUserDefaults setObject:[NSNumber numberWithInt:storeServerSelection.row] forKey:@"lastServer"];
                    [standardUserDefaults synchronize];
                }
            }
            else if (storeServerSelection.row==indexPath.row){
                storeServerSelection=nil;
                masterViewController.obj.serverDescription = @"";
                masterViewController.obj.serverUser = @"";
                masterViewController.obj.serverPass = @"";
                masterViewController.obj.serverIP = @"";
                masterViewController.obj.serverPort = @"";
                [masterViewController changeServerStatus:NO infoText:@"No connection"];
                [standardUserDefaults setObject:[NSNumber numberWithInt:-1] forKey:@"lastServer"];
                [standardUserDefaults synchronize];
            }
        }
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
	}   
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIImage *myImage = [UIImage imageNamed:@"blank.png"];
	UIImageView *imageView = [[UIImageView alloc] initWithImage:myImage] ;
	imageView.frame = CGRectMake(0,0,320,8);
	return imageView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 4;
}

- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIImage *myImage = [UIImage imageNamed:@"blank.png"];
	UIImageView *imageView = [[UIImageView alloc] initWithImage:myImage] ;
	imageView.frame = CGRectMake(0,0,320,8);
	return imageView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 4;
}

-(IBAction)editTable:(id)sender forceClose:(BOOL)forceClose{
    AppDelegate *mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([mainDelegate.arrayServerList count]==0 && !serverListTableView.editing) return;
    if (serverListTableView.editing || forceClose==YES){
        [serverListTableView setEditing:NO animated:YES];
        [editTableButton setSelected:NO];
        if ([mainDelegate.arrayServerList count] == 0)
            [serverListTableView reloadData];
        if (storeServerSelection){
            [serverListTableView selectRowAtIndexPath:storeServerSelection animated:YES scrollPosition:UITableViewScrollPositionMiddle];
            UITableViewCell *cell = [serverListTableView cellForRowAtIndexPath:storeServerSelection];
            cell.accessoryType=UITableViewCellAccessoryCheckmark;
        }
    }
    else{
        [serverListTableView setEditing:YES animated:YES];
        [editTableButton setSelected:YES];
    }
}

#pragma mark - Long Press & Action sheet

-(IBAction)handleLongPress{
    if (lpgr.state == UIGestureRecognizerStateBegan){
        CGPoint p = [lpgr locationInView:serverListTableView];
        NSIndexPath *indexPath = [serverListTableView indexPathForRowAtPoint:p];
        AppDelegate *mainDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if (indexPath != nil && indexPath.row<[mainDelegate.arrayServerList count]){
            NSLog(@"%@", storeServerSelection);
            if (storeServerSelection && indexPath.row == storeServerSelection.row){
                UITableViewCell *cell = [serverListTableView cellForRowAtIndexPath:indexPath];
                [serverListTableView deselectRowAtIndexPath:indexPath animated:YES];
                cell.accessoryType = UITableViewCellAccessoryNone;
                storeServerSelection = nil;
                masterViewController.obj.serverDescription = @"";
                masterViewController.obj.serverUser = @"";
                masterViewController.obj.serverPass = @"";
                masterViewController.obj.serverIP = @"";
                masterViewController.obj.serverPort = @"";
                [masterViewController changeServerStatus:NO infoText:@"No connection"];
                NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
                if (standardUserDefaults) {
                    [standardUserDefaults setObject:[NSNumber numberWithInt:-1] forKey:@"lastServer"];
                    [standardUserDefaults synchronize];
                }
            }
            [self modifyHost:indexPath];
        }
    }
}

#pragma mark - TableManagement from MasterViewController 

-(void)selectIndex:(NSIndexPath *)selection reloadData:(BOOL)reload{
    if (reload){
        NSIndexPath *checkSelection = [serverListTableView indexPathForSelectedRow];
        [serverListTableView reloadData];
        if (checkSelection){
            [serverListTableView selectRowAtIndexPath:checkSelection animated:YES scrollPosition:UITableViewScrollPositionMiddle];
            UITableViewCell *cell = [serverListTableView cellForRowAtIndexPath:checkSelection];
            cell.accessoryType=UITableViewCellAccessoryCheckmark;
        } 
    }
    else if (selection){
            [self selectServerAtIndexPath:selection];
            [serverListTableView selectRowAtIndexPath:selection animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}


#pragma mark - LifeCycle

- (void)viewDidLoad{
    [super viewDidLoad];
}

- (void)viewDidUnload{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end