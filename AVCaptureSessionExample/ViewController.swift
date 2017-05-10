//
//  ViewController.swift
//  AVCaptureSessionExample
//
//  Created by Nick Wilkerson on 5/9/17.
//  Copyright © 2017 Nick Wilkerson. All rights reserved.
//

import UIKit
import AVFoundation



class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, AVCapturePhotoCaptureDelegate {
    var captureSession = AVCaptureSession();
    var sessionOutput = AVCapturePhotoOutput();
    var sessionOutputSetting = AVCapturePhotoSettings(format: [AVVideoCodecKey:AVVideoCodecJPEG]);
    var previewLayer = AVCaptureVideoPreviewLayer();
    var cameraView: UIView?
    
    
    var label: UILabel = UILabel()
    var detectLabel: UILabel = UILabel()
    var button: UIButton = UIButton()
    
    override func viewDidLoad() {
        
        cameraView = UIView(frame: view.frame)
        view.addSubview(cameraView!)
        

        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        label.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant:-view.frame.height*0.08).isActive = true
        label.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.05).isActive = true
        
        view.addSubview(detectLabel)
        detectLabel.translatesAutoresizingMaskIntoConstraints = false
        detectLabel.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        detectLabel.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        detectLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant:-view.frame.height*0.08).isActive = true
        detectLabel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.05).isActive = true
        detectLabel.textAlignment = .right
        detectLabel.textColor = UIColor.red
        
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        button.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        button.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        button.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.08).isActive = true
        button.setTitle("Capture", for: .normal)
        button.addTarget(self, action: #selector(takePhoto(_:)), for: .touchUpInside)
        button.backgroundColor = UIColor.blue
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let deviceDiscoverySession = AVCaptureDeviceDiscoverySession(deviceTypes: [AVCaptureDeviceType.builtInDualCamera, AVCaptureDeviceType.builtInTelephotoCamera,AVCaptureDeviceType.builtInWideAngleCamera], mediaType:AVMediaTypeVideo, position: AVCaptureDevicePosition.unspecified)
        for device in (deviceDiscoverySession?.devices)! {
            if(device.position == AVCaptureDevicePosition.back){
                captureSession.sessionPreset = AVCaptureSessionPresetPhoto;//this
                do{
                    let input = try AVCaptureDeviceInput(device: device)
                    if(captureSession.canAddInput(input)){
                        captureSession.addInput(input);
                        
                        if(captureSession.canAddOutput(sessionOutput)){
                    
                            captureSession.addOutput(sessionOutput);
                            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession);
                            previewLayer.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)//(cameraView?.bounds)!
                            previewLayer.videoGravity = AVLayerVideoGravityResizeAspect/*AVLayerVideoGravityResizeAspectFill*/;
                            previewLayer.connection.videoOrientation = AVCaptureVideoOrientation.portrait;
                            cameraView?.layer.addSublayer(previewLayer);
                        }
                        
                        let captureMetadataOutput:AVCaptureMetadataOutput  = AVCaptureMetadataOutput()
                        captureSession.addOutput(captureMetadataOutput)
                        let dispatchQueue = DispatchQueue(label: "queue")
                        captureMetadataOutput.setMetadataObjectsDelegate(self , queue: dispatchQueue)
                        captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
  
                    }
                }
                catch{
                    print("exception!");
                }
            }
        }

    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        captureSession.startRunning()
    }

    /* AVCaptureMetadataOutputObjectsDelegate */
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        if metadataObjects != nil && metadataObjects.count > 0 {
            let metadatas = metadataObjects as Array
            let metadataObject: AVMetadataMachineReadableCodeObject = metadatas[0] as! AVMetadataMachineReadableCodeObject
            if metadataObject.type == AVMetadataObjectTypeQRCode {
                print("\(metadataObject.stringValue)")
                DispatchQueue.main.async {
                    
                    self.label.text = metadataObject.stringValue
                    self.detectLabel.text = "+"
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                        self.detectLabel.text = ""
                    })
                }
            }
        }
    }
    
    func takePhoto(_ sender:UIButton) {
        let settings = AVCapturePhotoSettings()
        sessionOutput.capturePhoto(with: settings, delegate: self)
    }
    
    /* AVCapturePhotoCaptureDelegate */
    func capture(_ captureOutput: AVCapturePhotoOutput, willBeginCaptureForResolvedSettings resolvedSettings: AVCaptureResolvedPhotoSettings) {
        print("willBeginCapture")
    }
    
    func capture(_ captureOutput: AVCapturePhotoOutput, willCapturePhotoForResolvedSettings resolvedSettings: AVCaptureResolvedPhotoSettings) {
        print("willCapturePhoto")
    }
    
    func capture(_ captureOutput: AVCapturePhotoOutput, didCapturePhotoForResolvedSettings resolvedSettings: AVCaptureResolvedPhotoSettings) {
        print("didCapturePhoto")
    }
    
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishCaptureForResolvedSettings resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        print("didFinishCapture")
    }
    
    /* jpeg */
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        print("jpg")
        if let error = error {
            print(error.localizedDescription)
        }
    
        if let sampleBuffer = photoSampleBuffer {
            print("sampleBuffer: \(sampleBuffer)")

            if let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: nil) {
                print("dataImage: \(dataImage)")
                print("inside if let")
                
                let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                
                let folderPath = paths[0]
                let filePath = folderPath.appendingPathComponent("image.jpg")
                print("filePath: \(filePath)")
                do {
                    try dataImage.write(to: filePath, options:.atomic)
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
                
                let image = UIImage(data: dataImage)
                if let im = image {
                    UIImageWriteToSavedPhotosAlbum(im, nil, nil, nil)
                }
                print("\(String(describing: image))")
            } else {
                print("outside if let")
            }
        }
    }
    
    /* raw */
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingRawPhotoSampleBuffer rawSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        print("raw")
        
    }
    

    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
}
