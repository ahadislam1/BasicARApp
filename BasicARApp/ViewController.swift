//
//  ViewController.swift
//  BasicARApp
//
//  Created by Ahad Islam on 6/8/20.
//  Copyright © 2020 Ahad Islam. All rights reserved.
//

import UIKit
import RealityKit
import ARKit

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        arView.session.delegate = self
        setupARView()
        
        arView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:))))
    }
    
    func setupARView() {
        arView.automaticallyConfigureSession = false
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.environmentTexturing = .automatic
        arView.session.run(configuration)
    }
    
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: arView)
        
        let results = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal)
        
        //read up on estimated plane, geometry/infinite
        
        if let firstResult = results.first {
            let anchor = ARAnchor(name: "placeHolder", transform: firstResult.worldTransform)
            arView.session.add(anchor: anchor)
        } else {
            print("Object placement failed - couldn't find surface")
        }
    }
    
}

extension ViewController: ARSessionDelegate {
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let anchorName = anchor.name, anchorName == "placeHolder" {
                placeObject(named: anchorName, for: anchor)
            }
        }
    }
    
    func placeObject(named entityName: String, for anchor: ARAnchor) {
        let entity = try? ModelEntity.loadModel(named: entityName)
        
        entity?.generateCollisionShapes(recursive: true)
        arView.installGestures([.rotation, .translation], for: entity!)
        
        let anchorEntity = AnchorEntity(anchor: anchor)
        anchorEntity.addChild(entity!)
        
        arView.scene.addAnchor(anchorEntity)
        
    }
}
