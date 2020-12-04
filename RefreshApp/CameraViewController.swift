//
//  CameraViewController.swift
//  RefreshApp
//
//  Created by 篠崎 明子 on 2020/11/06.
//  Copyright © 2020 Akiko Shinozaki. All rights reserved.
//


import UIKit
import AVFoundation

extension UIImage {

    func rotate(angle: CGFloat, orientation:String) -> UIImage{
        // オリジナルの画像サイズと同じサイズでコンテキストを開く
        UIGraphicsBeginImageContextWithOptions(CGSize(width: self.size.width, height: self.size.height), false, 0.0)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        //　座標軸の原点を画像の中心点に移動
        context.translateBy(x: self.size.width/2, y: self.size.height/2)
        //　y軸を反転してCoreGraphicsとiOSのデフォルト座標系を合わせる
        context.scaleBy(x: 1.0, y: -1.0)

        // 任意の角度で回転　時計回りを正とするために、受けとったangleを反転
        //let radian: CGFloat = (-angle) * CGFloat.pi / 180.0　←　角度で受け取る場合
        context.rotate(by: -angle)
        // 座標軸の原点を基準にRect領域を作成し，オリジナル画像を描画
         //縦方向の画像を受け取った時
         if(orientation == "Portrait"){
         context.draw(self.cgImage!, in: CGRect(x: -self.size.height/2, y: -self.size.width/2, width: self.size.height, height: self.size.width))
         //横方向の画像を受け取った時
         }else if(orientation == "Landscape"){
         context.draw(self.cgImage!, in: CGRect(x: -self.size.width / 2, y: -self.size.height / 2, width: self.size.width, height: self.size.height))
         }
        //描画したImageをrotatedImageに格納
        let rotatedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return rotatedImage
    }
    
}

var imageTag:Int = 0
var imageArr:[UIImage] = []
var dispImg:UIImage!

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate, UINavigationControllerDelegate {
    var device: AVCaptureDevice!
    var session: AVCaptureSession!
    var output: AVCapturePhotoOutput!
    var previewLayer:AVCaptureVideoPreviewLayer!

    @IBOutlet weak var toolbar: UIToolbar!
    //@IBOutlet weak var tagLabel: UILabel!
    
    var image:UIImage!
//    var imageExist:Bool = false
    var shutterButton = UIButton()
    var tagLabel:UILabel!
    
    // 回転禁止
    override var shouldAutorotate: Bool {
        get {
            return false
        }
    }
    
    // 画面の向きを固定
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            //return .landscapeRight
            return .landscape
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        // セッションを生成
        session = AVCaptureSession()
        session.sessionPreset = .photo
        output = AVCapturePhotoOutput()
        device = AVCaptureDevice.default(for: .video)
        //バックカメラを指定
        //device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)

        do {
            let input = try AVCaptureDeviceInput(device: device)
            if (session.canAddInput(input)) {
                session.addInput(input)
                if (session.canAddOutput(output)) {
                    session.addOutput(output)
                    session.startRunning()
                    // プレビューレイヤを生成
                    previewLayer = AVCaptureVideoPreviewLayer.init(session: session)
                    
                    let width = max(self.view.frame.size.width, self.view.frame.size.height)
                    let height = min(self.view.frame.size.width, self.view.frame.size.height) -
                        toolbar.frame.size.height

                    previewLayer.frame = CGRect(x: 0, y: 0, width: width, height: height)
                    previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                    self.view.layer.addSublayer(previewLayer)

                }
            }
        }
        catch {
            print(error)
        }
   
        //デバイスの向きによってプレビューの向き固定
        //LandscapeLeftの時以外はLandscapeRight
        let myDevice = UIDevice.current
        if myDevice.orientation == .landscapeRight {
            previewLayer.connection?.videoOrientation = .landscapeLeft
            //撮影した写真を回転するメソッド
        }else {
            //プレビューの向きも固定
            previewLayer.connection?.videoOrientation = .landscapeRight
        }
        self.view.layer.addSublayer(previewLayer)

        // セッションを開始
        session.startRunning()
        // 撮影ボタンを生成
        shutterButton.contentMode = .center
        shutterButton.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        shutterButton.setImage(UIImage(named: "shutter.png"), for: .normal)
        shutterButton.layer.position = CGPoint(x: previewLayer.frame.size.width - 60, y: previewLayer.frame.size.height - 200)
        shutterButton.addTarget(self, action: #selector(shot(_:)), for: .touchUpInside)
        view.addSubview(shutterButton)
        // tagLabelを生成
        let height = min(self.view.frame.size.width, self.view.frame.size.height)
        let label_y = height-self.toolbar.frame.size.height-160
        tagLabel = UILabel(frame: CGRect(x: 20, y: label_y, width: 512, height: 120))
        
        //tagNOがあれば表示
        if tagNO == "" {
            tagLabel.font = UIFont.boldSystemFont(ofSize: 50)
            tagLabel.text = "TAGNoが不明です"
            tagLabel.textColor = .red
        }else {
            tagLabel.font = UIFont.boldSystemFont(ofSize: 100)
            tagLabel.text = tagNO
            tagLabel.textColor = .black
        }
        
        tagLabel.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        tagLabel.textAlignment = .center
        tagLabel.adjustsFontSizeToFitWidth = true
        tagLabel.minimumScaleFactor = 0.5
        
        self.view.addSubview(tagLabel)

    }
    

    override func viewDidAppear(_ animated: Bool) {
        //print(#function)
        //回転の通知を受け取る（回転しないからいらない）
        //NotificationCenter.default.addObserver(self, selector: #selector(changeOrientation), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        if !session.isRunning {
            session.startRunning()
        }
        self.setToolBar()
    }
    
    func setToolBar() {
        /* ツールバーの設定 */
        let backButton = UIBarButtonItem(title: "戻る", style: .plain, target: self, action: #selector(self.back))
        //let cancelButton = UIBarButtonItem(title: "撮り直す", style: .plain, target: self, action: #selector(self.retake))
        //let useButton = UIBarButtonItem(title: "写真を使用", style: .plain, target: self, action: #selector(self.usePhoto))
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [backButton,flexSpace]

/*        if imageExist{
            toolbar.items = [cancelButton,flexSpace, useButton]
        }else {
            toolbar.items = [backButton,flexSpace]
        }*/

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    override func viewDidDisappear(_ animated: Bool) {
        //メモリ解放
        session.stopRunning()
        
        for output in session.outputs {
            session.removeOutput(output)
        }
        
        for input in session.inputs {
            session.removeInput(input)
        }
        previewLayer.removeFromSuperlayer()
        session = nil
        device = nil
    }*/
    
    //撮影ボタンを押した時の処理
    @objc func shot(_ sender: AnyObject) {
        let setting = AVCapturePhotoSettings()
        //setting.isAutoStillImageStabilizationEnabled = true
        setting.isHighResolutionPhotoEnabled = false
        output?.capturePhoto(with: setting, delegate: self)
        
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        print(#function)
          //セッションストップ
                self.session.stopRunning()
        if let photoData = photo.fileDataRepresentation() {
            //シャッターボタン非表示
            
            self.image = UIImage(data: photoData)
            
            self.usePhoto()
        }
        

    }

    
    //デバイスが回転したことを通知する（回転しないからいらない）
    @objc func changeOrientation(notification: NSNotification){
        //回転したら描画し直す
        //self.setToolBar()
    }
    
    @objc func back() {
        //メモリ解放
        session.stopRunning()
        
        for output in session.outputs {
            session.removeOutput(output)
        }
        
        for input in session.inputs {
            session.removeInput(input)
        }
        previewLayer.removeFromSuperlayer()
        session = nil
        device = nil
        
        self.dismiss(animated: true, completion: nil)
        //self.navigationController?.popViewController(animated: true)
    }
    
    @objc func usePhoto() {
        
        let img: UIImage = self.imgOrientation(image: image!) //向きを調整してから格納する

        //print(tagLabel.frame)
        //UIImageの画像をリサイズ
        let resize:CGFloat = 1.0
        let size:CGSize = CGSize(width: img.size.height * resize, height: img.size.width * resize)
        
        UIGraphicsBeginImageContext(size)
        img.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let resizedImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        print(resizedImg?.size)
        dispImg = resizedImg

        let storyboard: UIStoryboard = self.storyboard!
        let camera2 = storyboard.instantiateViewController(withIdentifier: "camera2")
        //self.navigationController?.pushViewController(camera2, animated: true)
        camera2.modalPresentationStyle = .fullScreen

        self.present(camera2, animated: false, completion: nil)

    }
    
    //撮影した写真の向きを調整
    func imgOrientation(image:UIImage) -> UIImage {
        var originalImage:UIImage!
        //写真が反対向きになってしまうので、180度回転
        if previewLayer.connection?.videoOrientation.rawValue == 4 {
            originalImage = image.rotate(angle: CGFloat.pi, orientation: "Landscape")

        }else {
            originalImage = image.rotate(angle: 0, orientation: "Landscape")

        }
        return originalImage
    }
    
}
