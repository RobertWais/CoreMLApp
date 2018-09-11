//
//  ViewController.swift
//  CoreMLApp
//
//  Created by Robert Wais on 9/5/18.
//  Copyright © 2018 Robert Wais. All rights reserved.
//

import UIKit
import AVFoundation
import CoreML
import Vision

class CameraVC: UIViewController {
    
    var captureSession: AVCaptureSession!
    var captureOutput: AVCapturePhotoOutput!
    var preview: AVCaptureVideoPreviewLayer!
    var data: Data?

    @IBOutlet weak var roundedLblView: RoundedShadowView!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var conLbl: UILabel!
    @IBOutlet weak var imageView:RoundedShadowImageView!
    @IBOutlet weak var flashBtn: RoundedShadowBtn!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        preview.frame = cameraView.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let press = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSession.Preset.hd1920x1080
        
        let backCam = AVCaptureDevice.default(for: AVMediaType.video)
        
        
        do{
            let input = try AVCaptureDeviceInput(device: backCam!)
            if captureSession.canAddInput(input) == true {
                captureSession.addInput(input)
            }
            
            captureOutput = AVCapturePhotoOutput()
            
            if captureSession.canAddOutput(captureOutput) == true{
                captureSession.addOutput(captureOutput!)
                
                preview = AVCaptureVideoPreviewLayer(session: captureSession!)
                preview.videoGravity = AVLayerVideoGravity.resizeAspectFill
                preview.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                cameraView.layer.addSublayer(preview!)
                cameraView.addGestureRecognizer(press)
                captureSession.startRunning()
                
            }
            
        } catch let error {
            print("Error: \(error.localizedDescription)")
        }
    }

    @objc func didTapView(){
        let settings = AVCapturePhotoSettings()
        settings.previewPhotoFormat = settings.embeddedThumbnailPhotoFormat
        captureOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func resultsMethod(request: VNRequest, error: Error?){
        
        guard let results = request.results as? [VNClassificationObservation] else {return}
        
        for classification in results {
            //if its only fifty percent sure
            if classification.confidence < 0.5 {
                self.descLbl.text = "I am not sure what that is. Please try taking the picture again."
                self.conLbl.text = ""
                break
            } else {
                self.descLbl.text = classification.identifier
                self.conLbl.text = "CONFIDENCE: \(Int(classification.confidence * 100))%"
                break
            }
        }
    }
    
}



extension CameraVC: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error: \(error.localizedDescription)")
        } else {
            data = photo.fileDataRepresentation()
            
            do {
                let model = try VNCoreMLModel(for: SqueezeNet().model)
                let request = VNCoreMLRequest(model: model, completionHandler: resultsMethod)
                let handler = VNImageRequestHandler(data: data!)
                
                try handler.perform([request])
            } catch let error{
                
            }
            
            let image = UIImage(data: data!)
            self.imageView.image = image
        }
    }
}





