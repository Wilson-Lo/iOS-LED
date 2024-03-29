//
//  BaseViewController.swift
//  LED
//
//  Created by 啟發電子 on 2021/2/17.
//  Copyright © 2021 gomax. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    var alert: UIAlertController!
    final let UDPKey = "qzy159pkn333rty2" //UDP AES key
    final let key_server_ip = "led_server_ip" //LED Server IP
    final let SERVER_PORT = "8080" //Server listening port
    let preferences = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.alert = UIAlertController(title: nil, message: "Please wait ...", preferredStyle: .alert)
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
}

extension BaseViewController{
    
    //show please wait dialog
    public func showLoading(){
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
    }
    
    //cancel please wait dialog
    public func closeLoading(){
        dismiss(animated: false, completion: nil)
    }
    
    //show alert dialog
    public func showAlert(title: String, message: String) {
        if(!message.isEmpty){
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            })
            present(alert, animated: true)
        }
    }
    
    public func getPreServerIP() -> String{
        if(self.preferences.value(forKey: self.key_server_ip) != nil){
            let fullIP = self.preferences.value(forKey: self.key_server_ip) as! String
            return fullIP
        }else{
            return ""
        }
    }
    
}

protocol ModalViewControllerDelegate:class {
    func dismissed()
}
