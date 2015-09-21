//
//  SFDocument.m
//  ReScene
//
//  Created by Michael Ilich on 2013-05-03.
//  Copyright (c) 2013 Sarofax. All rights reserved.
//

#import "SFDocument.h"

#import <stdint.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <assert.h>

@implementation SFDocument

- (id)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
        // If an error occurs here, return nil.
        
        [sourcePath setURL:[NSURL URLWithString:NSHomeDirectory()]];
    }
    return self;
}


- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"SFDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    /*
     Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
     You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
     */
    NSException *exception = [NSException exceptionWithName:@"UnimplementedMethod" reason:[NSString stringWithFormat:@"%@ is unimplemented", NSStringFromSelector(_cmd)] userInfo:nil];
    @throw exception;
    return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    /*
     Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning NO.
     You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
     If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
     */
    NSException *exception = [NSException exceptionWithName:@"UnimplementedMethod" reason:[NSString stringWithFormat:@"%@ is unimplemented", NSStringFromSelector(_cmd)] userInfo:nil];
    @throw exception;
    return TRUE;
}

- (IBAction)selectSource:(id)sender
{
    // Create a File Open Dialog class.
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    
    // Set array of file types
    NSArray *fileTypesArray;
    fileTypesArray = [NSArray arrayWithObjects:@"krscene", nil];
    
    // Enable options in the dialog.
    [openDlg setDirectoryURL:sourcePath.URL];
    [openDlg setCanChooseFiles:YES];
    [openDlg setCanChooseDirectories:NO];
    [openDlg setAllowedFileTypes:fileTypesArray];
    [openDlg setAllowsMultipleSelection:NO];
    
    // Display the dialog box.  If the OK pressed,
    // process the files.
    if ( [openDlg runModal] == NSOKButton ) {
        
        // Gets list of all files selected
        NSArray *files = [openDlg URLs];
        [sourcePath setURL:[NSURL URLWithString:[[files objectAtIndex:0] path]]];
        
    }
}


- (void) alertDidEnd:(NSAlert *) alert returnCode:(int) returnCode contextInfo:(int *) contextInfo
{
    switch (returnCode) {
        case 1001:
        {
            NSLog(@"Now processing file.");
            NSMutableArray *newLines = [NSMutableArray array];
            NSString *newContents = [NSMutableString string];
            
            NSString *contents = [NSString stringWithContentsOfFile:[sourcePath stringValue]  encoding:NSASCIIStringEncoding error:nil];
            NSArray *lines = [contents componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\r\n"]];
            
            for (NSString* line in lines) {
                NSArray *tokens = [line componentsSeparatedByString:@"light_map=\""];
                if ([tokens count] > 1) {
                    NSArray *subTokens = [[tokens objectAtIndex:1] componentsSeparatedByString:@"\""];
                    NSArray *subLM = [[subTokens objectAtIndex:0] componentsSeparatedByString:@"_"];
                    
                    if ([[subLM objectAtIndex:([subLM count]-2)] rangeOfString:@"LM"].location != NSNotFound) {
                        NSString *newline = [NSString stringWithFormat:@"%@ light_map=\"%@_%@",[tokens objectAtIndex:0], [subLM objectAtIndex:([subLM count]-2)],[subLM objectAtIndex:([subLM count]-1)]];
                        for (int i = 1; i < [subTokens count]; i++) {
                            newline = [newline stringByAppendingString:[NSString stringWithFormat:@"\"%@",[subTokens objectAtIndex:i]]];
                        }
                        [newLines addObject:[NSString stringWithFormat:@"%@",newline]];
                    } else {
                        [newLines addObject:[NSString stringWithFormat:@"%@",line]];                        
                    }
                } else { // tokens count = 1
                    [newLines addObject:[NSString stringWithFormat:@"%@",line]];
                }
            } // end for
            
            for (int ii=0; ii < [newLines count]; ii++) {                
                newContents = [newContents stringByAppendingString:[NSString stringWithFormat:@"%@\n", [newLines objectAtIndex:ii]]];
            }

            [newContents writeToFile:[sourcePath stringValue] atomically:YES encoding:NSASCIIStringEncoding error:nil];
            
            NSAlert *alert = [[[NSAlert alloc] init] autorelease];
            [alert addButtonWithTitle:@"Ok"];
            [alert setMessageText:@"KRScene File Processed"];
            [alert setInformativeText:[NSString stringWithFormat:@"Enjoy your grouped lightmaps!"]];
            [alert setAlertStyle:NSInformationalAlertStyle];
            [alert beginSheetModalForWindow:[[NSApplication sharedApplication] mainWindow] modalDelegate:self didEndSelector:nil contextInfo:nil];
        } // end case 1001
        break;
        default:
            break;
    }
    
}

- (IBAction)convertPushed:(id)sender
{
    
    if ([[sourcePath stringValue] hasSuffix:@".krscene"] || [[sourcePath stringValue] hasSuffix:@".krscene"]) {
        NSAlert *alert = [[[NSAlert alloc] init] autorelease];
        [alert addButtonWithTitle:@"No"];
        [alert addButtonWithTitle:@"Yes"];
        [alert setMessageText:@"Process File?"];
        [alert setInformativeText:[NSString stringWithFormat:@"%@?",[sourcePath stringValue]]];
        [alert setAlertStyle:NSInformationalAlertStyle];
        [alert beginSheetModalForWindow:[[NSApplication sharedApplication] mainWindow] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
        
    }
    else {
        NSAlert *alert = [[[NSAlert alloc] init] autorelease];
        [alert addButtonWithTitle:@"Ok"];
        [alert setMessageText:@"File Not Found"];
        [alert setInformativeText:[NSString stringWithFormat:@"Please select a krscene."]];
        [alert setAlertStyle:NSInformationalAlertStyle];
        [alert beginSheetModalForWindow:[[NSApplication sharedApplication] mainWindow] modalDelegate:self didEndSelector:nil contextInfo:nil];
    }
}

+ (BOOL)autosavesInPlace
{
    return TRUE;
}

@end
