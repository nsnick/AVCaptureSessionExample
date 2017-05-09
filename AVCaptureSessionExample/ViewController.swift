//
//  ViewController.swift
//  AVCaptureSessionExample
//
//  Created by Nick Wilkerson on 5/9/17.
//  Copyright © 2017 Nick Wilkerson. All rights reserved.
//

import UIKit
import AVFoundation



class ViewController: UIViewController {
    var captureSession = AVCaptureSession();
    var sessionOutput = AVCapturePhotoOutput();
    var sessionOutputSetting = AVCapturePhotoSettings(format: [AVVideoCodecKey:AVVideoCodecJPEG]);
    var previewLayer = AVCaptureVideoPreviewLayer();
    var cameraView: UIView?
    
    override func viewDidLoad() {
        
        cameraView = UIView(frame: view.frame)
        view.addSubview(cameraView!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let deviceDiscoverySession = AVCaptureDeviceDiscoverySession(deviceTypes: [AVCaptureDeviceType.builtInDualCamera, AVCaptureDeviceType.builtInTelephotoCamera,AVCaptureDeviceType.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: AVCaptureDevicePosition.unspecified)
        for device in (deviceDiscoverySession?.devices)! {
            if(device.position == AVCaptureDevicePosition.back){
                do{
                    let input = try AVCaptureDeviceInput(device: device)
                    if(captureSession.canAddInput(input)){
                        captureSession.addInput(input);
                        
                        if(captureSession.canAddOutput(sessionOutput)){
                            captureSession.addOutput(sessionOutput);
                            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession);
                            previewLayer.frame = (cameraView?.bounds)!
                            previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
                            previewLayer.connection.videoOrientation = AVCaptureVideoOrientation.portrait;
                            cameraView?.layer.addSublayer(previewLayer);
                        }
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

    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
}
