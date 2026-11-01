#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <objc/runtime.h>

static id hooked_FakeUDID(id self, SEL _cmd) {
    return @"00008110-001A2B3C4D5E6F00";
}

static id hooked_FakeIDFV(id self, SEL _cmd) {
    return @"E621E1F8-C36C-495A-93FC-0C247A3E6E5F";
}

static BOOL hooked_ReturnNO(id self, SEL _cmd) {
    return NO;
}

static int hooked_ActivationState(id self, SEL _cmd) {
    return 1;
}

static void hooked_NoOp(id self, SEL _cmd) {
}

static void hookSelectorOnClass(Class cls, SEL sel, IMP newImp) {
    if (!cls) return;
    Method instMethod = class_getInstanceMethod(cls, sel);
    if (instMethod) {
        method_setImplementation(instMethod, newImp);
    }
    Method clsMethod = class_getClassMethod(cls, sel);
    if (clsMethod) {
        method_setImplementation(clsMethod, newImp);
    }
}

static void applyAuthBypass() {
    const char *deviceClasses[] = {
        "VKKeychainIDFV",
        "ASClientInfo",
        "DeviceInfo",
        "ASStatusUDIDAlertView",
        "ASDebugSessionManager"
    };
    
    SEL udidSelectors[] = {
        sel_registerName("VKgetUdidFromKeyChain"),
        sel_registerName("VKKeychainUDID"),
        sel_registerName("getDeviceIdentifier")
    };
    
    SEL idfvSelectors[] = {
        sel_registerName("VKgetIdfvFromKeyChain"),
        sel_registerName("VKKeychainIDFV"),
        sel_registerName("VKKeychainIDFVWithCacheStatus:"),
        sel_registerName("identifierForVendor")
    };

    for (int i = 0; i < sizeof(deviceClasses) / sizeof(deviceClasses[0]); i++) {
        Class cls = objc_getClass(deviceClasses[i]);
        if (!cls) continue;
        
        for (int j = 0; j < sizeof(udidSelectors) / sizeof(udidSelectors[0]); j++) {
            hookSelectorOnClass(cls, udidSelectors[j], (IMP)hooked_FakeUDID);
        }
        for (int k = 0; k < sizeof(idfvSelectors) / sizeof(idfvSelectors[0]); k++) {
            hookSelectorOnClass(cls, idfvSelectors[k], (IMP)hooked_FakeIDFV);
        }
        
        hookSelectorOnClass(cls, sel_registerName("activationState"), (IMP)hooked_ActivationState);
    }

    const char *uiClasses[] = {
        "ASStatusUDIDAlertView",
        "ASStatusView",
        "APIClientOverlayViewController",
        "APIClientOverlayWindow",
        "FCAlertView",
        "DTTJailbreakDetection"
    };

    SEL blockUISelectors[] = {
        sel_registerName("showLoginForm"),
        sel_registerName("setupLoginForm"),
        sel_registerName("showLoginFormWithTitle:description:placeholder:submitTitle:contactTitle:countdownFrom:"),
        sel_registerName("showExpiredForm"),
        sel_registerName("setupExpiredForm"),
        sel_registerName("showExpiredWithTitle:message:changeKeyTitle:copyUDIDTitle:copyKeyTitle:countdownFrom:"),
        sel_registerName("showUDIDAlertWithTitle:message:leftTitle:rightTitle:leftAction:rightAction:"),
        sel_registerName("showAlertView"),
        sel_registerName("showLoginError:"),
        sel_registerName("showLoginLoading"),
        sel_registerName("startCountdownTimer"),
        sel_registerName("countdownTimerFired"),
        sel_registerName("scheduleExpiry")
    };

    for (int i = 0; i < sizeof(uiClasses) / sizeof(uiClasses[0]); i++) {
        Class cls = objc_getClass(uiClasses[i]);
        if (!cls) continue;
        
        for (int j = 0; j < sizeof(blockUISelectors) / sizeof(blockUISelectors[0]); j++) {
            hookSelectorOnClass(cls, blockUISelectors[j], (IMP)hooked_NoOp);
        }
        hookSelectorOnClass(cls, sel_registerName("isAlertVisible"), (IMP)hooked_ReturnNO);
    }
}

__attribute__((constructor)) static void initAuthBypass() {
    applyAuthBypass();
    dispatch_async(dispatch_get_main_queue(), ^{
        applyAuthBypass();
    });
}
