//
//  ViewController.m
//  GoodnightMoon
//
//  Created by Johnny Appleseed on 1/14/15.
//  Copyright (c) 2015 MobileMakers. All rights reserved.
//

#import "ViewController.h"
#import "ImageCollectionViewCell.h"

@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollisionBehaviorDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) UICollisionBehavior *collisionBehavior;
@property (strong, nonatomic) UIDynamicItemBehavior *dynamicItemBehavior;
@property (strong, nonatomic) UIGravityBehavior *gravityBehavior;
@property (strong, nonatomic) UIDynamicAnimator *dynamicAnimator;
@property (strong, nonatomic) UIPushBehavior *pushBehavior;
@property (weak, nonatomic) IBOutlet UIView *shadeView;
@property NSMutableArray *moonImages;
@property NSMutableArray *sunImages;
@property NSMutableArray *currentImages;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.moonImages = [NSMutableArray new];
    [self.moonImages addObject:[UIImage imageNamed:@"moon_1"]];
    [self.moonImages addObject:[UIImage imageNamed:@"moon_2"]];
    [self.moonImages addObject:[UIImage imageNamed:@"moon_3"]];
    [self.moonImages addObject:[UIImage imageNamed:@"moon_4"]];
    [self.moonImages addObject:[UIImage imageNamed:@"moon_5"]];
    [self.moonImages addObject:[UIImage imageNamed:@"moon_6"]];

    self.sunImages = [NSMutableArray new];
    [self.sunImages addObject:[UIImage imageNamed:@"sun_1"]];
    [self.sunImages addObject:[UIImage imageNamed:@"sun_2"]];
    [self.sunImages addObject:[UIImage imageNamed:@"sun_3"]];
    [self.sunImages addObject:[UIImage imageNamed:@"sun_4"]];
    [self.sunImages addObject:[UIImage imageNamed:@"sun_5"]];
    [self.sunImages addObject:[UIImage imageNamed:@"sun_6"]];

    self.currentImages = self.moonImages;
}

-(void)viewDidAppear:(BOOL)animated
{
    self.dynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];

    self.collisionBehavior = [[UICollisionBehavior alloc] initWithItems:[NSArray arrayWithObject:self.shadeView]];
    self.gravityBehavior = [[UIGravityBehavior alloc] initWithItems:[NSArray arrayWithObject:self.shadeView]];
    self.dynamicItemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:[NSArray arrayWithObject:self.shadeView]];
    self.pushBehavior = [[UIPushBehavior alloc] initWithItems:[NSArray arrayWithObject:self.shadeView] mode:UIPushBehaviorModeContinuous];

    [self.collisionBehavior addBoundaryWithIdentifier:@"bottom"
                                            fromPoint:CGPointMake(0, -self.view.frame.size.height + 80)
                                              toPoint:CGPointMake(self.view.frame.size.width, -self.view.frame.size.height + 80)];

    [self.collisionBehavior addBoundaryWithIdentifier:@"top"
                                            fromPoint:CGPointMake(0, self.view.frame.size.height)
                                              toPoint:CGPointMake(self.view.frame.size.width, self.view.frame.size.height)];


    [self.gravityBehavior setGravityDirection:CGVectorMake(0, 0)];  // no gravity when the view loads

    [self.dynamicItemBehavior setElasticity:0.25];   // for bouncing off the boundaries

    [self.dynamicAnimator addBehavior:self.collisionBehavior];
    [self.dynamicAnimator addBehavior:self.gravityBehavior];
    [self.dynamicAnimator addBehavior:self.pushBehavior];
    [self.dynamicAnimator addBehavior:self.dynamicItemBehavior];

    self.collisionBehavior.collisionDelegate = self;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
     ImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.imageView.image = [self.currentImages objectAtIndex:indexPath.row];
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.currentImages.count;
}

- (IBAction)handlePan:(UIPanGestureRecognizer *)gesture
{
    //gets the translation
    CGPoint translation = [gesture translationInView:gesture.view];

    gesture.view.center = CGPointMake(gesture.view.center.x, gesture.view.center.y + translation.y);
    [gesture setTranslation:CGPointMake(0, 0) inView:gesture.view];

    CGFloat yVelocity = [gesture velocityInView:gesture.view].y;  // get the y velocity

    if (gesture.state == UIGestureRecognizerStateEnded) {

        [self.dynamicAnimator updateItemUsingCurrentState:self.shadeView];

        //Dragging up
        if (yVelocity < -500.0) {
            [self.gravityBehavior setGravityDirection:CGVectorMake(0, -1)];
            [self.dynamicItemBehavior setElasticity:0.5];
            [self.pushBehavior setPushDirection:CGVectorMake(0, [gesture velocityInView:gesture.view].y)];
        }
        else if (yVelocity >= -500.0 && yVelocity < 0) {
            [self.gravityBehavior setGravityDirection:CGVectorMake(0, -1)];
            [self.dynamicItemBehavior setElasticity:0.25];
            [self.pushBehavior setPushDirection:CGVectorMake(0, -500.0)];
        }
        else if (yVelocity >= 0 && yVelocity < 500.0) {
            [self.gravityBehavior setGravityDirection:CGVectorMake(0, 1)];
            [self.dynamicItemBehavior setElasticity:0.25];
            [self.pushBehavior setPushDirection:CGVectorMake(0, 500.0)];
        } else {
            [self.gravityBehavior setGravityDirection:CGVectorMake(0, 1)];
            [self.dynamicItemBehavior setElasticity:0.5];
            [self.pushBehavior setPushDirection:CGVectorMake(0, [gesture velocityInView:gesture.view].y)];
        }
    }
}

-(void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)p
{
    if (self.currentImages == self.moonImages)
    {
        self.currentImages = self.sunImages;
    }
    else
    {
        self.currentImages = self.moonImages;
    }
    [self.collectionView reloadData];
}

@end
