//
//  ViewController.swift
//  ARichMan
//
//  Created by 宋 奎熹 on 2017/9/10.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    var isAuto: Bool = false

    @IBOutlet var sceneView: ARSCNView!

    var boxNode: SCNNode?

    // 存放平面节点
    var planes: [UUID: Plane] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]

        // Tap gesture to put money
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
        sceneView.addGestureRecognizer(tap)

        // Back Button
        let button = UIButton(frame: CGRect(x: 30, y: 30, width: 60, height: 30))
        button.backgroundColor = .myYellowColor
        button.setTitle("返回", for: .normal)
        button.titleLabel?.font = UIFont(name: "PingFangSC-Regular", size: 15.0)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 4.0
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        self.view.addSubview(button)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Detect horizontal planes
        configuration.planeDetection = .horizontal

        // Set the session's delegate
        sceneView.session.delegate = self
        
        // Run the view's session
        sceneView.session.run(configuration)

        sceneView.automaticallyUpdatesLighting = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    @objc func backAction() {
        self.dismiss(animated: true, completion: nil)
    }

    @objc func didTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(location, types: .existingPlaneUsingExtent)
        if let hitResult = hitTestResults.first {
            let position = SCNVector3(
                hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y + Float.random(2), hitResult.worldTransform.columns.3.z
            )
            insertMoney(at: position)
        }
    }

    private func insertMoney(at position: SCNVector3) {
        let node = (SCNScene(named: "art.scnassets/money.scn")?.rootNode.childNode(withName: "rmb", recursively: true))!

        node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        node.physicsBody?.mass = 1
        node.physicsBody?.categoryBitMask = 2

        node.position = position

        sceneView.scene.rootNode.addChildNode(node)
    }

    // MARK: - ARSCNViewDelegate

    /// 找到一个 Anchor 时自动添加节点
    ///
    /// - Parameters:
    ///   - renderer: 渲染 scene 用的 renderer
    ///   - anchor: 锚点
    /// - Returns: 新增锚点上的节点
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()

        return node
    }

    /// 已经为 Anchor 加上节点之后调用
    ///
    /// - Parameters:
    ///   - renderer: 渲染 scene 用的 renderer
    ///   - node: 新增的节点
    ///   - anchor: 新增的节点所对应的锚点
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        print("Add a node")
        guard let anchor = anchor as? ARPlaneAnchor else {
            return
        }

        // 检测到新平面时创建 SceneKit 平面以实现 3D 视觉化
        let plane = Plane(withAnchor: anchor)
        planes[anchor.identifier] = plane
        node.addChildNode(plane)
    }

    /// 更新对应 Anchor 上的节点
    ///
    /// - Parameters:
    ///   - renderer: 渲染 scene 用的 renderer
    ///   - node: 要更新的节点
    ///   - anchor: 要更新的节点对应的锚点
    func renderer(_ renderer: SCNSceneRenderer, willUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let plane = planes[anchor.identifier] else {
            return
        }

        // After updating anchors, we need to update the nodes.
        plane.update(anchor: anchor as! ARPlaneAnchor)
    }

    /// 已经移除节点
    ///
    /// - Parameters:
    ///   - renderer: 渲染 scene 用的 renderer
    ///   - node: 已经移除的节点
    ///   - anchor: 已经移除的节点对应的锚点
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        // remove the useless (combined) planes
         planes.removeValue(forKey: anchor.identifier)
    }

    /// 实时更新场景的渲染效果
    ///
    /// - Parameters:
    ///   - renderer: 渲染 scene 用的 renderer
    ///   - time: 时间间隔
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        for node in sceneView.scene.rootNode.childNodes {
            // Some nodes didn't fall on the plane, we need to remove them.
            if node.presentation.position.y < -10 {
                node.removeFromParentNode()
            }
        }
    }

    // MARK: - ARSessionDelegate

    /// 更新当前会话的 Frame 时调用（比如移动相机）
    ///
    /// - Parameters:
    ///   - session: 当前会话
    ///   - frame: 当前 Frame
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        if isAuto {
            let position = SCNVector3(
                frame.camera.transform.columns.3.x, frame.camera.transform.columns.3.y + Float.random(2), frame.camera.transform.columns.3.z - 0.5
            )
            insertMoney(at: position)
        }
    }

    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }

}
