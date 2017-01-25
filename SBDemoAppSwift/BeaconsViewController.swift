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
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = "Beacons"
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return beacons.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)

        let beacon:SBMBeacon = beacons.object(at: (indexPath as NSIndexPath).row) as! SBMBeacon

        let proximityUUID:String = String.hyphenateUUIDString(beacon.uuid).uppercased()
        
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
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func onSBEventLocationAuthorization(_ event:SBEventLocationAuthorization) {
        //        print(event)
        SBManager.shared().startMonitoring()
    }
    
    func onSBEventPerformAction(_ event:SBEventPerformAction) {
        print(event)
    }
    
    func onSBEventRegionEnter(_ event:SBEventRegionEnter) {
        beacons.add(event.beacon)
        self.tableView.reloadData()
    }
    
    func onSBEventRegionExit(_ event:SBEventRegionExit) {
        beacons.remove(event.beacon)
        self.tableView.reloadData()
    }

}
