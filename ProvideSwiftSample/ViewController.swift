//
//  ViewController.swift
//  ProvideSwiftSample
//
//  Created by Kevin Munc on 09/21/18.
//  Copyright © 2018 Method Up. All rights reserved.
//

import UIKit
import provide

class ViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    
    private var networkTransactions: Array<[String : Any]>!
    /* Example response element:
     {
     "id": "25762486-0e99-41a2-b79c-eb6bc8d257d3",
     "created_at": "2018-09-01T07:18:28.929692Z",
     "application_id": null,
     "user_id": null,
     "network_id": "024ff1ef-7369-4dee-969c-1918c6edb5d4",
     "wallet_id": "d2de919a-0d15-4c39-9446-454926a65a37",
     "to": "0x2aFc3E098605DaCFf1d8673324e41822A9F4Fd75",
     "value": 0,
     "data": "0x30b24a960000000000000000000000000000000000000000000000000000000000000000",
     "hash": "0x30fe8e1b18356fec27b8bf7c335682f34c839d3f1b7e1660146e971b2314dfa4",
     "status": "success",
     "params": null,
     "traces": null,
     "ref": "fe7c9ef5-4a09-4482-8a10-06d056e9517b"
     },
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Network Transactions"
        networkTransactions = Array<[String : Any]>()
        login()
    }
    
    // NOTE: This is not a good model for iOS applications.
    //       This is as super-quick and (very) _dirty_ as can be for the Hackathon. :D
    // FIXME: Implement an actual login screen and flow.
    private func login() {
        
        // --------------------------------------------
        // TODO: Replace these with your own credentials.
        //       Go to https://console.provide.services/#/signup if you need an account. 
        let email = "YOUR_PROVIDE_EMAIL_ADRESS"
        let password = "YOUR_PROVIDE_PASSWORD"
        // NOTE: Do _NOT_ commit your password.
        // --------------------------------------------
        
        
        try! ProvideIdent().authenticate(email: email,
                                         password: password,
                                         successHandler:
            { [weak self] (result) in
                if let authToken = result as? String {
                    print("WOOT! \(authToken)")
                    KeychainService.shared.authToken = authToken
                    self?.processTransactions()
                } else {
                    print("OOPS: \(String(describing: result))")
                }
        }) { (response, result, error) in
            print("NOOO! \(String(describing: error))")
        }
    }
    
    private func processTransactions() {
        let networkId = "024ff1ef-7369-4dee-969c-1918c6edb5d4"
        let params = [String : Any]()
        try! ProvideGoldmine().listNetworkTransactions(networkId: networkId, parameters: params, successHandler: { [weak self] (result) in
            if let result = result as? Data {
                let deserialized = try? JSONSerialization.jsonObject(with: result, options: .allowFragments)
                // print("Transactions List Result = '\(String(describing: deserialized))'")
                if let deserialized = deserialized as? Array<[String : Any]> {
                    print("MUNC: feed table with \(deserialized.count) transactions")
                    self?.networkTransactions = deserialized
                    self?.tableView.reloadData()
                } else {
                    print("NOOO!")
                }
            } else {
                print("NOOO!")
            }
        }) { (respose, result, error) in
            print("NOOO! \(String(describing: error))")
        }
    }
    
}

extension ViewController: UITableViewDelegate {
    
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return networkTransactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "TransactionCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        var txnId = ""
        let txn = networkTransactions[indexPath.row]
        if let transactionId = txn["id"] as? String {
            txnId = transactionId
        }
        cell.textLabel?.text = "Txn: \(txnId)"
        return cell
    }
    
}

