////
////  foo.swift
////  SVNCamera
////
////  Created by Aaron Dean Bikis on 4/5/17.
////  Copyright © 2017 7apps. All rights reserved.
////
//
//import Foundation
////
////  ImagePreviewVC.Swift
////  WMN
////
////  Created by Aaron Dean Bikis on 2/16/17.
////  Copyright © 2017 7apps. All rights reserved.
////
//
//import UIKit
//import AVFoundation
//
//final class ImagePreviewVC: UIViewController, AVCapturePhotoCaptureDelegate, UITextFieldDelegate, ContactCardVCCreateDelegate, LocallyStorable, ContactCardLocationDelegate {
//    
//    var captureSession: AVCaptureSession?
//    var stillImageOutput: AVCapturePhotoOutput?
//    var previewLayer: AVCaptureVideoPreviewLayer?
//    var previewView: ImagePreviewView!
//    var stillImageView: UIImageView?
//    
//    var previewImage: UIImage! {
//        didSet {
//            self.stillImageView = UIImageView(image: previewImage)
//            stillImageView?.contentMode = .scaleAspectFill
//            stillImageView?.clipsToBounds = true
//            previewView.preview.addSubview(stillImageView!)
//            stillImageView?.frame = previewView.bounds
//        }
//    }
//    
//    var contact: Contact?
//    
//    var contactCardVC: ContactCardVC!
//    
//    var locationName: String?
//    
//    //MARL: LifeCycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        previewView = ImagePreviewView.instanceFromNib(withOwner: self)
//        previewView.frame = view.bounds
//        previewView.configure()
//        view.addSubview(previewView)
//        
//        contactCardVC = ContactCardVC()
//        contactCardVC.editContact = contact
//        contactCardVC.VCtype = CardVCType.addContact
//        contactCardVC.locationName = locationName
//        contactCardVC.view.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: view.frame.height)
//        //Set the navbarHeight for the card to animate up to
//        contactCardVC.navBarHeight = previewView.unwindButton.frame.origin.y + previewView.unwindButton.frame.height
//        //set Delegates
//        contactCardVC.locationDelegate = self
//        contactCardVC.createDelegate = self
//        //Present the VC
//        self.addChildViewController(contactCardVC)
//        self.view.addSubview(contactCardVC.view)
//        contactCardVC.didMove(toParentViewController: self)
//        contactCardVC.cardState = .closed
//        //Gestures
//        let tgr = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
//        self.view.addGestureRecognizer(tgr)
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        //The user already took a picture and is returning from somewhere
//        if previewImage != nil { return }
//        //The user is editing a contact
//        if let imageRef = contact?.imageRef {
//            previewImage = readImageFromDocumentsDirectory(WithFilepath: imageRef)
//            contactCardVC.addContactCard.shootPhotoButton.animateButtonState = .exit
//            return
//        } else {
//            //the user is either creating a new contact or editing a contact that didn't already have a picture
//            initilizeCaptureSession()
//        }
//    }
//    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        if stillImageView != nil {
//            self.stillImageView?.frame = previewView.bounds
//        }
//    }
//    
//    func initilizeCaptureSession(){
//        captureSession = AVCaptureSession()
//        captureSession!.sessionPreset = AVCaptureSessionPresetPhoto
//        stillImageOutput = AVCapturePhotoOutput()
//        
//        
//        guard let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) else {
//            //Device doesn't have a camera
//            previewView.preview.backgroundColor = .black
//            return
//        }
//        
//        let input = try? AVCaptureDeviceInput(device: device)
//        if (captureSession!.canAddInput(input)) {
//            captureSession!.addInput(input)
//            if (captureSession!.canAddOutput(stillImageOutput)) {
//                captureSession!.addOutput(stillImageOutput)
//                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//                previewLayer!.frame = previewView.bounds
//                previewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
//                previewView.preview.layer.addSublayer(previewLayer!)
//                captureSession?.startRunning()
//            }
//        }
//    }
//    
//    func handleTap( _ sender: UITapGestureRecognizer){
//        contactCardVC.view.endEditing(true)
//    }
//    
//    //MARK Coordinator Methods
//    var editContact: ((String?, String?, String?, UIImage?, Int?) throws -> Void)?
//    
//    var finishShowing: (() -> Void)!
//    
//    var editLocation: (() -> Void)!
//    
//    //MARK: ImagePreviewView Actions
//    @IBAction func shouldCreateContact(_ sender: Any) {
//        let cardView = contactCardVC.addContactCard
//        do {
//            try editContact?(cardView.nameTextField.text,
//                             cardView.notesTextField.text,
//                             cardView.locationTextField.text,
//                             stillImageView?.image,
//                             contact?.id)
//            finishShowing()
//        }
//        catch let error as WMNError {
//            print(error.description)
//        }
//        catch {
//            print("unknown error")
//        }
//    }
//    
//    
//    @IBAction func shouldUnwind(_ sender: Any) {
//        finishShowing()
//    }
//    
//    //MARK: ContactCardVC Delegates
//    func photoButtonTriggered(_ sender: ShootPhotoButton) {
//        if sender.animateButtonState == .exit {
//            stillImageView?.removeFromSuperview()
//            stillImageView = nil
//            if captureSession == nil {
//                initilizeCaptureSession()
//                return
//            }
//            captureSession?.startRunning()
//            return
//        }
//        //Is in circle state and we should shoot an image
//        let settings = AVCapturePhotoSettings()
//        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
//        let previewFormat = [
//            kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
//            kCVPixelBufferWidthKey as String: 160,
//            kCVPixelBufferHeightKey as String: 160
//        ]
//        settings.previewPhotoFormat = previewFormat
//        stillImageOutput?.capturePhoto(with: settings, delegate: self)
//    }
//    
//    func shouldHideAcceptButton(_ shouldHide: Bool) {
//        previewView.acceptButton.isHidden = shouldHide
//    }
//    
//    func contactCardToEditLocation() {
//        editLocation()
//    }
//    
//    
//    //MARK: AVCapture Delegate
//    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
//        
//        if let error = error {
//            print("error capturing image : \(error.localizedDescription)")
//        }
//        
//        guard let sampleBuffer = photoSampleBuffer,
//            let previewBuffer = previewPhotoSampleBuffer,
//            let dataImage =  AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer:  sampleBuffer, previewPhotoSampleBuffer: previewBuffer) else { return }
//        
//        let dataProvider = CGDataProvider(data: dataImage as CFData)
//        let cgImageRef: CGImage! = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
//        let image = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: UIImageOrientation.right)
//        previewImage = image
//        captureSession?.stopRunning()
//        //if this changes while editing a contact we want to be able to push those changes
//        if contact != nil {
//            shouldHideAcceptButton(false)
//        }
//    }
//}
