//
//  GameViewController.swift
//  Peer2Peer Tris
//
//  Created by Fabio Palladino on 24/03/2020.
//  Copyright © 2020 Mario Armini. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class GameViewController: UIViewController, GameDelegate, Peer2PeerManagerDelegate {
    
    @IBOutlet weak var viewGrid: UIImageView!
    @IBOutlet weak var titoloLabel: UILabel!
    @IBOutlet weak var labelInfo: UILabel!
    
    @IBOutlet weak var noteTextView: UITextView!
    
    var buttons = [UIButton]()
    var coordButtons = [Int: CGPoint]()
    var game: Game!
    var timer: Timer?
    var app = AppDelegate.App
    let defaults = UserDefaults.standard
    var shapeLayer: CAShapeLayer?
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noteTextView.text = ""
        game = Game()
        let nickname = defaults.string(forKey: "nickname")
        game.name = nickname ?? app.peer2peer.peerID.displayName
        game?.delegate = self
        app.peer2peer.delegate = self
        // Do any additional setup after loading the view.
        titoloLabel.text = game.name
        
    }
    override func viewWillAppear(_ animated: Bool) {
    }
    override func viewDidAppear(_ animated: Bool) {
        
        let offset = viewGrid.layer.frame.origin
        let size = viewGrid.layer.frame
        let w: CGFloat = (size.width/3)
        let h: CGFloat = size.height/3
        let offsetY: CGFloat = -20.0
        
        //print(offset)
        //print(size)
        for x in 0...2 {
            for y in 0...2 {
                let x2 = CGFloat(offset.x) + (CGFloat(y) * w)
                let y2 = CGFloat(offset.y) + (CGFloat(x) * h) + offsetY
                
                let rc = CGRect(x: x2, y: y2, width: w, height: h).inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
                let btn = UIButton(frame: rc)
                btn.setTitle("", for: .normal)
                //bnt.backgroundColor = .red
                btn.addTarget(self, action: #selector(onClickPiece), for: .touchUpInside)
                btn.tag = buttons.count
                btn.autoresizesSubviews = false
                buttons.append(btn)
                coordButtons[btn.tag] = CGPoint(x: x, y: y)
                self.view.addSubview(btn)
            }
        }
        startTimer()
    }
    override func viewWillDisappear(_ animated: Bool) {
        game.clearState()
        game.sendMessageDone()
        stopTimer()
    }
    @objc func onClickPiece(sender: UIButton!) {
        
        if game.currentStep == .changePlayer {
            if game.waitingPlayer {
                showMessage("Deve muove l'altro giocatore \(game.vsName)")
            } else {
                let bnt = buttons[sender.tag]
                let xy = coordButtons[sender.tag]!
                if bnt.currentImage == nil {
                    let imageName = "image-" + game.playerPiece.rawValue.lowercased()
                    bnt.setImage(UIImage(named: imageName), for: .normal)
                    let x = Int(xy.x)
                    let y = Int(xy.y)
                    game.sendMove(x: x, y: y)
                } else {
                    addLog("Casella piena")
                }
            }
            
        } else {
            showMessage("Non sei in modalità play")
        }
    }
    func updateImage(x: Int, y: Int, piece: TrisPiece) {
        for i in 0..<coordButtons.count {
            if coordButtons[i]?.x == CGFloat(x) && coordButtons[i]?.y == CGFloat(y) {
                let bnt = buttons[i]
                let imageName = "image-" + piece.rawValue.lowercased()
                bnt.setImage(UIImage(named: imageName), for: .normal)
                break
            }
        }
    }
    func startTimer() {
        stopTimer()
        self.timer = Timer.scheduledTimer(timeInterval: 1.0,
                                        target: self,
                                        selector: #selector(self.mainTimer),
                                        userInfo: nil,
                                        repeats: true)
    }
    func stopTimer() {
       if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
    @objc func mainTimer() {
        self.manageGame()
    }
    func onMessage(step: GameStep) {
        if step == .none {
            
        } else if step == .starting {
            self.game.sendMessageMaster()
            addLog("invio scelta master")
        } else if step == .chooseMaster {
            addLog("il master è \(game.masterName)")
        } else if step == .changePlayer {
            if game.waitingPlayer {
                addLog("In attesa di \(game.vsName) \(game.currentPiece)")
                updateInfo("Waiting \(game.vsName)")
            } else {
                addLog("Tocca a me \(game.name)")
                updateInfo("I must move")
            }
        } else if step == .move {
            addLog("move mossa salvata ora tocca a me \(game.name) \(game.currentPiece)")
            if game.check1Win(){
                DispatchQueue.main.async {
                    self.victoryLine(xI: self.buttons[0].center.x-20, yI: self.buttons[0].center.y, xF: self.buttons[2].center.x+20, yF: self.buttons[2].center.y)
                }
            }
            if game.check2Win(){
                DispatchQueue.main.async {
                    self.victoryLine(xI: self.buttons[3].center.x-20, yI: self.buttons[3].center.y, xF: self.buttons[5].center.x+20, yF: self.buttons[5].center.y)
                }
            }
            if game.check3Win(){
                DispatchQueue.main.async {
                    self.victoryLine(xI: self.buttons[6].center.x-20, yI: self.buttons[6].center.y, xF: self.buttons[8].center.x+20, yF: self.buttons[8].center.y)
                }
            }
            if game.check4Win(){
                DispatchQueue.main.async {
                    self.victoryLine(xI: self.buttons[0].center.x, yI: self.buttons[0].center.y-20, xF: self.buttons[6].center.x, yF: self.buttons[6].center.y+20)
                }
            }
            if game.check5Win(){
                DispatchQueue.main.async {
                    self.victoryLine(xI: self.buttons[1].center.x, yI: self.buttons[1].center.y-20, xF: self.buttons[7].center.x, yF: self.buttons[7].center.y+20)
                }
            }
            if game.check6Win(){
                DispatchQueue.main.async {
                    self.victoryLine(xI: self.buttons[2].center.x, yI: self.buttons[2].center.y-20, xF: self.buttons[8].center.x, yF: self.buttons[8].center.y+20)
                }
            }
            if game.check7Win(){
                DispatchQueue.main.async {
                    self.victoryLine(xI: self.buttons[0].center.x-10, yI: self.buttons[0].center.y-10, xF: self.buttons[8].center.x+10, yF: self.buttons[8].center.y+10)
                }
            }
            if game.check8Win(){
                DispatchQueue.main.async {
                    self.victoryLine(xI: self.buttons[6].center.x-10, yI: self.buttons[6].center.y-10, xF: self.buttons[2].center.x+10, yF: self.buttons[2].center.y+10)
                }
            }
            if game.checkWins(p: game.currentPiece.rawValue) {
                game.sendMessageDone()
                showMessageEnd("You Lose!")
            } else {
                game.sendChangePlayer()
            }
        } else if step == .done {
            addLog("done")
            game.sendChangePlayer()
            if game.check1Win(){
                DispatchQueue.main.async {
                    self.victoryLine(xI: self.buttons[0].center.x-20, yI: self.buttons[0].center.y, xF: self.buttons[2].center.x+20, yF: self.buttons[2].center.y)
                }
            }
            if game.check2Win(){
                DispatchQueue.main.async {
                    self.victoryLine(xI: self.buttons[3].center.x-20, yI: self.buttons[3].center.y, xF: self.buttons[5].center.x+20, yF: self.buttons[5].center.y)
                }
            }
            if game.check3Win(){
                DispatchQueue.main.async {
                    self.victoryLine(xI: self.buttons[6].center.x-20, yI: self.buttons[6].center.y, xF: self.buttons[8].center.x+20, yF: self.buttons[8].center.y)
                }
            }
            if game.check4Win(){
                DispatchQueue.main.async {
                    self.victoryLine(xI: self.buttons[0].center.x, yI: self.buttons[0].center.y-20, xF: self.buttons[6].center.x, yF: self.buttons[6].center.y+20)
                }
            }
            if game.check5Win(){
                DispatchQueue.main.async {
                    self.victoryLine(xI: self.buttons[1].center.x, yI: self.buttons[1].center.y-20, xF: self.buttons[7].center.x, yF: self.buttons[7].center.y+20)
                }
            }
            if game.check6Win(){
                DispatchQueue.main.async {
                    self.victoryLine(xI: self.buttons[2].center.x, yI: self.buttons[2].center.y-20, xF: self.buttons[8].center.x, yF: self.buttons[8].center.y+20)
                }
            }
            if game.check7Win(){
                DispatchQueue.main.async {
                    self.victoryLine(xI: self.buttons[0].center.x-10, yI: self.buttons[0].center.y-10, xF: self.buttons[8].center.x+10, yF: self.buttons[8].center.y+10)
                }
            }
            if game.check8Win(){
                DispatchQueue.main.async {
                    self.victoryLine(xI: self.buttons[6].center.x-10, yI: self.buttons[6].center.y-10, xF: self.buttons[2].center.x+10, yF: self.buttons[2].center.y+10)
                }
            }
            showMessageEnd("Victory!")
        }
    }
    func onMove(x: Int, y: Int, piece: TrisPiece) {
        DispatchQueue.main.async {
            self.updateImage(x: x, y: y, piece: piece)
        }
        
    }
    func onMasterChoose(name: String) {
        addLog("onMasterChoose -> \(name)")
        if game.isMaster {
            game.sendChangePlayer()
        }
    }
    func manageGame() {
        let step = game.currentStep
        //updateInfo("Current Step \(step.rawValue) \(game.masterName)")

        if step == .none {
            addLog("invio starting")
            self.game.sendMessageStarting()
        } else if step == .starting {
            
        } else if step == .chooseMaster {
            //addLog("il master è \(game.masterName)")
        } else if step == .changePlayer {
        
        } else if step == .move {
            addLog("move")
            
        } else if step == .done {
            addLog("done")
        }
    }
    func addLog(_ s: String) {
        print(s)
        DispatchQueue.main.async {
            self.noteTextView.text += s + "\n"
        }
    }
    
    func connectClient(peerID: MCPeerID) {
        
    }
    
    func disconnectClient(peerID: MCPeerID) {
        stopTimer()
        game.clearState()
        showMessage("Connection Lost")
    }
    
    func receiveMessage(data: Data) {
        game.receiveMessage(data: data) { (success) in
            
        }
    }
    func showMessage(_ s: String) {
        
        DispatchQueue.main.async {
            let ac = UIAlertController(title: "Tris", message: s, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac,animated: true)
        }
        
    }
    
    func showMessageEnd(_ s: String) {
        
        DispatchQueue.main.async {
            let ac = UIAlertController(title: "Tris", message: s, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: {(action:UIAlertAction!) in
                self.navigationController?.popToRootViewController(animated: true)
            })
            ac.addAction(okAction)
            self.present(ac,animated: true)
        }
        
    }

    func updateInfo(_ message: String) {
        DispatchQueue.main.async {
            self.labelInfo.text = message
        }
    }
    
    func victoryLine(xI: CGFloat, yI: CGFloat, xF: CGFloat, yF: CGFloat){
        let path = UIBezierPath()
        path.move(to: CGPoint(x: xI, y: yI))
        path.addLine(to: CGPoint(x: xF, y: yF))

        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor
        shapeLayer.strokeColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1).cgColor
        shapeLayer.lineWidth = 10
        shapeLayer.path = path.cgPath

        self.view.layer.addSublayer(shapeLayer)
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.duration = 0.5
        shapeLayer.add(animation, forKey: "MyAnimation")

        self.shapeLayer = shapeLayer
    }
    
}
