//
//  ConnectionViewController.swift
//  Peer2Peer Tris
//
//  Created by Mario Armini on 24/03/2020.
//  Copyright © 2020 Mario Armini. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ConnectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, Peer2PeerManagerDelegate{
    
    
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var strValue = String()
    var nickName = String()
    let defaults = UserDefaults.standard
    
    
    var foundPeers = [MCPeerID]()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        let app = AppDelegate.App
        
        app.peer2peer.delegate = self
        scanButton.addTarget(self, action: #selector(scan(sender:)), for: .touchUpInside)
        
        tableView.tableFooterView = UIView()
        foundPeers = app.peer2peer.retrievePeers()
        tableView.reloadData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let app = AppDelegate.App
        foundPeers = app.peer2peer.retrievePeers()
        tableView.reloadData()
        print(foundPeers)
    }
    
    @objc func scan(sender: UIBarButtonItem) {
        let app = AppDelegate.App
        app.peer2peer.scan()
        self.foundPeers = app.peer2peer.retrievePeers()
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foundPeers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "peerCell", for: indexPath) as! PeerTableViewCell
        cell.peerLabel.text = foundPeers[indexPath.row].displayName
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let app = AppDelegate.App
        //app.peer2peer.invitePeer(peer: foundPeers[indexPath.row])
        showMessageNick(peer: foundPeers[indexPath.row])
    }
        
    func connectClient(peerID: MCPeerID) {
        print("Connected to \(peerID)")
    }
    
    func disconnectClient(peerID: MCPeerID) {
        print("Disconnected to \(peerID)")
    }
    
    func receiveMessage(data: Data) {
        print(data)
        self.strValue = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
    }
    
    func showMessageNick(peer: MCPeerID){
        DispatchQueue.main.async {
            let app = AppDelegate.App
            let ac = UIAlertController(title: "Tris", message: "Choose your nickname", preferredStyle: .alert)
            ac.addTextField { textField in
                textField.placeholder = "Nickname"
                textField.isSecureTextEntry = false
            }
            let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: {(action:UIAlertAction!) in
                guard let textField = ac.textFields?.first else { return }
                self.nickName = textField.text ?? "\(app.peer2peer.peerID.displayName)"
                app.peer2peer.invitePeer(peer: peer)
                self.defaults.set(self.nickName, forKey: "nickname")
                self.performSegue(withIdentifier: "segueGame", sender: self)
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
            ac.addAction(okAction)
            ac.addAction(cancelAction)
            self.present(ac,animated: true)
        }
        
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "segueGame" {
            print("controllo se è connesso")
        }
        return true
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    }
}
