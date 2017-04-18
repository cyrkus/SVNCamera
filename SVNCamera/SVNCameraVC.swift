//
//  SVNCamera.swift
//  Tester
//
//  Created by Aaron Dean Bikis on 4/5/17.
//  Copyright © 2017 7apps. All rights reserved.
//

import UIKit
import SVNShapesManager
import SVNTheme
import SVNModalViewController
import AVFoundation


public class SVNCameraViewController: SVNModalViewController, AVCapturePhotoCaptureDelegate {
    
    private lazy var actionbutton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(tapAction), for: .touchUpInside)
        self.view.addSubview(button)
        return button
    }()
    
    private lazy var acceptButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(accept), for: .touchUpInside)
        self.view.addSubview(button)
        return button
    }()
    
    private lazy var declineButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(decline), for: .touchUpInside)
        self.view.addSubview(button)
        return button
    }()
    
    private lazy var shapeManager: SVNShapesManager = {
        let manager = SVNShapesManager(container: self.view.bounds)
        return manager
    }()
    
    private lazy var leftCircle: SVNShapeMetaData = {
        let shape = SVNShapeMetaData(shapes: nil,
                                     location: .botMid,
                                     padding: CGPoint(x: 65.0, y: 25.0),
                                     size: CGSize(width: 65.0, height: 65.0),
                                     fill: UIColor.clear.cgColor,
                                     stroke: self.theme.stanardButtonTintColor.cgColor,
                                     strokeWidth: 2.5)
        return shape
    }()
    
    private lazy var rightCircle: SVNShapeMetaData = {
        let shape = SVNShapeMetaData(shapes: nil,
                                     location: .botMid,
                                     padding: CGPoint(x: 65.0, y: 25.0),
                                     size: CGSize(width: 65.0, height: 65.0),
                                     fill: UIColor.clear.cgColor,
                                     stroke: self.theme.stanardButtonTintColor.cgColor,
                                     strokeWidth: 2.5)
        return shape
    }()
    
    private var acceptShape: SVNShapeMetaData!
    
    private var declineShape: SVNShapeMetaData!
    
    //MARK: AV ivars
    private var captureSession: AVCaptureSession?
    
    private var stillImageOutput: AVCapturePhotoOutput?
    
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    private var stillImageView: UIImageView?
    
    private var awesomeImage: UIImage?
    
    //MARK: Coordinator Delegates
    public var shotAnAwesomeImage: ((UIImage) -> Void)!
    
    public var stop: (() -> Void)!
    
    public init(theme: SVNTheme?){
        super.init(nibName: nil, bundle: nil)
        self.theme = theme == nil ? SVNTheme_DefaultDark() : theme!
    }
    
    public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, theme: SVNTheme?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.theme = theme == nil ? SVNTheme_DefaultDark() : theme!
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init with coder not currently supported")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.setInitalLayout()
        //Set things that should only happen once
        self.view.backgroundColor = UIColor.black
        self.actionbutton.frame = self.shapeManager.fetchRect(with: leftCircle)
    }
    
    private func setInitalLayout(){
        self.leftCircle.shapes = [self.shapeManager.createCircleLayer(with: self.leftCircle)]
        self.rightCircle.shapes = [self.shapeManager.createCircleLayer(with: self.rightCircle)]
        self.view.layer.addSublayer(self.leftCircle.shapes!.first!)
        self.view.layer.addSublayer(self.rightCircle.shapes!.first!)
        DispatchQueue.main.async {
            self.initilizeCaptureSession()
        }
    }
    
    private func refreshView(){
        //Catch for nil
        guard var layers = self.acceptShape.shapes,
            let declineLayers = self.declineShape.shapes,
            let leftLayers = self.leftCircle.shapes,
            let rightLayers = self.rightCircle.shapes else { return }
        //Add to collection
        layers.append(contentsOf: declineLayers)
        layers.append(contentsOf: leftLayers)
        layers.append(contentsOf: rightLayers)
        //Animate Opacity
        self.shapeManager.animateOpacity(of: layers, to: 0.0, in: 0.2) {
            //Remove layers
            self.acceptShape.flushLayers()
            self.declineShape.flushLayers()
            self.leftCircle.flushLayers()
            self.rightCircle.flushLayers()
            //set to nil
            self.acceptShape = nil
            self.declineShape = nil
            //Disable Button
            self.acceptButton.isEnabled = false
            self.declineButton.isEnabled = false
            //Refresh layout
            self.setInitalLayout()
        }
    }
    
    //MARK: Actions
    public override func shouldDismiss() {
        self.stop()
    }
    
    internal func tapAction(){
        self.shootPhoto()
        self.animateShapesForPhoto()
    }
    
    private func animateShapesForPhoto(){
        self.shapeManager.animateToOval(with: leftCircle, in: 0.5, withNewLocation: .botLeft) {
            let rect = self.shapeManager.fetchRect(for: .botLeft, with: self.leftCircle.padding, and: self.leftCircle.size)
            self.declineShape = SVNShapeMetaData(shapes: nil,
                                                 location: .botLeft,
                                                 padding: self.leftCircle.padding,
                                                 size: self.leftCircle.size,
                                                 fill: UIColor.clear.cgColor,
                                                 stroke: self.theme.declineButtonTintColor.cgColor,
                                                 strokeWidth: 2.0)
            self.declineButton.frame = rect
            self.declineShape.shapes = self.shapeManager.createTwoLines(with: self.declineShape, shapeToCreate: .exit)
            self.declineShape.shapes?.forEach({ self.view.layer.addSublayer($0) })
            self.declineButton.isEnabled = true
        }
        
        self.shapeManager.animateToOval(with: self.rightCircle, in: 0.5, withNewLocation: .botRight) {
            let rect = self.shapeManager.fetchRect(for: .botRight, with: self.rightCircle.padding, and: self.rightCircle.size)
            self.acceptButton.frame = rect
            self.acceptShape = SVNShapeMetaData(shapes: nil,
                                                location: .botRight,
                                                padding: self.rightCircle.padding,
                                                size: self.rightCircle.size,
                                                fill: UIColor.clear.cgColor,
                                                stroke: self.theme.acceptButtonTintColor.cgColor,
                                                strokeWidth: 2.5)
            self.acceptShape?.shapes = [self.shapeManager.createCheckMark(with: self.acceptShape)]
            self.acceptShape.shapes?.forEach({ self.acceptButton.layer.addSublayer($0) })
            self.acceptButton.isEnabled = true
        }
    }
    
    private func shootPhoto(){
        if stillImageView != nil {
            stillImageView?.removeFromSuperview()
            stillImageView = nil
            if captureSession == nil {
                initilizeCaptureSession()
                return
            }
            captureSession?.startRunning()
            return
        }
        //Is in circle state and we should shoot an image
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [
            kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
            kCVPixelBufferWidthKey as String: 160,
            kCVPixelBufferHeightKey as String: 160
        ]
        settings.previewPhotoFormat = previewFormat
        stillImageOutput?.capturePhoto(with: settings, delegate: self)
    }
    
    
    internal func accept(){
        guard let image = awesomeImage else { return }
        self.shotAnAwesomeImage(image)
    }
    
    internal func decline(){
        self.refreshView()
    }
    
    //MARK: AV Methods
    private func initilizeCaptureSession(){
        self.captureSession = AVCaptureSession()
        self.captureSession!.sessionPreset = AVCaptureSessionPresetPhoto
        self.stillImageOutput = AVCapturePhotoOutput()
        
        guard let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) else {
            fatalError("Device doesn't have a camera")
        }
        //Flush the preview layer
        if self.previewLayer != nil {
            self.previewLayer?.removeFromSuperlayer()
            self.previewLayer = nil
        }
        
        let input = try? AVCaptureDeviceInput(device: device)
        if (self.captureSession!.canAddInput(input)) {
            self.captureSession!.addInput(input)
            if (self.captureSession!.canAddOutput(stillImageOutput)) {
                self.captureSession!.addOutput(stillImageOutput)
                self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                self.previewLayer!.frame = self.view.bounds
                self.previewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
                self.view.layer.insertSublayer(previewLayer!, at: 0)
                captureSession?.startRunning()
            }
        }
    }
    
    public func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        if let error = error {
            print("error capturing image : \(error.localizedDescription)")
        }
        
        guard let sampleBuffer = photoSampleBuffer,
            let previewBuffer = previewPhotoSampleBuffer,
            let dataImage =  AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer:  sampleBuffer, previewPhotoSampleBuffer: previewBuffer) else { return }
        
        let dataProvider = CGDataProvider(data: dataImage as CFData)
        let cgImageRef: CGImage! = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
        self.awesomeImage = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: UIImageOrientation.right)
        self.previewLayer?.contents = awesomeImage
        captureSession?.stopRunning()
    }
}
