//
//  ProfileEditCell.m
//  DateMe
//
//  Created by Mayukh Bhaowal on 5/15/11.
//  Copyright 2011 Individual. All rights reserved.
//

#import "ProfileEditCell.h"



@implementation ProfileEditCell

@synthesize cellText;

/*- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	// The user can only edit the text field when in editing mode.
    [super setEditing:editing animated:animated];
	cellText.enabled = editing;
}
*/
#pragma mark Life Cycle events


- (void)dealloc {
	[cellText release]; cellText = nil;
    [super dealloc];
}


@end
