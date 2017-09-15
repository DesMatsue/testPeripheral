//
//  StatusController.swift
//  testPeripheral
//
//  Created by Takakura 高倉 優介 on 2017/09/10.
//  Copyright © 2017年 DesMatsue. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth

class StatusController: UIViewController,CBPeripheralManagerDelegate,UITextFieldDelegate {
    var peripheralManager: CBPeripheralManager!
    var centralManager: CBCentralManager!
    var isSending:Bool = false
    private var peripheralArray = [CBPeripheral]()
    private var serviceArray = [CBService]()
    private var charasteristicArray = [CBCharacteristic]()
    
    @IBOutlet weak var dataUnitText: UITextField!
    @IBOutlet weak var dataIntervalUnit: UITextField!
    @IBOutlet weak var speedText: UILabel!
    @IBOutlet weak var buttonSubmit: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataUnitText.delegate = self
        dataIntervalUnit.delegate = self
        peripheralManager = CBPeripheralManager(delegate: self,queue: nil)
    }
    
    /*
     * Delegate or Protocol
     */
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        // 状態変化を取得する
        print("periState\(peripheral.state)")
    }
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        // startAdvertise
        if let error = error{
            print("\(error)")
            return
        }
        print("")
    }
    // invoked when remote central subscribes advertisement
    // * 引数を変えていないことが気になる
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        var arr:[UInt8] = []
        let serviceUUID = CBUUID(string: "5736A771-18DA-4DD6-8011-9AF47D6B7C20")
        let service = CBMutableService(type: serviceUUID, primary: true)
        guard let interval = Int(dataIntervalUnit.text!),
            let data = UInt8(dataUnitText.text!)
            else {
                // illegal input
                buttonSubmit.setTitle("Submit", for: UIControlState.normal)
                return
        }
        // byte配列を作成
        for _ in 1...data {
            arr.append(data)
        }
        // バイト変換
        let submitData = Data(bytes:arr)
        peripheralManager.setDesiredConnectionLatency(
            CBPeripheralManagerConnectionLatency.init(rawValue: interval)!, for: central)
        let charastericUUID = CBUUID(string: "9F392B50-34E2-453F-AE24-238FFE4CDEB5")
        let charasteristic = CBMutableCharacteristic(
            type: charastericUUID, properties: CBCharacteristicProperties.read,
            value: submitData, permissions: CBAttributePermissions.readable)
        service.characteristics = [charasteristic]
        self.peripheralManager.add(service)
        
    }
    
    /*
     * private methods
     */
    private func calcSpeed() {
        var resultDouble:Double
        do {
            resultDouble = try execCalculation(dataUnitText.text!, dataIntervalUnit.text!)
            speedText.text = String(resultDouble)
        } catch {
            speedText.text = "-"
        }
    }
    private func execCalculation(_ first:String, _ second:String)throws -> Double{
        guard let firstParameter = Double(first),let secondParameter = Double(second) else {
            throw NSError(domain: "aaa", code: -1, userInfo: nil)
        }
        return 8*firstParameter*(1000/secondParameter)
    }
    // startAdvertise
    private func startAdvertise(){
        if !isSending {
            peripheralManager.stopAdvertising()
        }else{
            let advertisementData = [CBAdvertisementDataLocalNameKey: "Test Device"]
            peripheralManager.startAdvertising(advertisementData)
        }
    }
    
    /*
    * event handler
    */
    @IBAction func stepperDidTap(_ sender: UIStepper) {
        dataUnitText.text = "\(sender.value)"
        calcSpeed()
    }
    @IBAction func stepperDidTap2(_ sender: UIStepper) {
        dataIntervalUnit.text = "\(sender.value)"
        calcSpeed()
    }
    @IBAction func submitAdvertise(_ sender: Any) {
        // Bloadcast Advertise
        isSending = !isSending
        buttonSubmit.setTitle(isSending ? "Stop":"Submit", for: UIControlState.normal)
        startAdvertise()
    }
}
