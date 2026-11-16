// Shared product presentation for discovery and device details.
#pragma once
#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <AIBudsFoundation/AIBudsFoundation-Swift.h>

static inline NSString *DemoProductName(AIBudsDeviceProduct product) {
    switch (product) {
        case AIBudsDeviceProductUnknown: return NSLocalizedString(@"LocKey.Unknown", nil);
        case AIBudsDeviceProductWatch: return NSLocalizedString(@"LocKey.SmartWatch", nil);
        case AIBudsDeviceProductRing: return NSLocalizedString(@"LocKey.SmartRing", nil);
        case AIBudsDeviceProductGlasses: return NSLocalizedString(@"LocKey.SmartGlasses", nil);
        case AIBudsDeviceProductChargingCase: return NSLocalizedString(@"LocKey.ChargingCase", nil);
        case AIBudsDeviceProductEarbuds: return NSLocalizedString(@"LocKey.Earbuds", nil);
        case AIBudsDeviceProductSpeaker: return NSLocalizedString(@"LocKey.SmartSpeaker", nil);
        case AIBudsDeviceProductHeadphones: return NSLocalizedString(@"LocKey.Headphones", nil);
        case AIBudsDeviceProductScreenlessBand: return NSLocalizedString(@"LocKey.ScreenlessBand", nil);
        case AIBudsDeviceProductScreenBand: return NSLocalizedString(@"LocKey.ScreenBand", nil);
        case AIBudsDeviceProductEyeMask: return NSLocalizedString(@"LocKey.EyeMask", nil);
        case AIBudsDeviceProductEarrings: return NSLocalizedString(@"LocKey.Earrings", nil);
        case AIBudsDeviceProductElectronicBadge: return NSLocalizedString(@"LocKey.ElectronicBadge", nil);
        default: return NSLocalizedString(@"LocKey.Unknown", nil);
    }
}

// Only new ABMate advertisements provide icon codes. Legacy devices use the default icon.
static inline UIImage *DemoAdvertisementIcon(NSDictionary<NSString *, id> *advertisement, AIBudsDeviceProduct product, AIBudsDeviceShape shape) {
    NSString *symbol = @"antenna.radiowaves.left.and.right";
    NSData *data = advertisement[CBAdvertisementDataManufacturerDataKey];
    if ([data isKindOfClass:NSData.class] && data.length == 15) {
        const uint8_t *bytes = data.bytes;
        if ((bytes[1] == 0x82 || bytes[1] == 0x83) && bytes[0] >= 0x01 && bytes[0] <= 0x0D) {
            // Product and shape come from the SDK; raw bytes only preserve legacy-icon fallback.
            switch (product) {
                case AIBudsDeviceProductScreenlessBand: symbol = @"capsule"; break;
                case AIBudsDeviceProductScreenBand: symbol = @"applewatch"; break;
                case AIBudsDeviceProductRing: symbol = @"circle"; break;
                case AIBudsDeviceProductEyeMask: symbol = @"sleep"; break;
                case AIBudsDeviceProductWatch:
                    if (shape == AIBudsDeviceShapeRound) symbol = @"clock";
                    else if (shape == AIBudsDeviceShapeSquare) symbol = @"applewatch";
                    break;
                case AIBudsDeviceProductGlasses: symbol = @"eyeglasses"; break;
                case AIBudsDeviceProductSpeaker: symbol = @"hifispeaker"; break;
                case AIBudsDeviceProductChargingCase: symbol = @"airpods.chargingcase"; break;
                case AIBudsDeviceProductEarrings: symbol = @"drop"; break;
                case AIBudsDeviceProductElectronicBadge: symbol = @"seal"; break;
                case AIBudsDeviceProductEarbuds: symbol = @"earbuds"; break;
                case AIBudsDeviceProductHeadphones: symbol = @"headphones"; break;
                default: break;
            }
        }
    }
    return [UIImage systemImageNamed:symbol] ?: [UIImage systemImageNamed:@"antenna.radiowaves.left.and.right"];
}
