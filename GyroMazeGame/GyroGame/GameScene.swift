import SpriteKit
import CoreMotion
import Foundation

class GameScene: SKScene {
    
    private var motionManager: CMMotionManager!
    var playerNode: SKShapeNode!
    private var isGameOver = false
    
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .light)
    private let hapticNotification = UINotificationFeedbackGenerator()
    
    let timerNode: SKLabelNode = SKLabelNode(fontNamed: "Arial")
    let rankingNode: SKLabelNode = SKLabelNode(fontNamed: "Arial")
    
    let defaults = UserDefaults.standard
    
    var time: Float = 30.00{
        didSet{
            if (time >= 10.00){
                timerNode.text = String(format: "tempo: %.2f", time)
            } else {
                timerNode.text = String(format: "tempo: 0%.2f", time)
            }
        }
        
    }
    
    var topTimes: [Float] = []
    
    
    fileprivate func topResultsSetup() {
        if topTimes.isEmpty{
            var rankingNumbers = defaults.object(forKey: "topTimes") as? [Float] ?? []
            var ranking = ""
            for index in 0..<rankingNumbers.count {
                let formatted = String(format: "%.2f", rankingNumbers[index])
                ranking += " \(index + 1)- " + formatted + "|| "
            }
            topTimes = rankingNumbers
            rankingNode.text = ranking
        } else {
            var ranking: String = ""
            for index in 0..<topTimes.count {
                let formatted = String(format: "%.2f", topTimes[index])
                ranking += " \(index + 1)- " + formatted + "|| "
            }
            rankingNode.text = ranking
            
        }
    }
    
    

    override func didMove(to view: SKView) {
        physicsWorld.gravity = .zero //physics world vem pronto de uma cena -> faz parte da física que ta automatizada
        physicsWorld.contactDelegate = self
        createPlayer()
        startMotionManager()
        timer()
        ranking()
        topResultsSetup()
        
    }
    
    
    private func startMotionManager() {
        motionManager = CMMotionManager()
        guard motionManager.isAccelerometerAvailable else {
            return
        }
        motionManager.startAccelerometerUpdates()
    }
    
    private func createPlayer() {
        playerNode = SKShapeNode(circleOfRadius: 40)
        playerNode.position = CGPoint(x: frame.minX + 50, y: frame.minY + 280)
        playerNode.strokeColor = UIColor.green
        playerNode.lineWidth = 6
        playerNode.fillColor = UIColor.black
        playerNode.physicsBody = SKPhysicsBody(circleOfRadius: 40)
        playerNode.physicsBody?.categoryBitMask = 1
        playerNode.physicsBody?.contactTestBitMask = 3
        playerNode.physicsBody?.collisionBitMask = 2        
        playerNode.zPosition = 1// in front of all nodes
        addChild(playerNode) //aqui é o ponto que tu coloca o treco na tela
    }
    
    private func countdown(){
        time -= 0.1
        if time <= 0 {
            playerDone()
        }
    }
    
    private func timer(){
        timerNode.fontSize = 65
        timerNode.fontColor = SKColor.green
        timerNode.position = CGPoint(x: frame.midX, y: frame.minY + 120)
        timerNode.zPosition = 2
        addChild(timerNode)

        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(countdown),
                SKAction.wait(forDuration: 0.1)])))
    }
    
    
    private func ranking(){
        
        rankingNode.fontSize = 65
        rankingNode.fontColor = SKColor.green
        rankingNode.position = CGPoint(x: frame.midX , y: frame.minY)
        rankingNode.zPosition = 2
        addChild(rankingNode)
    }
    
    private func endingGame() {
        self.playerNode.physicsBody?.isDynamic = true
        topResultsSetup()
        isGameOver = true
    }
    
    private func restartGame() {
        let playerTime = 30.00 - time
        createPlayer()
        topTimes.append(playerTime)
        topTimes.sort()
        //colocar um treco para apenas ser o top 3
        if topTimes.count > 3 {
            topTimes.remove(at: 3)
        }
        defaults.set(topTimes, forKey: "topTimes")
        topResultsSetup()
        time = 30.00
        isGameOver = false
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard isGameOver == false else { return }
        // the speed is proportional to the degree the device is turned
        if let accelerometerData = motionManager.accelerometerData {
            physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * -40, dy: accelerometerData.acceleration.x * 40)
        }
    }
}

extension GameScene: SKPhysicsContactDelegate {

    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node == playerNode {
            if let nodeB = contact.bodyB.node {
                playerContacted(with: nodeB)
            }
        } else if contact.bodyB.node == playerNode {
            if let nodeA = contact.bodyA.node {
                playerContacted(with: nodeA)
            }
        }
    }
    
    private func playerContacted(with node: SKNode) {
        if node.name == "finishNode" {
            playerDone()
        } else { // wall contacted
            hapticFeedback.impactOccurred()
        }
    }
    
    private func playerDone() {
        hapticNotification.notificationOccurred(.error)
        endingGame()
        playerNode.removeFromParent()
        restartGame()
    }
}
