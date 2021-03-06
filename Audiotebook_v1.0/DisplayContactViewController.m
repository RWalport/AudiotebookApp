//
//  DisplayContactViewController.m
//  Audiotebook_v1.0
//
//  Created by Robert Walport on 2/13/13.
//  Copyright (c) 2013 Hacks. All rights reserved.
//

#import "DisplayContactViewController.h"

@implementation DisplayContactViewController

@synthesize managedObjectContext;
@synthesize currentPicture;
@synthesize titleField, descriptionField, imageField, phoneField;
@synthesize imagePicker;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // If we are editing an existing picture, then put the details from Core Data into the text fields for displaying
    if (currentPicture)
    {
        [titleField setText:[currentPicture name]];
        [descriptionField setText:[currentPicture job]];
        if ([currentPicture smallPicture])
            [imageField setImage:[UIImage imageWithData:[currentPicture smallPicture]]];
    }
}

#pragma mark - Button actions

- (IBAction)editSaveButtonPressed:(id)sender
{
    // If we are adding a new picture (because we didnt pass one from the table) then create an entry
    if (!currentPicture)
        self.currentPicture = (Contact *)[NSEntityDescription insertNewObjectForEntityForName:@"Contact" inManagedObjectContext:self.managedObjectContext];
    
    // For both new and existing pictures, fill in the details from the form
    [self.currentPicture setName:[titleField text]];
    [self.currentPicture setJob:[descriptionField text]];
    [self.currentPicture setPhone:[phoneField text]];
    
    if (imageField.image)
    {
        // Resize and save a smaller version for the table
        float resize = 74.0;
        float actualWidth = imageField.image.size.width;
        float actualHeight = imageField.image.size.height;
        float divBy, newWidth, newHeight;
        if (actualWidth > actualHeight) {
            divBy = (actualWidth / resize);
            newWidth = resize;
            newHeight = (actualHeight / divBy);
        } else {
            divBy = (actualHeight / resize);
            newWidth = (actualWidth / divBy);
            newHeight = resize;
        }
        CGRect rect = CGRectMake(0.0, 0.0, newWidth, newHeight);
        UIGraphicsBeginImageContext(rect.size);
        [imageField.image drawInRect:rect];
        UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        // Save the small image version
        NSData *smallImageData = UIImageJPEGRepresentation(smallImage, 1.0);
        [self.currentPicture setSmallPicture:smallImageData];
    }
    
    //  Commit item to core data
    NSError *error;
    if (![self.managedObjectContext save:&error])
        NSLog(@"Failed to add new picture with error: %@", [error domain]);
    
    //  Automatically pop to previous view now we're done adding
    [self.navigationController popViewControllerAnimated:YES];
}

//  Pick an image from album
- (IBAction)imageFromAlbum:(id)sender
{
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

//  Take an image with camera
- (IBAction)imageFromCamera:(id)sender
{
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

//  Resign the keyboard after Done is pressed when editing text fields
- (IBAction)resignKeyboard:(id)sender
{
    [sender resignFirstResponder];
}

#pragma mark - Image Picker Delegate Methods

//  Dismiss the image picker on selection and use the resulting image in our ImageView
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    [imagePicker dismissModalViewControllerAnimated:YES];
    [imageField setImage:image];
}

//  On cancel, only dismiss the picker controller
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [imagePicker dismissModalViewControllerAnimated:YES];
}

- (void) prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    MainAudiotebookViewController* logView = segue.destinationViewController;
    if( [logView respondsToSelector: @selector (setManagedObjectContext:)] ) {
        [logView setValue:self.managedObjectContext forKey:@"managedObjectContext"];
    }
    
    logView.currentPicture = self.currentPicture;
}

- (IBAction)MakeCall:(id)sender {
    NSString *phoneNumber = phoneField.text; // dynamically assigned
    NSString *phoneURLString = [NSString stringWithFormat:@"tel:%@", phoneNumber];
    NSURL *phoneURL = [NSURL URLWithString:phoneURLString];
    [[UIApplication sharedApplication] openURL:phoneURL];
}
@end
