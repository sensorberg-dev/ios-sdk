//
//  BeaconsViewController.swift
//  SensorbergSDK
//
//  Created by Andrei Stoleru on 14/07/16.
//  Copyright © 2016 Sensorberg GmbH. All rights reserved.
//

import UIKit

import SensorbergSDK

import SensorbergSDK.NSString_SBUUID

class BeaconsViewController: UITableViewController {
    
    var beacons = NSMutableArray()
    
    let cellIdentifier = "beaconCell"

    override func viewDidLoad() {
        super.viewDidLoad()

//TODO: Enter API key
        
        let kAPIKey = "<< !!! ENTER API KEY HERE !!! >>"

        SBManager.shared().setApiKey(kAPIKey, delegate: self)
        
        SBManager.shared().requestLocationAuthorization(true)
        
        beacons = [];
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = "Beacons"
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beacons.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)

        let beacon:SBMBeacon = beacons.object(at: (indexPath as NSIndexPath).row) as! SBMBeacon

        let proximityUUID:String = beacon.uuid.uppercased()
        
        let beaconID:String = SensorbergSDK.defaultBeaconRegions()![proximityUUID] as! String
        
        if (!beaconID.isEmpty) {
            cell.textLabel?.text = beaconID
        } else {
            cell.textLabel?.text = beacon.uuid
        }
        
        cell.detailTextLabel?.text = "Major: " + String(beacon.major) + " Minor: " + String(beacon.minor)

        return cell
    }
 
    /*
     
     The method names have to be in the form "on"+<Event name>
     So, `SBEventLocationAuthorization` becomes `onSBEventLocationAuthorization`
     The full list of events is available at
     
     */
    
    @objc public func onSBEventLocationAuthorization(_ event:SBEventLocationAuthorization) {
        //        print(event)
        SBManager.shared().startMonitoring()
    }
    
    @objc public func onSBEventPerformAction(_ event:SBEventPerformAction) {
        print(event)
    }
    
    @objc public func onSBEventRegionEnter(_ event:SBEventRegionEnter) {
        beacons.add(event.beacon)
        self.tableView.reloadData()
    }
    
    @objc public func onSBEventRegionExit(_ event:SBEventRegionExit) {
        beacons.remove(event.beacon)
        self.tableView.reloadData()
    }

}
