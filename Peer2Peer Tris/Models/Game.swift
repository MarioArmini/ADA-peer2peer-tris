//
//  Game.swift
//  TestPeer2Peer
//
//  Created by Fabio Palladino on 21/03/2020.
//  Copyright © 2020 Fabio Palladino. All rights reserved.
//

import Foundation
import UIKit
import MultipeerConnectivity

enum GameStep: String {
    case none = "none"
    case starting = "starting"
    case chooseMaster = "choose-master"
    case move = "move"
    case changePlayer = "change-player"
    case done = "done"
}
enum TrisPiece: String {
    case none = ""
    case X = "X"
    case O = "O"
}

struct GameCommand: Codable {
    var playerMove: String
    var moveToX: Int
    var moveToY: Int
    
    init(playerMove: TrisPiece, x: Int, y: Int) {
        self.playerMove = playerMove.rawValue
        self.moveToX = x
        self.moveToY = y
    }
}
struct GameMaster: Codable {
    var masterNumber: Int
    var name: String
    init(name: String) {
        self.masterNumber = Int.random(in: 0..<Int.max)
        self.name = name
    }
}
struct GameMessage: Codable {
    var step: String
    var name: String
    var command: GameCommand?
    var master: GameMaster?
    var currentPiece: String?
    
    init(step: GameStep, name: String) {
        self.step = step.rawValue
        self.name = name
    }
    init(step: GameStep, name: String, piece: TrisPiece) {
        self.step = step.rawValue
        self.name = name
        self.currentPiece = piece.rawValue
    }
    init(step: GameStep, name: String, command: GameCommand) {
        self.step = step.rawValue
        self.name = name
        self.command = command
    }
    func toJson() -> String {
        let encode = JSONEncoder()
        var jsonValue: Data?
        do {
            encode.outputFormatting = .prettyPrinted
            jsonValue = try encode.encode(self)
        }
        catch let error {
            print("toJson -> \(error)")
        }
        if jsonValue != nil {
            let jsonString = String(data: jsonValue!, encoding: .utf8)
            return jsonString ?? ""
        }
        return ""
    }
    
}
protocol GameDelegate {
    func onMessage(step: GameStep)
    func onMasterChoose(name: String)
}
class Game {
    
    var currentStep: GameStep
    var currentPiece: TrisPiece
    var tris: [[String]] = []
    var isMaster: Bool
    var session: Peer2PeerManager? // MCSession?
    var delegate: GameDelegate?
    var masterName: String
    var name: String
    var vsName: String
    var playerPiece: TrisPiece
    
    var masterSent: GameMaster?
    var masterReceive: GameMaster?
    
    init() {
        self.currentStep = .none
        self.currentPiece = .none
        self.isMaster = false
        self.masterName = ""
        self.name = ""
        self.vsName = ""
        self.playerPiece = .none
        self.session = AppDelegate.App.peer2peer
        
        tris.append(["","",""])
        tris.append(["","",""])
        tris.append(["","",""])
    }
    func clearState() {
        self.currentStep = .none
        self.currentPiece = .none
        self.isMaster = false
        self.masterName = ""
        //self.name = ""
        self.vsName = ""
        self.playerPiece = .none
        self.masterReceive = nil
        self.masterSent = nil
        
        tris.append(["","",""])
        tris.append(["","",""])
        tris.append(["","",""])
    }
    var waitingPlayer: Bool {
        get {
            return (currentPiece == playerPiece) ? false : true
        }
    }
    func printMatrix() {
        for i in 0..<3 {
            for j in 0..<3 {
                print("\(i)-\(j) = \(tris[i][j])")
            }
        }
    }
    func move(x: Int, y: Int, m: TrisPiece) {
        tris[x][y] = m.rawValue
        sendToPeer(message: GameMessage(step: GameStep.move, name: self.name, command: GameCommand(playerMove: self.playerPiece, x: x, y: y)))
    }
    func sendMove(x: Int, y: Int) {
        self.move(x: x, y: y, m: self.playerPiece)
    }
    func sendMessageStarting() {
        self.sendToPeer(message: GameMessage(step: .starting, name: self.name))
    }
    func sendChangePlayer() {
        self.sendToPeer(message: GameMessage(step: .changePlayer, name: self.name, piece: self.playerPiece))
        self.currentPiece = self.playerPiece
    }
    func sendMessageMaster() {
        var msg = GameMessage(step: .chooseMaster, name: self.name)
        self.masterSent = GameMaster(name: self.name)
        msg.master = self.masterSent!
        sendToPeer(message: msg)
        self.checkMaster()
    }
    func sendMessageDone() {
        self.sendToPeer(message: GameMessage(step: .done, name: self.name))
    }
    func startPlay() {
        if isMaster {
            let msg = GameMessage(step: .move, name: self.name)
            sendToPeer(message: msg)
        }
    }
    func sendToPeer(message: GameMessage) {
        if session != nil {
            self.currentStep = GameStep(rawValue: message.step)!
            session?.sendData(data: message.toJson().data(using: .utf8)!)
        }
        /*if session != nil && session!.connectedPeers.count > 0 {
            
            //print("Peer connected \(session?.connectedPeers.count)")
            do {
                self.currentStep = GameStep(rawValue: message.step)!
                try session!.send(message.toJson().data(using: .utf8)!, toPeers: session!.connectedPeers, with: .reliable)
                
            } catch let error as NSError {
             //let ac = UIAlertController(title: "Send error", message: error.localizedDescription, preferredStyle: .alert)
             //ac.addAction(UIAlertAction(title: "OK", style: .default))
             //resent(ac, animated: true)
                print(error)
            }
        } else {
            print("No peer connected")
        }*/
    }
    func receiveMessage(data: Data, callback: @escaping((Bool) -> Void)) {
        let output = String(data: data, encoding: .utf8)
        print(output!)
        let decoder = JSONDecoder()
        do {
            let obj = try decoder.decode(GameMessage.self, from: data)
            
            let step = GameStep(rawValue: obj.step)!
            switch(step) {
            case GameStep.none:
                print("GameStep.none")
            case GameStep.starting:
                print("GameStep.starting")
            case GameStep.chooseMaster:
                print("GameStep.chooseMaster")
                self.vsName = obj.name
                self.masterReceive = obj.master!
                self.checkMaster()
            case GameStep.move:
                print("GameStep.move")
                if obj.command != nil {
                    tris[obj.command!.moveToX][obj.command!.moveToY] = obj.command!.playerMove
                }
            case GameStep.changePlayer:
                print("GameStep.changePlayer \(obj.name) \(obj.currentPiece!)")
                if let currentPiece = TrisPiece(rawValue: obj.currentPiece!) {
                    self.currentPiece = currentPiece
                    self.currentStep = step
                }
            case GameStep.done:
                print("GameStep.done")
                self.currentStep = .done
            }
            
            callback(true)
            self.delegate?.onMessage(step: step)
        } catch let ex {
            print(ex)
        }
    }
    func checkMaster() {
        if self.masterReceive != nil && self.masterSent != nil {
            if self.masterSent!.masterNumber > self.masterReceive!.masterNumber {
                self.isMaster = true
                self.masterName = self.name
                self.playerPiece = .X
                self.currentPiece = self.playerPiece
            } else {
                self.isMaster = false
                self.masterName = self.masterReceive!.name
                self.playerPiece = .O
                self.currentPiece = .X
            }
            self.delegate?.onMasterChoose(name: self.masterName)
        }
        
    }
    func checkWins(p: String) -> Bool {
        
        for i in 0..<3 {
            if tris[i][0] == p && tris[i][1] == p && tris[i][2] == p {
                return true
            }
        }
        for i in 0..<3 {
            if tris[0][i] == p && tris[1][i] == p && tris[2][i] == p {
                return true
            }
        }
        
        if tris[0][0] == p && tris[1][1] == p && tris[2][2] == p {
            return true
        }
        
        if tris[2][0] == p && tris[1][1] == p && tris[0][2] == p {
            return true
        }
        
        return false
    }
}
