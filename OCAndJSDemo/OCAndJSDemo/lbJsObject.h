//
//  lbJsObject.h
//  OCAndJSDemo
//
//  Created by 刘李斌 on 2020/6/11.
//  Copyright © 2020 Brilliance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

NS_ASSUME_NONNULL_BEGIN


@protocol lbJsObjectProtocol <JSExport>

JSExportAs(letJSImage, - (void)letShowImage:(NSString *)str);
JSExportAs(getSum, - (NSInteger)getSum:(NSInteger)num1 num2:(NSInteger)num2);
/**
 PropertyName   JS的方法名
 Selector              OC的方法(可以是私有方法)
 JSExportAs(PropertyName, Selector)
 */

@end

@interface lbJsObject : NSObject <lbJsObjectProtocol>

/** name */
@property (nonatomic, copy) NSString *name;

@end

NS_ASSUME_NONNULL_END
