//
//  TokenViewController.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit
import web3swift
import BigInt

class TokenViewController: UIViewController {
    
    @IBOutlet weak var qrImageView: UIImageView!
    @IBOutlet weak var tokenNameBalanceLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var copiedLabel: UILabel!
    @IBOutlet weak var copyAddressButton: UIButton!
    @IBOutlet weak var sendTokenButton: UIButton!
    
    
    var tokenBalance: String?
    var walletName: String?
    var walletAddress: String?
    
    convenience init(walletAddress: String,
                     walletName: String,
                     tokenBalance: String) {
        self.init()
        self.walletAddress = walletAddress
        self.walletName = walletName
        self.tokenBalance = tokenBalance
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Token"
        qrImageView.image = generateQRCode(from: walletAddress ?? "")
        addressLabel.text = walletAddress?.lowercased()
        tokenNameBalanceLabel.text = "\(CurrentToken.currentToken?.symbol ?? ""): \(tokenBalance ?? "0")"
        copiedLabel.alpha = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let balance = Float(tokenBalance!) else {
            sendTokenButton.isEnabled = false
            sendTokenButton.alpha = 0.5
            return
        }
        guard balance > 0 else {
            sendTokenButton.isEnabled = false
            sendTokenButton.alpha = 0.5
            return
        }
    }
    
    func generateQRCode(from string: String?) -> UIImage? {
        guard let string = string else {
            return nil
        }
        
        guard let code = Web3.EIP67Code(address: string)?.toString() else {
            return nil
        }
        
        let data = code.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        
        return nil
    }
    
    @IBAction func copyAddress(_ sender: UIButton) {
        UIPasteboard.general.string = walletAddress ?? ""
        
        DispatchQueue.main.async {
            self.copiedLabel.alpha = 0.0
            UIView.animate(withDuration: 1.0,
                           animations: {
                            self.copiedLabel.alpha = 1.0
            }, completion: { _ in
                UIView.animate(withDuration: 2.0, animations: {
                    self.copiedLabel.alpha = 0.0
                })
            })
        }
    }
    
    @IBAction func sendToken(_ sender: UIButton) {
        let sendSettingsViewController = SendSettingsViewController(
            walletName: walletName ?? "",
            tokenBalance: tokenBalance ?? "",
            walletAddress: walletAddress ?? "")
        self.navigationController?.pushViewController(sendSettingsViewController, animated: true)
    }
    
}

