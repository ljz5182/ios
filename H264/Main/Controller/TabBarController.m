//
//  TabBarController.m
//  H264
//
//  Created by 梁家章 on 2017/7/24.
//  Copyright © 2017年 梁家章. All rights reserved.
//

#import "TabBarController.h"
#import "DecodeController.h"
#import "EncodeController.h"



@interface TabBarController ()

@end

@implementation TabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.'
    
    // 全局设置item的文字属性
    [self setupItem];
    
    // 添加所有的子控制器
    [self setupAllChildVCs];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 添加所有的子控制器
- (void)setupAllChildVCs {
    
#pragma mark - 利用KVC设置tabBar的文字属性
    // 创建tabBarController子控制器
    [self setupChildVC:[[EncodeController alloc] init] title:@"编码" image:[UIImage imageNamed:@"tab_find_nor"] selectImage:[[UIImage imageNamed:@"tab_find_press"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    [self setupChildVC:[[DecodeController alloc] init] title:@"解码" image:[UIImage imageNamed:@"tab_homepage_nor"] selectImage:[[UIImage imageNamed:@"tab_homepage_press"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
}

/**
 * 添加一个子控制器
 * @param vc    控制器
 * @param title 文字
 * @param image 图片
 * @param selectImage 选中时的图片
 */
- (void)setupChildVC:(UIViewController *)vc title:(NSString *)title image:(UIImage *)image selectImage:(UIImage *)selectImage {
    
    [self addChildViewController:vc];
    vc.tabBarItem.title = title;
    vc.tabBarItem.image = image;
    vc.tabBarItem.selectedImage = selectImage;
    vc.view.backgroundColor = [UIColor grayColor];
}

#pragma mark - 全局设置tabBarItem的属性
- (void)setupItem {
    
    // 正常情况下tabBar的字体属性
    NSMutableDictionary *normalAttr = [NSMutableDictionary dictionary];
    // 设置文字的颜色
    normalAttr[NSForegroundColorAttributeName] = [UIColor grayColor];
    // 设置文字字体
    normalAttr[NSFontAttributeName] = [UIFont systemFontOfSize:13];
    // 选中情况下tabBar的字体属性
    NSMutableDictionary *selectedAttr = [NSMutableDictionary dictionary];
    // 设置选中时的颜色
    selectedAttr[NSForegroundColorAttributeName] = [UIColor darkGrayColor];
    
    // 统一一给所有的UITabBarItem设置文字属性
    // 只有后面带有UI_APPEARANCE_SELECTOR的属性或方法,才可以通过Appearance对象来统一设置控件的属性
    UITabBarItem *item = [UITabBarItem appearance];
    [item setTitleTextAttributes:normalAttr forState:UIControlStateNormal];
    [item setTitleTextAttributes:selectedAttr forState:UIControlStateSelected];
}

@end
