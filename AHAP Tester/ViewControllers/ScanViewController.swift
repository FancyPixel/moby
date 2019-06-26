//
//  ScanViewController.swift
//  AHAP Tester
//
//  Created by Andrea Mazzini on 26/06/2019.
//  Copyright © 2019 Fancy Pixel. All rights reserved.
//

import UIKit
import AVFoundation

protocol ScanViewControllerDelegate: class {
  func scanViewController(_ controller: ScanViewController, didScan code: String)
}

class ScanViewController: UIViewController {
  private var captureSession = AVCaptureSession()
  private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
  var delegate: ScanViewControllerDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera], mediaType: AVMediaType.video, position: .back)
    
    guard let captureDevice = deviceDiscoverySession.devices.first else {
      print("Failed to get the camera device")
      dismiss(animated: true, completion: nil)
      return
    }
    
    do {
      let input = try AVCaptureDeviceInput(device: captureDevice)
      captureSession.addInput(input)
      let captureMetadataOutput = AVCaptureMetadataOutput()
      captureSession.addOutput(captureMetadataOutput)
      captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
      captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
    } catch {
      print(error)
      dismiss(animated: true, completion: nil)
      return
    }
    
    videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
    videoPreviewLayer?.frame = view.layer.bounds
    view.layer.addSublayer(videoPreviewLayer!)
    
    captureSession.startRunning()
  }
}

extension ScanViewController: AVCaptureMetadataOutputObjectsDelegate {
  func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
    if metadataObjects.count == 0 {
      return
    }
    
    let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
    
    if metadataObj.type == AVMetadataObject.ObjectType.qr {
      if let code = metadataObj.stringValue  {
        delegate?.scanViewController(self, didScan: code)
        captureSession.stopRunning()
        dismiss(animated: true, completion: nil)
      }
    }
  }
}
