//
//  ViewController.swift
//  ArKitDEMO
//
//  Created by Jay Buddhdev on 09/08/22.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var planes = [OverlayPlane]()
    var boxes = [SCNNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        let missleScene = SCNScene(named: "missile-1.scn")
        let missle = Missle(scene: missleScene!)
        missle.name = "Missile"
        missle.position = SCNVector3(0,0,-4)
//        let missleNode = missleScene?.rootNode.childNode(withName: "missileNode", recursively: true)
//        missleNode?.position = SCNVector3(0,0,-0.5)
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        scene.rootNode.addChildNode(missle)
        sceneView.scene = scene
        registerGestureRecognizers()
    }
    
    private func registerGestureRecognizers() {
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        
        let doubleTappedGestureReconizer = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        doubleTappedGestureReconizer.numberOfTapsRequired = 2
        
        tapGestureRecognizer.require(toFail: doubleTappedGestureReconizer)
        
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        self.sceneView.addGestureRecognizer(doubleTappedGestureReconizer)
    }
    
    @objc func doubleTapped(recognizer : UIGestureRecognizer) {
        let sceneView = recognizer.view as! ARSCNView
        let touch  = recognizer.location(in: sceneView)
        
        let hitResults = sceneView.hitTest(touch,options: [:])
        if !hitResults.isEmpty {
            guard let hitResults = hitResults.first else {
                return
            }
            
            let node = hitResults.node
            node.physicsBody?.applyForce(SCNVector3(hitResults.worldCoordinates.x * (2.0),2.0,hitResults.worldCoordinates.z * (2.0)), asImpulse: true)
        }
    }
    @objc func tapped(recognizer :UIGestureRecognizer) {
        
//        let sceneView = recognizer.view as! ARSCNView
//        let touchLocation = recognizer.location(in: sceneView)
//
//        let hitTestResult = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
//
//        if !hitTestResult.isEmpty {
//
//            guard let hitResult = hitTestResult.first else {
//                return
//            }
//            addBox(hitResult :hitResult)
//        }
        
        guard let missileNode = self.sceneView.scene.rootNode.childNode(withName: "Missile", recursively: true) else {
            fatalError("Missile not found")
        }
        guard let smokeNode = self.sceneView.scene.rootNode.childNode(withName: "smokeNode", recursively: true) else {
            fatalError("No Smoke found")
        }
        smokeNode.removeAllParticleSystems()
        let fire = SCNParticleSystem(named: "fire.scnp", inDirectory: nil)
        smokeNode.addParticleSystem(fire!)
        missileNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        missileNode.physicsBody?.isAffectedByGravity = false
        missileNode.physicsBody?.damping = 0.0
        missileNode.physicsBody?.applyForce(SCNVector3(0,50,0), asImpulse: false)
    }
    
    private func addBox(hitResult :ARHitTestResult) {
        
        let boxGeometry = SCNBox(width: 0.2, height: 0.2, length: 0.1, chamferRadius: 0)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        
        boxGeometry.materials = [material]
        
        let boxNode = SCNNode(geometry: boxGeometry)
        boxNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape:nil)
        boxNode.physicsBody?.categoryBitMask = BodyType.box.rawValue
        self.boxes.append(boxNode)
        
        boxNode.position = SCNVector3(hitResult.worldTransform.columns.3.x,hitResult.worldTransform.columns.3.y + Float(boxGeometry.height/2), hitResult.worldTransform.columns.3.z)
        
        self.sceneView.scene.rootNode.addChildNode(boxNode)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        if !(anchor is ARPlaneAnchor) {
            return
        }
        
        let plane = OverlayPlane(anchor: anchor as! ARPlaneAnchor)
        self.planes.append(plane)
        node.addChildNode(plane)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        let plane = self.planes.filter { plane in
            return plane.anchor.identifier == anchor.identifier
            }.first
        
        if plane == nil {
            return
        }
        
        plane?.update(anchor: anchor as! ARPlaneAnchor)
    }
}
