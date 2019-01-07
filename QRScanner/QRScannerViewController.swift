//
//  QRScannerViewController.swift
//  QRScannerWithScanningLaser
//
//  Created by Pankaj Kumhar on 1/7/19.
//  Copyright © 2019 Pankaj Kumhar. All rights reserved.
////

import UIKit
import AVFoundation
class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var videoPreviewLayer = AVCaptureVideoPreviewLayer()
    @IBOutlet weak var viewCapture: UIView!
    @IBOutlet weak var lblHold: UILabel!
    @IBOutlet weak var lblScanning: UILabel!
    @IBOutlet weak var lblLaser: UILabel!
    let output = AVCaptureMetadataOutput()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.animateScanningLaser()
        self.scanQR()
    }
    
    override func viewDidLayoutSubviews() {
        viewCapture.layer.cornerRadius = 10.0
        viewCapture.layer.addSublayer(createFrame())
        videoPreviewLayer.frame = view.frame
        output.rectOfInterest = videoPreviewLayer.metadataOutputRectConverted(fromLayerRect: CGRect(x: viewCapture.frame.minX, y: viewCapture.frame.minY, width: viewCapture.bounds.width, height: viewCapture.bounds.height))
    }
    
    //MARK: - AVCaptureMetadataOutputObjects Delegate
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count != 0 {
            
            if let object = metadataObjects[0] as? AVMetadataMachineReadableCodeObject {
                self.alert(message: object.stringValue ?? "", title: "Scanned Data.")
            }
        }
    }
    
    fileprivate func scanQR() {
        let captureSession = AVCaptureSession()
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        do{
            let input = try AVCaptureDeviceInput(device: captureDevice!) as AVCaptureDeviceInput
            captureSession.addInput(input)
        }
        catch {
            print("error")
        }
        
        captureSession.addOutput(output)
        
        output.setMetadataObjectsDelegate(self , queue: DispatchQueue.main)
        output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer.frame = view.frame
        view.layer.addSublayer(videoPreviewLayer)
        
        view.bringSubviewToFront(viewCapture)
        self.view.bringSubviewToFront(lblHold)
        self.view.bringSubviewToFront(lblScanning)
        captureSession.startRunning()
        
    }
    
    func createFrame() -> CAShapeLayer {
        let height: CGFloat = self.viewCapture.frame.size.height
        let width: CGFloat = self.viewCapture.frame.size.width
        let path = UIBezierPath()
        //Top Left Curve
        path.move(to: CGPoint(x: 5, y: self.viewCapture.frame.size.width/3))
        path.addLine(to: CGPoint(x: 5, y: 5)) //Horizontal line
        path.addLine(to: CGPoint(x: self.viewCapture.frame.size.width/3, y: 5)) // Vertical line
        
        //Top Right Curve
        path.move(to: CGPoint(x: height - self.viewCapture.frame.size.width/3, y: 5))
        path.addLine(to: CGPoint(x: height - 5, y: 5))
        path.addLine(to: CGPoint(x: height - 5, y: self.viewCapture.frame.size.width/3))
        
        //Bottom Left Curve
        path.move(to: CGPoint(x: 5, y: width - self.viewCapture.frame.size.width/3))
        path.addLine(to: CGPoint(x: 5, y: width - 5))
        path.addLine(to: CGPoint(x: self.viewCapture.frame.size.width/3, y: width - 5))
        
        //Bottom Right Curve
        path.move(to: CGPoint(x: width - self.viewCapture.frame.size.width/3, y: height - 5))
        path.addLine(to: CGPoint(x: width - 5, y: height - 5))
        path.addLine(to: CGPoint(x: width - 5, y: height - self.viewCapture.frame.size.width/3))
        
        let shape = CAShapeLayer()
        shape.path = path.cgPath
        shape.strokeColor = UIColor.white.cgColor
        shape.lineWidth = 25
        shape.fillColor = UIColor.clear.cgColor
        return shape
    }
    
    fileprivate func animateScanningLaser(){
        DispatchQueue.main.async {
            UIView.animate(withDuration: 1.3, delay: 0.0, options: .curveLinear, animations: {
                self.lblLaser.transform = CGAffineTransform(translationX: self.viewCapture.bounds.maxX -  50, y: self.lblLaser.bounds.minY)
            }, completion: { (b) in
                UIView.animate(withDuration: 1.3, delay: 0.0, options: .curveLinear, animations: {
                    self.lblLaser.transform = CGAffineTransform(translationX: self.viewCapture.bounds.minX , y: self.lblLaser.bounds.minY)
                }, completion: { (b) in
                    self.animateScanningLaser()
                })
            })
        }
    }
}
extension UIViewController
{
    
    func alert(message: String, title: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}
