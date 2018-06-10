//
//  ViewController.swift
//  ARImageDetectionDemo
//
//  Created by Shawn Roller on 6/9/18.
//  Copyright © 2018 Shawn Roller. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

class ViewController: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!
    var matchPicker: UIImagePickerController?
    var replacePicker: UIImagePickerController?
    var matchImage = UIImage(named: "AnniversaryPhoto")
    var replaceImage = UIImage(named: "Demon")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARImageTrackingConfiguration()
        guard let images = ARReferenceImage.referenceImages(inGroupNamed: "Photos", bundle: .main) else {
            // TODO: handle error
            return
        }

        configuration.trackingImages = images
        configuration.maximumNumberOfTrackedImages = 1
        sceneView.session.run(configuration)
    }
    
    private func setupImages() {
        let configuration = ARImageTrackingConfiguration()
        var images = Set<ARReferenceImage>()
        let image = ARReferenceImage(self.matchImage!.cgImage!, orientation: .up, physicalWidth: 0.7)
        images.insert(image)
        
        configuration.trackingImages = images
        configuration.maximumNumberOfTrackedImages = 1
        sceneView.session.run(configuration)
    }
}

// MARK: - button actions
extension ViewController {
    
    @IBAction private func changeMatchPhoto(sender: Any) {
        matchPicker = UIImagePickerController()
        matchPicker?.allowsEditing = true
        matchPicker?.delegate = self
        guard matchPicker != nil else { return }
        present(matchPicker!, animated: true) {
            
        }
    }
    
    @IBAction private func changeReplacePhoto(sender: Any) {
        replacePicker = UIImagePickerController()
        replacePicker?.allowsEditing = true
        replacePicker?.delegate = self
        guard replacePicker != nil else { return }
        present(replacePicker!, animated: true) {
            
        }
    }
    
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if picker == matchPicker {
            guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
            matchImage = image
            setupImages()
            dismiss(animated: true)
            matchPicker = nil
        }
        else if picker == replacePicker {
            guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
            replaceImage = image
            setupImages()
            dismiss(animated: true)
            replacePicker = nil
        }
    }
    
}

extension ViewController: ARSCNViewDelegate {
    
    public func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        if let imageAnchor = anchor as? ARImageAnchor {
            let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
            let replacementImage = replaceImage!
            plane.firstMaterial?.diffuse.contents = replacementImage
            let planeNode = SCNNode(geometry: plane)
            planeNode.eulerAngles.x = -.pi / 2
            node.addChildNode(planeNode)
        }
        return node
    }
    
}
