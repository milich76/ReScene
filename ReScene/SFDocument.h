//
//  SFDocument.h
//  ReScene
//
//  Created by Michael Ilich on 2013-05-03.
//  Copyright (c) 2013 Sarofax. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SFDocument : NSDocument {
    IBOutlet NSPathCell *sourcePath;            // The krscene Source path selection widget
}

- (IBAction)selectSource :(id)sender;
- (IBAction)convertPushed:(id)sender;

@end
