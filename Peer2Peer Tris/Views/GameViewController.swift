//
//  GameViewController.swift
//  Peer2Peer Tris
//
//  Created by Fabio Palladino on 24/03/2020.
//  Copyright © 2020 Mario Armini. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {

    @IBOutlet weak var viewGrid: UIImageView!
    var buttons = [UIButton]()
    var coordButtons = [Int: CGPoint]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
    }
    override func viewDidAppear(_ animated: Bool) {
        
        let offset = viewGrid.layer.frame.origin
        let size = viewGrid.layer.frame
        let w: CGFloat = (size.width/3)
        let h: CGFloat = size.height/3
        let offsetY: CGFloat = -20.0
        
        print(offset)
        print(size)
        for x in 0...2 {
            for y in 0...2 {
                let x2 = CGFloat(offset.x) + (CGFloat(y) * w)
                let y2 = CGFloat(offset.y) + (CGFloat(x) * h) + offsetY
                
                let rc = CGRect(x: x2, y: y2, width: w, height: h).inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
                let bnt = UIButton(frame: rc)
                bnt.setTitle("", for: .normal)
                //bnt.backgroundColor = .red
                bnt.addTarget(self, action: #selector(onClickPiece), for: .touchUpInside)
                bnt.tag = buttons.count
                bnt.autoresizesSubviews = false
                buttons.append(bnt)
                coordButtons[bnt.tag] = CGPoint(x: x, y: y)
                self.view.addSubview(bnt)
            }
        }
    }
    @objc func onClickPiece(sender: UIButton!) {
        let bnt = buttons[sender.tag]
        let xy = coordButtons[sender.tag]!
        let imageName = "image" + ((xy.x > 0) ? "-x" : "-o")
        if bnt.currentImage == nil {
            bnt.setImage(UIImage(named: imageName), for: .normal)
        } else {
            print("gia pieno")
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
