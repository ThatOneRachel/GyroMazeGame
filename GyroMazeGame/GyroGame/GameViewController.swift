import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    // prevent screen rotation
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeRight
    }
    
    // hide home indicator
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    // hide status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            if let scene = SKScene(fileNamed: "GameScene") {
                scene.scaleMode = .aspectFit
                scene.backgroundColor = .black
                view.presentScene(scene)
            }
            view.ignoresSiblingOrder = true
            view.showsFPS = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setNeedsUpdateOfHomeIndicatorAutoHidden()
    }
    
}
