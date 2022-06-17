//
//  KSAreaButton.m
//  FastPair
//
//  Created by kiss on 2019/8/3.
//  Copyright © 2019 KSB. All rights reserved.
//

#import "KSAreaButton.h"

@implementation KSAreaButton

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    CGRect btnBouns = self.bounds;
    btnBouns = CGRectInset(btnBouns, -15, -15);
    // 若点击的点在新的bounds里，就返回YES
    return CGRectContainsPoint(btnBouns, point);
}

@end
