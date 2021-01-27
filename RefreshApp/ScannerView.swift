//
//  ScannerView.swift
//  RefreshApp
//
//  Created by 篠崎 明子 on 2020/11/06.
//  Copyright © 2020 Akiko Shinozaki. All rights reserved.
//

import UIKit

import AVFoundation
import AudioToolbox

protocol ScannerViewDelegate{
    func removeView()
    func getData(data:String)
}

class ScannerView: UIView, AVCaptureMetadataOutputObjectsDelegate {

    var delegate:ScannerViewDelegate?
    let session = AVCaptureSession()
    var videoLayer: AVCaptureVideoPreviewLayer?
    var cautionLabel:UILabel! = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 50))

    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var preview: UIView!
    @IBOutlet weak var closeBtn: UIButton!

    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        closeBtn.addTarget(self, action: #selector(close), for: .touchUpInside)
        // 入力（背面カメラ）
        let videoDevice = AVCaptureDevice.default(for: .video)!
        let videoInput = try! AVCaptureDeviceInput.init(device: videoDevice)
        
        if session.inputs.isEmpty {
            session.addInput(videoInput)
        }
        
        // 出力（メタデータ）
        let metadataOutput = AVCaptureMetadataOutput()

        if session.outputs.isEmpty {
            session.addOutput(metadataOutput)
            
            // QRコードを検出した際のデリゲート設定
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            // QRコードの認識を設定
            metadataOutput.metadataObjectTypes = [.qr,.ean13]
        }
        // プレビュー表示
        videoLayer = AVCaptureVideoPreviewLayer.init(session: session)
        videoLayer?.frame = preview.bounds
        videoLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        //デバイスの向きとプレビューの向きを合わせる
        let orientation = UIDevice.current.orientation
        print(orientation.rawValue)
        switch orientation {
        case .portrait:
            videoLayer?.connection?.videoOrientation = .portrait
        case .landscapeLeft:
            videoLayer?.connection?.videoOrientation = .landscapeRight

        case .landscapeRight:
            videoLayer?.connection?.videoOrientation = .landscapeLeft

        default:
            break
        }
        
        // 端末回転の通知機能を設定します。
        let name = UIDevice.orientationDidChangeNotification
        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange(_:)), name: name, object: nil)
        
        baseView.layer.cornerRadius = 8.0
        baseView.clipsToBounds = true
        
        preview.layer.addSublayer(videoLayer!)
        
        //cautionLabelの設定
        cautionLabel.frame = CGRect(x: 0, y: 20, width: preview.frame.size.width, height: 30)
        cautionLabel.font = UIFont.boldSystemFont(ofSize: 20)
        cautionLabel.textAlignment = .center
        cautionLabel.textColor = UIColor.yellow
        cautionLabel.backgroundColor = UIColor.clear
        cautionLabel.text = ""
        
        preview.addSubview(cautionLabel)
        cautionLabel.isHidden = true

        session.startRunning()
    }

    //コードから生成したときに通る初期化処理
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.nibInit()
    }
    
    // ストーリーボードで配置した時の初期化処理
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.nibInit()
    }

    
    // xibファイルを読み込んでviewに重ねる
    fileprivate func nibInit() {
        // File's OwnerをXibViewにしたので ownerはself になる
        guard let view = UINib(nibName: "ScannerView", bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView else {
            return
        }
        
        view.frame = self.bounds
        self.addSubview(view)
        
    }
    
    func metadataOutput(_ captureOutput: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // 複数のメタデータを検出
        for metadata in metadataObjects as! [AVMetadataMachineReadableCodeObject] {
            
            if metadata.type == .ean13 {
                if let data = metadata.stringValue {
                    print(data)
                    AudioServicesPlaySystemSound(1000)
                    cautionLabel.isHidden = true
                    self.session.stopRunning()
                    delegate?.getData(data: data)
                    self.close()
                }else {
                    print("nil")
                    cautionLabel.isHidden = false
                    cautionLabel.text = "このコードは読み取れません"
                }
            }else if metadata.type == .qr {
                if let data = metadata.stringValue, data.hasPrefix("RF=") {
                    print(data)
                    AudioServicesPlaySystemSound(1000)
                    cautionLabel.isHidden = true
                    self.session.stopRunning()
                    delegate?.getData(data: data)
                    self.close()
                }else {
                    cautionLabel.isHidden = false
                    cautionLabel.text = "このコードは読み取れません"
                }
            }else {
                cautionLabel.isHidden = false
                cautionLabel.text = "このコードは読み取れません"
            }
        }
    }
    
    
    @objc func orientationDidChange(_ notification: NSNotification) {

        //デバイスの向きとプレビューの向きを合わせる
            let orientation = UIDevice.current.orientation
            //print(orientation.rawValue)
            switch orientation {
            case .portrait:
                videoLayer?.connection?.videoOrientation = .portrait
            case .landscapeLeft:
                videoLayer?.connection?.videoOrientation = .landscapeRight

            case .landscapeRight:
                videoLayer?.connection?.videoOrientation = .landscapeLeft

            default:
                break
            }
        
       }
    
    
    @objc func close() {
        // 端末回転の通知機能の設定を解除します。
        let name = UIDevice.orientationDidChangeNotification
        NotificationCenter.default.removeObserver(self, name: name, object: nil)
        
        session.stopRunning()
        delegate?.removeView()
        self.removeFromSuperview()
    }
}
