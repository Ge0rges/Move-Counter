//
//  JWImagePickerController.m
//  Kidstar
//
//  Created by Jonah Wallerstein on 2/14/13.
//
//

#import "WFImagePickerControllerPlus.h"


@interface WFImagePickerControllerPlus ()

@property (nonatomic, retain) UIImagePickerController* uiImagePicker;
@property (nonatomic, retain) UIView *galleryView;
@property bool galleryViewIsCurrent;

@end

@implementation WFImagePickerControllerPlus

float PADDING_TOP = 49;
float PADDING = 9;
int COLS = 3;

- (id)init
{
    self = [super init];
    if(self)
    {
        self.uiImagePicker = [[UIImagePickerController alloc] init];
        self.uiImagePicker.delegate = self;
        self.uiImagePicker.allowsEditing = YES;
        self.cancelButtonTitle = @"Cancel";
        [self addChildViewController:self.uiImagePicker];
    }
    return self;
}

-(void)setGalleryDataSource:(id<WFImagePickerControllerGalleryDataSource>)dataSource
{
    _galleryDataSource = dataSource;
    self.galleryViewIsCurrent = NO;
}

-(void)setSourceType:(JWSimpleImagePickerControllerSourceType)type
{
    _sourceType = type;
    if(type != JWSimpleImagePickerControllerSourceTypeGallery) {
        if (type == JWSimpleImagePickerControllerSourceTypeCamera) {
            self.uiImagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        } else if (type == JWSimpleImagePickerControllerSourceTypePhotoLibrary) {
            self.uiImagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        } else if (type == JWSimpleImagePickerControllerSourceTypeSavedPhotosAlbum) {
            self.uiImagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        }
    }
}

-(void)setGalleryTitle:(NSString *)galleryTitle
{
    _galleryTitle =galleryTitle;
    self.galleryViewIsCurrent = NO;
}

-(void)loadView
{
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    
    self.view = [[UIView alloc] initWithFrame:applicationFrame];
    
    self.galleryView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.galleryView.backgroundColor = [UIColor whiteColor];
    
    
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    if(self.sourceType == JWSimpleImagePickerControllerSourceTypeGallery)
    {
        [self createGalleryView];
    }
}

-(void)createGalleryView
{
    //add image container scroll view
    UIScrollView * imageContainer = [[UIScrollView alloc] initWithFrame:self.view.bounds];
	imageContainer.clipsToBounds = YES;
    
    [self.galleryView addSubview:imageContainer];
    
    //create top bar
    UINavigationBar* topBar = [[UINavigationBar alloc]
                               initWithFrame:CGRectMake(0, 5, [[UIScreen mainScreen] applicationFrame].size.width, 44)];
    
    topBar.barStyle = UIBarStyleDefault;
    
    //create container for cancel button and title
    UINavigationItem * itemContainer = [[UINavigationItem alloc] initWithTitle:self.galleryTitle];
    
    UIBarButtonItem *cancelButton =  [[UIBarButtonItem alloc] initWithTitle:self.cancelButtonTitle style:UIBarButtonItemStylePlain target:self action:@selector(imagePickerControllerDidCancel:)];
    
    //put it all together
    [itemContainer setRightBarButtonItem:cancelButton];
    topBar.items = @[itemContainer];
    [self.galleryView addSubview:topBar];
    
    float imgSize = 87.75;
    
    if(self.galleryDataSource) {
        int numImages = [self.galleryDataSource numberOfImagesInGalleryForImagePicker:self];
        int contentHeight = PADDING_TOP + ceil((double)numImages/COLS)*(imgSize + PADDING) + PADDING;
        if(contentHeight < self.view.frame.size.height)
            contentHeight = self.view.frame.size.height;
        imageContainer.contentSize = CGSizeMake(self.view.frame.size.width,contentHeight);
        
        for(int cntr=0; cntr<numImages; cntr++)
        {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setImage:[self.galleryDataSource imagePickerController:self  galleryImageAtIndex:cntr] forState:UIControlStateNormal];
            
            button.imageView.contentMode = UIViewContentModeScaleAspectFit;
            button.imageView.layer.cornerRadius = 5.0;
            button.imageView.clipsToBounds = YES;
            button.showsTouchWhenHighlighted = YES;
            button.userInteractionEnabled = YES;
            button.tag = cntr;
            [button addTarget:self action:@selector(galleryImageSelectedFromButton:) forControlEvents:UIControlEventTouchUpInside];
            
            
            float frameY = PADDING_TOP + PADDING + floor(cntr / COLS) * (imgSize + PADDING);
            float frameX = PADDING + (cntr % COLS) * (imgSize + PADDING);
            
            button.frame = CGRectMake(frameX+25, frameY, 50, 87.75);
            
            [imageContainer addSubview:button];
        }
    }
    
    self.galleryViewIsCurrent = YES;
}

-(void)galleryImageSelectedFromButton:(UIButton *)sender
{
    if (sender.tag == 0) {
        [self.delegate imagePickerController:self didFinishPickingImage:nil defaultImage:YES imageName:@"roundJump"];
    } else if (sender.tag == 1) {
        [self.delegate imagePickerController:self didFinishPickingImage:nil defaultImage:YES imageName:@"roundJumpRope"];
    } else if (sender.tag == 2) {
        [self.delegate imagePickerController:self didFinishPickingImage:nil defaultImage:YES imageName:@"roundRun"];
    } else if (sender.tag == 3) {
        [self.delegate imagePickerController:self didFinishPickingImage:nil defaultImage:YES imageName:@"roundWalk"];
    } else if (sender.tag == 4) {
        [self.delegate imagePickerController:self didFinishPickingImage:nil defaultImage:YES imageName:@"roundPullUp"];
    } else if (sender.tag == 5) {
        [self.delegate imagePickerController:self didFinishPickingImage:nil defaultImage:YES imageName:@"roundPushUp"];
    } else if (sender.tag == 6) {
        [self.delegate imagePickerController:self didFinishPickingImage:nil defaultImage:YES imageName:@"roundSitUp"];
    } else if (sender.tag == 7) {
        [self.delegate imagePickerController:self didFinishPickingImage:nil defaultImage:YES imageName:@"roundBoxing"];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    if(self.sourceType == JWSimpleImagePickerControllerSourceTypeGallery) {
        [self.uiImagePicker.view removeFromSuperview];
        if(!self.galleryViewIsCurrent)
            [self createGalleryView];
        [self.view addSubview:self.galleryView];
    }
    else
    {
        [self.galleryView removeFromSuperview];
        [self.view addSubview:self.uiImagePicker.view];
    }
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.delegate imagePickerControllerDidGoBack:self];
    
    id sharedApp = [UIApplication sharedApplication];
    [sharedApp setStatusBarHidden:NO animated:YES];
    [sharedApp setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self.delegate imagePickerController:self didFinishPickingImage:[info objectForKey:@"UIImagePickerControllerEditedImage"] defaultImage:NO imageName:nil];
    
    id sharedApp = [UIApplication sharedApplication];
    [sharedApp setStatusBarHidden:NO animated:YES];
    [sharedApp setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

@end
