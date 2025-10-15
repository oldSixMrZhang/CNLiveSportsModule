//
//  CNTraceConst.m
//  CNLiveNetAdd
//
//  Created by open on 2019/6/5.
//  Copyright © 2019 cnlive. All rights reserved.
//

#import "CNTraceConst.h"

@implementation CNTraceConst

//#ifdef Environment_ON
//////////////////////////////正式
//
//#ifdef IPA_APPSTORE
//// 正式企业
//// 填写你在API控制台申请的iOS类型的AK
//NSString * const AK = @"1249woAM397jz6uGFEfXY4MxRxfkGtIN";
//
////填写你在API控制台申请iOS类型AK时指定的Bundle Identifier
//NSString * const MCODE = @"com.cnlive.CNLiveNetAddInHouse";
//
//NSUInteger const serviceID = 214690;
//
//#else
//// 正式个人
//// 填写你在API控制台申请的iOS类型的AK
//NSString * const AK = @"KbQoyL7KebOF1CvHWHqKa61pf8nMhUL4";
//
////填写你在API控制台申请iOS类型AK时指定的Bundle Identifier
//NSString * const MCODE = @"com.cnlive.CNLiveNetAdd";
//
//NSUInteger const serviceID = 214690;
//
//#endif
//
//#else
////////////////////////////////////////测试
//
//#ifdef IPA_APPSTORE
//// 测试企业
//// 填写你在API控制台申请的iOS类型的AK
//NSString * const AK = @"Nb4bz9t32YnmTkqVKrNHtToPQAwWvjzK";
//
////填写你在API控制台申请iOS类型AK时指定的Bundle Identifier
//NSString * const MCODE = @"com.cnlive.CNLiveNetAddInHouse.debug";
//// 填写你在鹰眼轨迹管理台创建的鹰眼服务对应的ID
//NSUInteger const serviceID = 213511;
//
//#else
//// 测试个人
//// 填写你在API控制台申请的iOS类型的AK
//NSString * const AK = @"jjrZsIZYalD5IPOkjzCOOqkApKLtn8LW";
//
////填写你在API控制台申请iOS类型AK时指定的Bundle Identifier
//NSString * const MCODE = @"com.cnlive.CNLiveNetAdd.debug";
//// 填写你在鹰眼轨迹管理台创建的鹰眼服务对应的ID
//NSUInteger const serviceID = 213511;
//
//#endif
//
//#endif







NSString * const TrackServiceOperationResultNotification = @"TrackServiceOperationResultNotification";

NSString * const TrackServiceGetPushMessageNotification = @"TrackServiceGetPushMessageNotification";

@end
