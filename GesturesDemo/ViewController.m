//
//  ViewController.m
//  GestureDemo
//  将一个单击和一次长按组合成一个完整动作，长按能滑动并实时计算偏移值
//
//  Created by huangzhaorong on 15/6/10.
//  Copyright (c) 2015年 huangzhaorong. All rights reserved.
//

#import "ViewController.h"

#define mainScreen [[UIScreen mainScreen] bounds]

@interface ViewController ()<UIGestureRecognizerDelegate>
{
    
    UITapGestureRecognizer *singleTap;                        //单击手势
    UILongPressGestureRecognizer *longPressRecognizer;        //长按手势
    UIPanGestureRecognizer *panRecognizer;        //长按手势
    
    BOOL hasTap;                //是否单击过
    BOOL hasLongPress;          //是否长按过
    BOOL finalResult;           //最终的动作是否完成
    
    NSTimer *timer;             //定时器
    NSDate *beginTime;          //单击完成时间
    NSDate *endTime;            //长按开始时间
    
    CGFloat maxWaitTime;        //单击和长按之间的时间间隔值
    
    CGPoint startLocation;      //长按开始坐标
    CGPoint translation;        //实时的偏移值
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setTitle:@"Demo"];
    [self.view setBackgroundColor:[UIColor yellowColor]];
    
    UILabel *gesture = [[UILabel alloc] initWithFrame:CGRectMake(mainScreen.size.width/2-50, mainScreen.size.height/2, 200, 100)];
    gesture.textColor = [UIColor blackColor];
    gesture.text = @"let's go!";
    [self.view addSubview:gesture];
    
    singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.delegate = self;
    [self.view addGestureRecognizer:singleTap];
    
//    longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressRecognizer:)];
//    longPressRecognizer.delegate = self;
//    [self.view addGestureRecognizer:longPressRecognizer];
    
    panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanRecognizer:)];
    panRecognizer.delegate = self;
    panRecognizer.maximumNumberOfTouches = 1;
    panRecognizer.minimumNumberOfTouches = 1;
    [self.view addGestureRecognizer:panRecognizer];
    
    maxWaitTime = 2.f;
    
}

//单击后开启定时器，并标记点击标志、记录开始时间
- (void)tapView:(UITapGestureRecognizer *)tap{
    finalResult = NO;
    
    if (singleTap.state == UIGestureRecognizerStateEnded) {
        if (!timer) {
            timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(listener) userInfo:nil repeats:YES];
        }
        //        [timer fire];
        hasTap = YES;
        beginTime = [NSDate date];
        NSLog(@"beginTime ====> %@",beginTime);
    }
    
}

//长按开始后记录结束时间，标记标志位，并判断是否在有效时间内的动作，同时计算偏移值
- (void)handleLongPressRecognizer:(UILongPressGestureRecognizer *)longPress{
    
    if (longPressRecognizer.state == UIGestureRecognizerStateBegan) {
        endTime = [NSDate date];
        NSLog(@"endTime ====> %@",endTime);
        
        hasLongPress = YES;
        NSTimeInterval waitTime = fabs([endTime timeIntervalSinceDate:beginTime]);
        if (waitTime <= maxWaitTime) {
            finalResult = YES;
            [self disabledTimer];
        }else{
            finalResult = NO;
        }
        
        //记录起始点
        startLocation = [longPressRecognizer locationInView:self.view];
    }
    
    if (longPressRecognizer.state == UIGestureRecognizerStateEnded) {
        
    }
    
    
    //移动中的坐标
    CGPoint moveLocation = [longPressRecognizer locationInView:self.view];
    //计算偏移量
    translation.x = moveLocation.x - startLocation.x;
    translation.y = moveLocation.y - startLocation.y;
    NSLog(@"finalResult  ====> %d,%f,%f",finalResult,translation.x,translation.y);
}

- (void)handlePanRecognizer:(UIPanGestureRecognizer *)pan{
    if (pan.state == UIGestureRecognizerStateBegan) {
        NSLog(@"handlePanRecognizer ---> %@",pan);
    }
//
}

//定时器策略，当时间超过maxWaitTime的值后，认为次动作未完成，并关闭定时器，重置各状态的初始值
- (void)listener{
    finalResult = NO;
    NSLog(@"[timer]:%@",[NSDate date]);
    NSTimeInterval waitTime = fabs([[NSDate date] timeIntervalSinceDate:beginTime]);
    if (waitTime > 0){
        if (waitTime <= maxWaitTime) {
            if (hasLongPress && hasTap) {
                finalResult = YES;
            }
        }else{
            [self disabledTimer];
            
            hasLongPress = NO;
            hasTap = NO;
            finalResult = NO;
        }
        
    }
    
    //    NSLog(@"finalResult listener ====> %d",finalResult);
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [self disabledTimer];
}

//关闭定时器
- (void)disabledTimer{
    [timer invalidate];
    timer = nil;
}

# pragma --delegate
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint pointer = [touch locationInView:self.view];
    CGPoint previousPointer = [touch previousLocationInView:self.view];
    
//    NSLog(@"touchesMoved ===> %f,%f",pointer.x,pointer.y);
//    NSLog(@"previousPointer =====> %f,%f",previousPointer.x,previousPointer.y);
}

- (void)touchesended:(NSSet *)touches withEvent:(UIEvent *)event{
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
        
        if (longPressRecognizer.state == UIGestureRecognizerStateChanged) {
            NSLog(@"this is a longpress recognizer");
        }
    }
    CGPoint pointer = [touch locationInView:self.view];
//    NSLog(@"gestureRecognizer =======> %f,%f",pointer.x,pointer.y);
    
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
