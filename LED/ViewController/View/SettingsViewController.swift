//
//  SettingsViewController.swift
//  LED
//
//  Created by 啟發電子 on 2021/2/17.
//  Copyright © 2021 gomax. All rights reserved.
//

import UIKit
import Network
import CryptoKit
import CocoaAsyncSocket
import CryptoSwift
import RSSelectionMenu
import Toast_Swift
import SwiftSocket

class SettingsViewController: BaseViewController , GCDAsyncUdpSocketDelegate{
    
    var queueUDP: DispatchQueue!
    var udpSendSocket: UDPClient!
    var udpReceiveSocket: GCDAsyncUdpSocket!
    
    @IBOutlet weak var hostnameEditText: UITextField!
    @IBOutlet weak var hostnameApplyBt: UIButton!
    @IBOutlet weak var ipEditText: UITextField!
    @IBOutlet weak var appVerLabel: UILabel!
    @IBOutlet weak var scanBt: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("SettingsViewController-viewDidLoad")
        self.queueUDP = DispatchQueue(label: "com.gomax.udp", qos: DispatchQoS.userInitiated)
        self.ipEditText.isUserInteractionEnabled = false
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        self.appVerLabel.text = "APP ver. " + String(version)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("SettingsViewController-viewWillAppear")
        self.udpReceiveSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
        queueUDP.async {
            do {
                self.udpReceiveSocket.setIPv4Enabled(true)
                self.udpReceiveSocket.setIPv6Enabled(false)
                try self.udpReceiveSocket.bind(toPort: 65088)
                try self.udpReceiveSocket.beginReceiving()
                print("socket create successful")
            } catch let error {
                print(error)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.queueUDP.async {
            self.udpSendSocket = UDPClient.init(address: "255.255.255.255", port: 5002)
            self.udpSendSocket.enableBroadcast()
        }
    }
    
    
    //****** UDP Listener - Start ******
    private func udpSocket(sock: GCDAsyncUdpSocket!, didConnectToAddress address: NSData!) {
        print("didConnectToAddress");
    }
    
    private func udpSocket(sock: GCDAsyncUdpSocket!, didNotConnect error: NSError!) {
        print("didNotConnect \(String(describing: error))")
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didSendDataWithTag tag: Int) {
        print("didSendDataWithTag")
    }
    
    private func udpSocket(sock: GCDAsyncUdpSocket!, didNotSendDataWithTag tag: Int, dueToError error: NSError!) {
        print("didNotSendDataWithTag")
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        print("receive")
        
        if(data != nil){
            var deviceInfo = aesDecode(data: data)
            if(deviceInfo.count > 0){
                print(String(deviceInfo[27]) + "." + String(deviceInfo[28]) + "." + String(deviceInfo[29]) + "." + String(deviceInfo[30]))
            }
        }
        
    }
    //****** UDP Listener - End ******
    
}

extension SettingsViewController{
    
    
    //encode udp cmd
    func aesEncodeUDPCmd() -> [Byte]{
        var aes = [Byte]()
        do {
            
            let key1:Array<Byte> = [0x00, 0x0b, 0x80, 0x00, 0x45, 0x54, 0x48, 0x5f, 0x52, 0x45, 0x51, 0x00, 0x00,0x00,0x00,0x00]
            //use AES-128-ECB mode
            aes = try AES(key: self.UDPKey.bytes, blockMode: ECB(), padding: .noPadding).encrypt(key1)
        } catch {}
        
        return aes
    }
    
    //deocode udp feedback
    func aesDecode(data: Data) -> [Byte]{
        var aes = [Byte]()
        do {
            
            //use AES-128-ECB mode
            aes = try AES(key: self.UDPKey.bytes, blockMode: ECB(), padding: .noPadding).decrypt(data.bytes)
        } catch {}
        
        return aes
    }
    
    
    @IBAction func sendUDP(sender: UIButton) {
        
        self.queueUDP.async {
            self.udpSendSocket.send(data: self.aesEncodeUDPCmd())
        }
    }
    
}
