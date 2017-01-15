//
//  JWImagePickerController.h
//  Kidstar
//
//  Created by Jonah Wallerstein on 2/14/13.
//
//

#import <UIKit/UIKit.h>

@class WFImagePickerControllerPlus;
@protocol WFImagePickerControllerGalleryDataSource <NSObject>

-(UIImage *)imagePickerController: (WFImagePickerControllerPlus *)picker galleryImageAtIndex:(NSUInteger) index;
-(int)numberOfImagesInGalleryForImagePicker: (WFImagePickerControllerPlus *)picker;

@end

@protocol WFImagePickerControllerPlusDelegate <NSObject>

-(void)imagePickerController:(WFImagePickerControllerPlus *)picker didFinishPickingImage:(UIImage *)image defaultImage:(BOOL)defaultImage imageName:(NSString *)defaultImageName;
- (void)imagePickerControllerDidGoBack:(WFImagePickerControllerPlus *)picker;

@end

//custom enum so can have extra source type
typedef enum
{
    JWSimpleImagePickerControllerSourceTypePhotoLibrary = UIImagePickerControllerSourceTypePhotoLibrary,
    JWSimpleImagePickerControllerSourceTypeCamera = UIImagePickerControllerSourceTypeCamera,
    JWSimpleImagePickerControllerSourceTypeSavedPhotosAlbum = UIImagePickerControllerSourceTypeSavedPhotosAlbum,
    JWSimpleImagePickerControllerSourceTypeGallery
    
} JWSimpleImagePickerControllerSourceType;

@interface WFImagePickerControllerPlus : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic) JWSimpleImagePickerControllerSourceType sourceType;
@property (nonatomic, retain) id<WFImagePickerControllerGalleryDataSource> galleryDataSource;
@property (nonatomic, retain) id<WFImagePickerControllerPlusDelegate> delegate;
@property (nonatomic, retain) NSString * galleryTitle;
@property (nonatomic, retain) NSString * cancelButtonTitle;

@end
