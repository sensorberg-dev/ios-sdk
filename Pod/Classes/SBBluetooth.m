//
//  SBBluetooth.m
//  Demo
//
//  Created by Andrei Stoleru on 27/07/15.
//  Copyright © 2015 Sensorberg. All rights reserved.
//

#import "SBBluetooth.h"

@implementation SBBluetooth

#pragma mark - SBBluetooth



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

#pragma mark - Helper methods

- (float)calculatedDistanceToBeacon:(float)calibratedRSSI rssi:(float)rssi {
    //
    float threshold = calibratedRSSI - rssi;
    float ratio = pow(10, threshold/10);
    return sqrt(ratio);
    //
}

@end
