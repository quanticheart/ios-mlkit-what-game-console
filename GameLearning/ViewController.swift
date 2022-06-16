//
//  ViewController.swift
//  GameLearning
//
//  Created by Jonatas Alves santos on 14/05/22.
//

import UIKit
import Vision

class ViewController: UIViewController {
    
    lazy var consoleClassificationRequest: VNCoreMLRequest? = {
        let config = MLModelConfiguration()
        do {
            let consoleIdentifier = try game(configuration: config)
            let visionModel = try VNCoreMLModel(for: consoleIdentifier.model)
            
            let request = VNCoreMLRequest.init(model: visionModel) { request, error in
                self.processObservation(for: request)
            }
            request.imageCropAndScaleOption = .scaleFill
            return request
        } catch {
            return nil
        }
        
        
    }()
    
    @IBOutlet weak var result: UILabel!
    
    @IBOutlet weak var background: UIImageView!
    
    @IBOutlet weak var btnLib: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    private func openPicker(type: UIImagePickerController.SourceType){
        let picker = UIImagePickerController()
        picker.sourceType = type
        picker.delegate = self
        present(picker, animated: false, completion: nil)
    }
    
    @IBAction func openLib(_ sender: Any) {
        openPicker(type: .photoLibrary)
    }
    
    @IBAction func openCamera(_ sender: Any) {
        openPicker(type: .camera)
    }
    
    private func classify(_ image:UIImage){
        DispatchQueue.global().async {
            guard let ciimage = CIImage(image: image),
            let consoleClassificationHandler = self.consoleClassificationRequest else {return}
            
            let orientation = image.imageOrientation
            let handler = VNImageRequestHandler(ciImage: ciimage, orientation: CGImagePropertyOrientation(orientation))
            do{
                try  handler.perform([consoleClassificationHandler])
            } catch{
                
            }
        }
    }
    
    private func processObservation(for request:VNRequest){
        guard   let observation = request.results?.first as? VNClassificationObservation else {return}
        let confidence =  "\(observation.confidence * 100)%"
        let indenifier = observation.identifier
       
        DispatchQueue.main.async {
            self.result.text = "Resultado: \(confidence) - \(indenifier)"
        }
    }
}

extension ViewController: (UIImagePickerControllerDelegate & UINavigationControllerDelegate) {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            background.image = image
            classify(image)
        }
        dismiss(animated: true, completion: nil)
    }
}

extension CGImagePropertyOrientation {
    init(_ uiOrientation: UIImage.Orientation) {
        switch uiOrientation {
            case .up: self = .up
            case .upMirrored: self = .upMirrored
            case .down: self = .down
            case .downMirrored: self = .downMirrored
            case .left: self = .left
            case .leftMirrored: self = .leftMirrored
            case .right: self = .right
            case .rightMirrored: self = .rightMirrored
        default: self = .up
        }
    }
}

