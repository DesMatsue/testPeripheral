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
    var perpheralManager: CBPeripheralManager!
    var centralManager: CBCentralManager!
    var isSending:Bool = false
    private var peripheralArray = [CBPeripheral]()
    private var serviceArray = [CBService]()
    private var charasteristicArray = [CBCharacteristic]()
    @IBOutlet weak var dataUnitText: UITextField!
    @IBOutlet weak var dataIntervalUnit: UITextField!
    @IBOutlet weak var speedText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataUnitText.delegate = self
        dataIntervalUnit.delegate = self
        
        perpheralManager = CBPeripheralManager(delegate: self,queue: nil)
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
        let advertisementData = [CBAdvertisementDataLocalNameKey: "Test Device"]
        perpheralManager.startAdvertising(advertisementData)
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
    }
}
