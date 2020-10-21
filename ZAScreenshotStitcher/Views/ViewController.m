//
//  ViewController.m
//  ZAConversationStitcher
//
//  Created by CPU11996 on 8/13/19.
//  Copyright © 2019 vng. All rights reserved.
//

#import "ViewController.h"
#import "ZAStitcherManager.h"
#import "ImageCollectionViewCell.h"
#import <QBImagePickerController/QBImagePickerController.h>

@interface ViewController () <QBImagePickerControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UIScrollViewDelegate>

@property (nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;
@property (nonatomic) QBImagePickerController *pickerViewController;

@property NSMutableArray *imageArray;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *resultImage;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;
@property (weak, nonatomic) IBOutlet UIButton *stitchButton;

@property (nonatomic) ZAStitcherManager *stitcher;

@end

@implementation ViewController

- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    [self setup];
    
}

- (void) setup {
    [self setupIndicator];
    [self setupCollectionView];
    [self setupScrollView];
    [self setupStitcher];
    
    _pickerViewController = [QBImagePickerController new];
    _pickerViewController.delegate = self;
    _pickerViewController.allowsMultipleSelection = YES;
    _pickerViewController.maximumNumberOfSelection = 6;
    _pickerViewController.showsNumberOfSelectedAssets = YES;

    _imageArray = [[NSMutableArray alloc] init];
}

- (void) setupCollectionView {
    _collectionView.dataSource = self;
}

- (void) setupStitcher {
    _stitcher = [[ZAStitcherManager alloc] init];
}

- (void) setupIndicator {
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.indicatorView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
    self.indicatorView.color = [UIColor grayColor];
    [self.view addSubview:self.indicatorView];
}

- (void) setupScrollView {
    [_scrollView setMaximumZoomScale:10.0];
    [_scrollView setClipsToBounds:YES];
}

# pragma mark - hanle actions:
- (IBAction) tappedOpenGalleryButton:(id)sender {
    [self presentViewController:_pickerViewController animated:YES completion:nil];
}

- (IBAction) tappedClearButton:(id)sender {
    [_imageArray removeAllObjects];
    [_collectionView reloadData];
    _resultImage.image = nil;
}

// START STITCH IMAGES:
- (IBAction) tappedStitchButton:(id)sender {

    _pickerViewController = [QBImagePickerController new];
    _pickerViewController.delegate = self;
    _pickerViewController.allowsMultipleSelection = YES;
    
    [self.collectionView reloadData];
    
    [_indicatorView startAnimating];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        // start timer:
        NSDate *methodStart = [NSDate date];
        
        // stitch:
        [self.stitcher stitchImages:self.imageArray completion:^(UIImage *result, NSError *error) {
            
            // complete stitch:
            NSDate *methodFinish = [NSDate date];
            NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
            
            // sitched all images:
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.indicatorView stopAnimating];
                if (!error) {
                    self.resultImage.image = result;
                    [self alertSuccess:executionTime];
                    [self.imageArray removeAllObjects];
                } else {
                    [self alertViewWithCode:error.code];
                }
            });
        }];
        
    });
}

# pragma mark - picker image delegate:
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    [_imageArray addObject:info[UIImagePickerControllerOriginalImage]];
    
    //[self dismissViewControllerAnimated:YES completion:nil];
    
    [_collectionView reloadData];
    _clearButton.enabled = true;
    if (_imageArray.count >= 2) {
        _stitchButton.enabled = true;
    }
}

# pragma mark - collectionview datasource:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellId" forIndexPath:indexPath];
    cell.imageView.image = self.imageArray[indexPath.row];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imageArray.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
# pragma mark - Scrollview Delegate
- (UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.resultImage;
}

# pragma mark - Private methods:
- (void) alertViewWithCode: (ZAStitchErrorCode) errorCode {
    NSString *alertContent;
    switch (errorCode) {
        case ZAStitchErrorCodeNotOverlap:
            alertContent = @"Error: Images Not Overlap.";
            break;
        case ZAStitchErrorCodeNotEqualWidth:
            alertContent = @"Error: Images Not Equal Width.";
            break;
        case ZAStitchErrorCodeNotEnoughImages:
            alertContent = @"Error: Need More Images";
            break;
        default:
            break;
    }
    
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"Warning!" message:alertContent preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [alertView addAction:alertAction];
    
    [self presentViewController:alertView animated:true completion:nil];
}

- (void) alertSuccess: (float) executionTime {
    NSString *alertContent;
    alertContent = [NSString stringWithFormat:@"Stitched successful %lu images. Execution time: %f (s)",(unsigned long)_imageArray.count,executionTime];
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"Success" message:alertContent preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [alertView addAction:alertAction];
    [self presentViewController:alertView animated:true completion:nil];
}

# pragma mark - QB Image Picker Delegate:
- (void) qb_imagePickerController:(QBImagePickerController *)imagePickerController didFinishPickingAssets:(NSArray *)assets {
    
    PHCachingImageManager *imageManager = [[PHCachingImageManager alloc] init];

    for (PHAsset *asset in assets) {
        [imageManager requestImageDataForAsset:asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            [self.imageArray addObject:[UIImage imageWithData:imageData]];
            [self.collectionView reloadData];
        }];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
