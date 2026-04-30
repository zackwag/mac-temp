#import <Foundation/Foundation.h>
#import <IOKit/IOKitLib.h>

// Private IOHIDEventSystem API declarations
// These exist in IOKit.framework but aren't in public headers

typedef struct __IOHIDEventSystemClient * IOHIDEventSystemClientRef;
typedef struct __IOHIDServiceClient * IOHIDServiceClientRef;
typedef struct __IOHIDEvent * IOHIDEventRef;
typedef uint32_t IOHIDEventType;
typedef int32_t IOHIDEventField;

#define kIOHIDEventTypeTemperature 15
#define IOHIDEventFieldBase(type) (type << 16)
#define kIOHIDEventFieldTemperatureLevel IOHIDEventFieldBase(kIOHIDEventTypeTemperature)

extern IOHIDEventSystemClientRef IOHIDEventSystemClientCreate(CFAllocatorRef allocator);
extern int IOHIDEventSystemClientSetMatching(IOHIDEventSystemClientRef client, CFDictionaryRef match);
extern CFArrayRef IOHIDEventSystemClientCopyServices(IOHIDEventSystemClientRef client);
extern IOHIDEventRef IOHIDServiceClientCopyEvent(IOHIDServiceClientRef service, IOHIDEventType type, int options, uint64_t timestamp);
extern double IOHIDEventGetFloatValue(IOHIDEventRef event, IOHIDEventField field);
extern CFTypeRef IOHIDServiceClientCopyProperty(IOHIDServiceClientRef service, CFStringRef key);

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        BOOL jsonMode = NO;
        BOOL rawMode  = NO;
        for (int i = 1; i < argc; i++) {
            if (strcmp(argv[i], "--json") == 0) jsonMode = YES;
            if (strcmp(argv[i], "--raw")  == 0) rawMode  = YES;
        }

        IOHIDEventSystemClientRef system = IOHIDEventSystemClientCreate(kCFAllocatorDefault);
        if (!system) {
            fprintf(stderr, "Error: Could not create IOHIDEventSystemClient\n");
            return 1;
        }

        // Match only temperature sensor services
        NSDictionary *matching = @{
            @"PrimaryUsagePage": @(0xff00),
            @"PrimaryUsage":     @(5)
        };
        IOHIDEventSystemClientSetMatching(system, (__bridge CFDictionaryRef)matching);

        CFArrayRef services = IOHIDEventSystemClientCopyServices(system);
        if (!services || CFArrayGetCount(services) == 0) {
            fprintf(stderr, "No sensor services found. Try running with sudo.\n");
            return 1;
        }

        NSMutableArray *readings = [NSMutableArray array];

        CFIndex count = CFArrayGetCount(services);
        for (CFIndex i = 0; i < count; i++) {
            IOHIDServiceClientRef service = (IOHIDServiceClientRef)CFArrayGetValueAtIndex(services, i);

            CFStringRef name = (CFStringRef)IOHIDServiceClientCopyProperty(service, CFSTR("Product"));
            NSString *nameStr = name ? (__bridge_transfer NSString *)name : @"unknown";

            IOHIDEventRef event = IOHIDServiceClientCopyEvent(service, kIOHIDEventTypeTemperature, 0, 0);
            if (!event) continue;

            double temp = IOHIDEventGetFloatValue(event, kIOHIDEventFieldTemperatureLevel);
            CFRelease(event);

            if (temp <= 0 || temp >= 150) continue;

            [readings addObject:@{@"name": nameStr, @"temp": @(temp)}];
        }

        CFRelease(services);
        CFRelease(system);

        if (readings.count == 0) {
            fprintf(stderr, "No temperature readings found. Try running with sudo.\n");
            return 1;
        }

        [readings sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];

        if (rawMode) {
            // Prefer "tcal" as the primary calibrated temp
            NSDictionary *best = nil;
            for (NSDictionary *r in readings) {
                if ([r[@"name"] containsString:@"tcal"]) { best = r; break; }
            }
            if (!best) best = readings[0];
            printf("%.1f\n", [best[@"temp"] doubleValue]);

        } else if (jsonMode) {
            printf("{\n");
            for (NSUInteger i = 0; i < readings.count; i++) {
                NSDictionary *r = readings[i];
                printf("  \"%s\": %.1f%s\n",
                    [r[@"name"] UTF8String],
                    [r[@"temp"] doubleValue],
                    i < readings.count - 1 ? "," : "");
            }
            printf("}\n");

        } else {
            for (NSDictionary *r in readings) {
                printf("%-20s %.1f°C\n", [r[@"name"] UTF8String], [r[@"temp"] doubleValue]);
            }
        }
    }
    return 0;
}
