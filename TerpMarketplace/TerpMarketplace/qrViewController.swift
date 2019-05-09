//
//  qrViewController.swift
//  TerpMarketplace
//
//  Created by fitsumend on 5/9/19.
//  Copyright © 2019 CMSC436. All rights reserved.
//

import UIKit
import AVFoundation
class qrViewController: UIViewController,AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet var videoPreview: UIView!
    
    
    var stringURL = String()
    
    enum error: Error {
        
        case noCameraAvailable
        case videoInputInitFail
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        do {
            try scanQrCode()
            
        }catch{
            
            print("failed to scan")
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func captureOutput(_ captureOutput: AVCaptureOutput!,
                       didOutputMetadataObjects metadataObjects:[Any]!, from connection:AVCaptureConnection){
        
        if metadataObjects.count > 0{
            
            let machineReadableCode = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
            if machineReadableCode.type == AVMetadataObject.ObjectType.qr {
                stringURL = machineReadableCode.stringValue!
                
                performSegue(withIdentifier: "link", sender: self)
                
            }
        }
        
        
    }
    func scanQrCode() throws {
        
       let avCaptureSession = AVCaptureSession()
        
        guard let avCaptureDevice = AVCaptureDevice.default(for:AVMediaType.video)else{
            
            print("No camera")
            throw error.noCameraAvailable
        }
        
        guard let avCaptureInput = try? AVCaptureDeviceInput(device: avCaptureDevice)else{
            
            print("failed")
            
            throw error.videoInputInitFail
        }
        
        let avCaptureMetadataOutput = AVCaptureMetadataOutput()
        avCaptureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        
        avCaptureSession.addInput(avCaptureInput)
        avCaptureSession.addOutput(avCaptureMetadataOutput)
        
        avCaptureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        
        let avCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: avCaptureSession)
        avCaptureVideoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        
        avCaptureVideoPreviewLayer.frame = videoPreview.bounds
        
        self.videoPreview.layer.addSublayer(avCaptureVideoPreviewLayer)
        
        
        avCaptureSession.startRunning()
        
        
        
    }
    
    override func prepare (for segue: UIStoryboardSegue, sender: (Any)?){
        
        if segue.identifier == "link"{
            
            let destination = segue.destination as! webViewController   
            
            destination.url = URL(string: stringURL)
        }
    }

}
