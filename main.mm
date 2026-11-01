#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <objc/runtime.h>

static id hooked_VKgetUdidFromKeyChain(id self, SEL _cmd) {
    return @"UDID_BYPASS";
}

static id hooked_VKgetIdfvFromKeyChain(id self, SEL _cmd) {
    return @"IDFV_BYPASS";
}

__attribute__((constructor)) void initAuthBypass() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        Class clientInfoClass = objc_getClass("ASClientInfo");
        if (clientInfoClass) {
            Method m1 = class_getInstanceMethod(clientInfoClass, @selector(VKgetUdidFromKeyChain));
            if (m1) {
                method_setImplementation(m1, (IMP)hooked_VKgetUdidFromKeyChain);
            }
            
            Method m2 = class_getInstanceMethod(clientInfoClass, @selector(VKgetIdfvFromKeyChain));
            if (m2) {
                method_setImplementation(m2, (IMP)hooked_VKgetIdfvFromKeyChain);
            }
        }
    });
}
