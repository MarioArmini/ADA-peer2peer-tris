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
    
    
    var foundPeers = [MCPeerID]()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        let app = AppDelegate.App
        
        //scanButton.action = #selector(scan(sender:))
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
        print(strValue)
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
        let app = AppDelegate.App
        app.peer2peer.invitePeer(peer: foundPeers[indexPath.row])
    }
        
    func connectClient(peerID: MCPeerID) {
        print("Connected to \(peerID)")
        self.strValue = peerID.displayName
    }
    
    func disconnectClient(peerID: MCPeerID) {
        print("Disconnected to \(peerID)")
    }
    
    func receiveMessage(data: Data) {
        print(data)
        self.strValue = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
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
