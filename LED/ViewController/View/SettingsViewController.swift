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
import SwiftyJSON
import Alamofire

class SettingsViewController: BaseViewController , GCDAsyncUdpSocketDelegate{
    
    var queueUDP: DispatchQueue!
    var udpSendSocket: UDPClient!
    var udpReceiveSocket: GCDAsyncUdpSocket!
    var deviceListForUI: Array<String> = []
    var deviceListForCmd: Array<String> = []
    var menu: RSSelectionMenu<String>!
    let preferences = UserDefaults.standard
    
    /** command event number  ***/
    final var GET_HOSTNAME_EVENT = 101
    
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
                
                self.deviceListForUI.append("MAC:" + String(format:"%02X", deviceInfo[21]) + "-" + String(format:"%02X", deviceInfo[22]) + "-" + String(format:"%02X", deviceInfo[23]) + "-" + String(format:"%02X", deviceInfo[24]) + "-" + String(format:"%02X", deviceInfo[25]) + "-" + String(format:"%02X", deviceInfo[26]) + "\n" + String(deviceInfo[27]) + "." + String(deviceInfo[28]) + "." + String(deviceInfo[29]) + "." + String(deviceInfo[30]))
                self.deviceListForCmd.append(String(deviceInfo[27]) + "." + String(deviceInfo[28]) + "." + String(deviceInfo[29]) + "." + String(deviceInfo[30]))
                print(String(deviceInfo[27]) + "." + String(deviceInfo[28]) + "." + String(deviceInfo[29]) + "." + String(deviceInfo[30]))
            }
        }
        
    }
    //****** UDP Listener - End ******
    
}

extension SettingsViewController{
    
    //send HTTP GET method
    public func sendHTTPGET(ip:String, cmd: String, cmdNumber: Int){
        AF.request("http://" + ip + ":" + self.SERVER_PORT + "/" + cmd, method: .get).response{ response in
            //  debugPrint(response)
            
            switch response.result{
                
            case .success(let value):
                let json = JSON(value)
                
                debugPrint(json)
                switch(cmdNumber){
                    
                case self.GET_HOSTNAME_EVENT:
                    print("GET_HOSTNAME_EVENT")
                    if let hostname = json["hostname"].string{
                        self.hostnameEditText.text = hostname
                    }
                    break
                    
                default:
                    
                    break
                }
                
                break
                
            case .failure(let error):
                debugPrint("HTTP GET request failed")
                DispatchQueue.main.async {
                    self.showAlert(title: "Warning", message: "Can't connect to LED !")
                }
                break
            }
        }
    }
    
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
        
        DispatchQueue.main.async {
            self.showLoading()
        }
        
        self.deviceListForUI.removeAll()
        self.deviceListForCmd.removeAll()
        
        self.queueUDP.async {
            self.udpSendSocket.send(data: self.aesEncodeUDPCmd())
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { // Change `2.0` to the desired number of seconds.
            
            print("times up")
            
            if(self.deviceListForCmd.count > 0){
                
                DispatchQueue.main.async {
                    self.closeLoading()
                    var selectedNames: [String] = []
                    // create menu with data source -> here [String]
                    self.menu = RSSelectionMenu(dataSource: self.deviceListForUI) { (cell, name, indexPath) in
                        cell.textLabel?.text = name
                    }
                    // provide selected items
                    self.menu.setSelectedItems(items: selectedNames) { (name, index, selected, selectedItems) in
                        selectedNames = selectedItems
                        
                        print(self.deviceListForCmd[index])
                        self.ipEditText.text = self.deviceListForCmd[index]
                        self.queueUDP.async {
                            self.sendHTTPGET(ip: self.deviceListForCmd[index], cmd: HTTPHelper.CMD_HOSTNAME, cmdNumber: self.GET_HOSTNAME_EVENT)
                            self.preferences.set(self.deviceListForCmd[index], forKey: self.key_server_ip)
                        }
                    }
                    self.menu.show(from: self)
                }
                
            }else{
                DispatchQueue.main.async {
                    self.closeLoading()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.showAlert(title: "Warning", message: "Can't find any devices")
                }
            }
        }
    }
    
}
