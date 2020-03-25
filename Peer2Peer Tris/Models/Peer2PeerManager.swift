//
//  Peer2PeerManager.swift
//  Peer2Peer Tris
//
//  Created by Fabio Palladino on 24/03/2020.
//  Copyright © 2020 Mario Armini. All rights reserved.
//

import UIKit
import MultipeerConnectivity

protocol Peer2PeerManagerDelegate : class{
    func connectClient(peerID: MCPeerID)
    func disconnectClient(peerID: MCPeerID)
    func receiveMessage(data: Data)
}

class Peer2PeerManager: NSObject, MCSessionDelegate,MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate{
    
    var peerID : MCPeerID!
    var session : MCSession!
    var serviceAdvertiser : MCNearbyServiceAdvertiser!
    var serviceBrowser : MCNearbyServiceBrowser!
    weak var delegate: Peer2PeerManagerDelegate? = nil
    
    var strValue = String()
    var foundPeers = [MCPeerID]()
    
    override init() {
        super.init()
        
        
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
        
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print("session", peerID, state)
        switch state { case MCSessionState.connected:
            print("Connected to \(peerID.displayName)")
            delegate?.connectClient(peerID: peerID)
        case MCSessionState.connecting:
            print("Connecting to \(peerID.displayName)...")
        case MCSessionState.notConnected:
            print("Not Connected to \(peerID.displayName)")
            delegate?.disconnectClient(peerID: peerID)
        @unknown default:
            print("unknown default \(state)")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let str = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
        print("Value received: \(str)")
        delegate?.receiveMessage(data: data)
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
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        delegate?.disconnectClient(peerID: peerID)
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("You received an invitation from \(peerID)")
        invitationHandler(true, self.session)
    }
    
    func scan(){
        print("Scanning for players...")
        
        self.serviceBrowser.stopBrowsingForPeers()
        self.serviceBrowser.startBrowsingForPeers()
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceAdvertiser.startAdvertisingPeer()
    }
    
    func sendData(data : Data){
        if session.connectedPeers.count > 0 {
            do {
                for p in session.connectedPeers {
                    print("send \(p.displayName)")
                }
                /*
                for p in self.foundPeers {
                    print("send2 \(p.displayName)")
                }*/
                try session.send(data, toPeers: session.connectedPeers, with: .reliable)
                //delegate?.receiveMessage(data: data)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        } else {
            print("No peer connected")
        }
    }
    
    func retrievePeers() -> [MCPeerID]{
        return foundPeers
    }
    
    func invitePeer(peer : MCPeerID){
        self.serviceBrowser.invitePeer(peer, to: self.session, withContext: nil, timeout: 10)
        
        let data = "True".data(using: .utf8)!
        sendData(data: data)
    }
}
