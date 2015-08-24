//
//  SBBluetooth.m
//  SensorbergSDK
//
//  Copyright (c) 2014-2015 Sensorberg GmbH. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "SBBluetooth.h"

#import "SBBluetooth+Events.h"

@import tolo;

@implementation SBBluetooth

#pragma mark - SBBluetooth

- (void)requestAuthorization {
    if ([self authorizationStatus]!=SBBluetoothOn) {
        // fake scan to force bluetooth authorization request
        [self.bleManager scanForPeripheralsWithServices:nil options:nil];
        //
    }
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManager:(nonnull CBCentralManager *)central didConnectPeripheral:(nonnull CBPeripheral *)peripheral {
    
}

- (void)centralManager:(nonnull CBCentralManager *)central didDisconnectPeripheral:(nonnull CBPeripheral *)peripheral error:(nullable NSError *)error {
    
}

- (void)centralManager:(nonnull CBCentralManager *)central didDiscoverPeripheral:(nonnull CBPeripheral *)peripheral advertisementData:(nonnull NSDictionary<NSString *,id> *)advertisementData RSSI:(nonnull NSNumber *)RSSI {
    
}

- (void)centralManager:(nonnull CBCentralManager *)central didFailToConnectPeripheral:(nonnull CBPeripheral *)peripheral error:(nullable NSError *)error {
    
}

- (void)centralManager:(nonnull CBCentralManager *)central willRestoreState:(nonnull NSDictionary<NSString *,id> *)dict {
    
}

- (void)centralManagerDidUpdateState:(nonnull CBCentralManager *)central {
    PUBLISH(({
        SBEBluetoothAuthorization *event = [SBEBluetoothAuthorization new];
        event.bluetoothAuthorization = [self authorizationStatus];
        event;
    }));
}

#pragma mark - CBPeripheralDelegate

- (void)peripheral:(nonnull CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error {
    
}

- (void)peripheral:(nonnull CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(nonnull CBService *)service error:(nullable NSError *)error {
    
}

- (void)peripheral:(nonnull CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(nonnull CBService *)service error:(nullable NSError *)error {
    
}

- (void)peripheral:(nonnull CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error {
    
}

- (void)peripheral:(nonnull CBPeripheral *)peripheral didUpdateValueForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error {
    
}

- (void)peripheral:(nonnull CBPeripheral *)peripheral didUpdateValueForDescriptor:(nonnull CBDescriptor *)descriptor error:(nullable NSError *)error {
    
}

- (void)peripheral:(nonnull CBPeripheral *)peripheral didWriteValueForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error {

}

- (void)peripheral:(nonnull CBPeripheral *)peripheral didWriteValueForDescriptor:(nonnull CBDescriptor *)descriptor error:(nullable NSError *)error {
    
}

- (void)peripheral:(nonnull CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error {
    
}

- (void)peripheral:(nonnull CBPeripheral *)peripheral didReadRSSI:(nonnull NSNumber *)RSSI error:(nullable NSError *)error {
    
}

- (void)peripheralDidUpdateName:(nonnull CBPeripheral *)peripheral {
    
}

- (void)peripheral:(nonnull CBPeripheral *)peripheral didModifyServices:(nonnull NSArray<CBService *> *)invalidatedServices {
    
}

#pragma mark - CBPeripheralManagerDelegate

- (void)peripheralManagerDidUpdateState:(nonnull CBPeripheralManager *)peripheral {
    
}

- (void)peripheralManager:(nonnull CBPeripheralManager *)peripheral willRestoreState:(nonnull NSDictionary<NSString *,id> *)dict {
    
}

- (void)peripheralManager:(nonnull CBPeripheralManager *)peripheral didAddService:(nonnull CBService *)service error:(nullable NSError *)error {
    
}

- (void)peripheralManagerDidStartAdvertising:(nonnull CBPeripheralManager *)peripheral error:(nullable NSError *)error {
    
}

- (void)peripheralManager:(nonnull CBPeripheralManager *)peripheral central:(nonnull CBCentral *)central didSubscribeToCharacteristic:(nonnull CBCharacteristic *)characteristic {
    
}

- (void)peripheralManager:(nonnull CBPeripheralManager *)peripheral central:(nonnull CBCentral *)central didUnsubscribeFromCharacteristic:(nonnull CBCharacteristic *)characteristic {
    
}

- (void)peripheralManager:(nonnull CBPeripheralManager *)peripheral didReceiveReadRequest:(nonnull CBATTRequest *)request {
    
}

- (void)peripheralManager:(nonnull CBPeripheralManager *)peripheral didReceiveWriteRequests:(nonnull NSArray<CBATTRequest *> *)requests {
    
}

#pragma mark - Bluetooth status

- (SBBluetoothStatus)authorizationStatus {
    if (self.bleManager.state==0) {
        return SBBluetoothUnknown;
    } else if (self.bleManager.state<<CBCentralManagerStatePoweredOn) {
        return SBBluetoothOff;
    }
    //
    return SBBluetoothOn;
    //
}

#pragma mark - Helper methods

- (float)calculatedDistanceToBeacon:(float)calibratedRSSI rssi:(float)rssi {
    //
    float threshold = calibratedRSSI - rssi;
    float ratio = pow(10, threshold/10);
    return sqrt(ratio);
    //
}

@end
