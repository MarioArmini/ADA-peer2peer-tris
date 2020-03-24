//
//  ConnectionViewController.swift
//  Peer2Peer Tris
//
//  Created by Mario Armini on 24/03/2020.
//  Copyright © 2020 Mario Armini. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ConnectionViewController: UIViewController, MCSessionDelegate,
MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate, UITableViewDataSource, UITableViewDelegate{
    
    var appDelegate:AppDelegate!
    
    var peerID : MCPeerID!
    var session : MCSession!
    var serviceAdvertiser : MCNearbyServiceAdvertiser!
    var serviceBrowser : MCNearbyServiceBrowser!
    
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var strValue = String()
    
    
    var foundPeers = [MCPeerID]()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*func willRunOnce() -> () {
            struct TokenContainer {
                static var token : dispatch_ = 0
            }
            
            dispatch_once(&TokenContainer.token) {
                appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.connViewController.setupPeerWithDisplayName(UIDevice.currentDevice().name)
                appDelegate.connViewController.setupSession()
                appDelegate.connViewController.advertiseSelf(true)
            }
            
        }*/
        
        tableView.tableFooterView = UIView()

        
        peerID = MCPeerID(displayName: UIDevice.current.name)
        session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .none)
        session.delegate = self
        
        self.serviceBrowser = MCNearbyServiceBrowser(peer: self.peerID, serviceType: "my-test")
        self.serviceBrowser.delegate = self
        self.serviceBrowser.startBrowsingForPeers()
        print("Browsing for peers...")
        
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: self.peerID, discoveryInfo: nil, serviceType: "my-test")
        self.serviceAdvertiser.delegate = self
        self.serviceAdvertiser.startAdvertisingPeer()
        print("Start advertising...")
        
        tableView.reloadData()
        
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print("session", peerID, state)
        switch state { case MCSessionState.connected:
            print("Connected to \(peerID.displayName)")
        case MCSessionState.connecting:
            print("Connecting to \(peerID.displayName)...")
        case MCSessionState.notConnected:
            print("Not Connected to \(peerID.displayName)")
        @unknown default:
            print("unknown default \(state)")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let str = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
       print("Value recieved: \(str)")
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("session DidReceive")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("session didStartReceivingResourceWithName")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        print("session didFinishReceivingResourceWithName")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        if !foundPeers.contains(peerID){
            foundPeers.append(peerID)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        print(foundPeers[0].displayName)
        
    }
    
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("Lost peer ", peerID)
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("You received an invitation from \(peerID)")
        invitationHandler(true, self.session)
        
    }
    

    @IBAction func scan(_ sender: Any) {
        self.serviceBrowser.stopBrowsingForPeers()
        self.serviceBrowser.startBrowsingForPeers()
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceAdvertiser.startAdvertisingPeer()
        
    }
    
    func sendData(data : Data){
        if session.connectedPeers.count > 0 {
            do {
                try session.send(data, toPeers: session.connectedPeers, with: .reliable)
            } catch let error as NSError {
                let ac = UIAlertController(title: "Send error", message: error.localizedDescription, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                present(ac, animated: true)
            }
        } else {
            print("No peer connected")
        }
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
        invitePeer(peer: foundPeers[indexPath.row])
        
    }
    
    func invitePeer(peer : MCPeerID){
        let alert = UIAlertController(title: nil, message: "Connecting to \(peer.displayName)", preferredStyle: .alert)
        

        present(alert, animated: true, completion: nil)
        
        self.serviceBrowser.invitePeer(peer, to: self.session, withContext: nil, timeout: 10)
        
        
        dismiss(animated: false, completion: nil)
        
        let data = "true".data(using: .utf8)!
        sendData(data: data)
    }
    
}
