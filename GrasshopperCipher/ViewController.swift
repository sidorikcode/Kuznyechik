//
//  ViewController.swift
//  GrasshopperCipher
//
//  Created by Илья Сидорик on 28.04.2024.
//

import UIKit
import MobileCoreServices


let key: [UInt8] = [118, 246, 100, 167, 65, 32, 54, 239, 25, 131, 95, 17, 129, 175, 97, 26, 182, 180, 98, 242, 147, 154, 157, 76, 214, 93, 29, 164, 75, 78, 83, 111]
//UInt64
let sBox: [UInt8] = [
    0xd3, 0x7e, 0x13, 0x18, 0xa9, 0xbd, 0x91, 0x9b, 0xcd, 0xd7, 0x4f, 0x20, 0x6e, 0x9d, 0xc1, 0x52,
    0x89, 0xab, 0xbb, 0x21, 0x5b, 0x4d, 0x74, 0xd4, 0x44, 0x2f, 0xf6, 0x64, 0x90, 0xd8, 0xa3, 0xe6,
    0xda, 0xea, 0x2c, 0xb9, 0x95, 0x3d, 0xd1, 0xfc, 0x07, 0x0a, 0x30, 0xbc, 0xa0, 0x45, 0xf9, 0xd5,
    0x09, 0x79, 0xc4, 0xaa, 0xd9, 0x56, 0x97, 0xbf, 0xb0, 0xb5, 0x7d, 0x8f, 0x01, 0x87, 0xe3, 0x16,
    0xf1, 0xb8, 0xc9, 0xdd, 0x5a, 0xad, 0x58, 0x70, 0xf2, 0x46, 0x0d, 0x2a, 0x69, 0x0c, 0x33, 0x1e,
    0x7b, 0x72, 0x03, 0x88, 0x22, 0x9f, 0xfe, 0x06, 0xed, 0x8e, 0x25, 0xb1, 0xba, 0x7c, 0x3a, 0xe4,
    0x12, 0x42, 0x5f, 0xfb, 0xa8, 0x6f, 0x7f, 0xe7, 0x34, 0x05, 0xca, 0x41, 0x75, 0xcb, 0x51, 0x66,
    0x3e, 0x40, 0x0b, 0x5c, 0x54, 0x2e, 0xae, 0x8a, 0x53, 0x1a, 0x28, 0x81, 0x68, 0xce, 0x94, 0x4a,
    0xa1, 0x02, 0xb3, 0x93, 0x17, 0x6c, 0x9a, 0x9c, 0x55, 0xe8, 0x15, 0xd2, 0xa6, 0xe0, 0xeb, 0xb7,
    0x1f, 0x3f, 0xf5, 0xf3, 0xc8, 0xf8, 0x37, 0x60, 0x24, 0x63, 0x5d, 0xa7, 0x99, 0x6b, 0x0e, 0xc2,
    0x84, 0x36, 0x8c, 0x35, 0xc6, 0xcf, 0x1b, 0x4b, 0xfd, 0xcc, 0xc7, 0x59, 0xa4, 0xc3, 0x27, 0xee,
    0x2d, 0x38, 0x31, 0x4c, 0x32, 0x49, 0x3c, 0xa2, 0xec, 0x39, 0x29, 0x5e, 0x8d, 0xdb, 0x4e, 0xd0,
    0xef, 0x08, 0x43, 0x1c, 0xc5, 0xdf, 0x80, 0xfa, 0x04, 0xf7, 0xe5, 0x57, 0x1d, 0x11, 0x96, 0x47,
    0x2b, 0x86, 0xac, 0x8b, 0xff, 0xb2, 0xb6, 0x83, 0x26, 0x6d, 0x3b, 0x48, 0xe9, 0x7a, 0x61, 0xc0,
    0x78, 0x67, 0xf4, 0x00, 0x98, 0xdc, 0xbe, 0x9e, 0x85, 0xf0, 0x82, 0x6a, 0x10, 0x0f, 0x19, 0xe1,
    0x50, 0x76, 0x92, 0x14, 0x73, 0x62, 0x23, 0xd6, 0xde, 0xe2, 0x71, 0x77, 0xaf, 0x65, 0xa5, 0xb4,
]

class ViewController: UIViewController, UIDocumentPickerDelegate {
    
    private let label: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.text = "!!!!!!!!!!!!!!!!"
        return label
    }()
    
    private let encryptButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue
        button.setTitle("encrypt", for: .normal)
        return button
    }()
    
    private let decryptButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue
        button.setTitle("decrypt", for: .normal)
        return button
    }()
    
    private let openDocumentsButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue
        button.setTitle("Открыть документы", for: .normal)
        return button
    }()
    
    var test: BlockCipherECB?
//    var test: BlockCipherCTR?


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        // Do any additional setup after loading the view.
        
        view.addSubview(label)
        view.addSubview(encryptButton)
        view.addSubview(decryptButton)
        view.addSubview(openDocumentsButton)
        
        encryptButton.addTarget(self, action: #selector(didTapEncryptButton), for: .touchUpInside)
        decryptButton.addTarget(self, action: #selector(didTapDecryptButton), for: .touchUpInside)
        openDocumentsButton.addTarget(self, action: #selector(didTapopenDocumentsButton), for: .touchUpInside)

        let kyz = KuznyechikCipher(key: key, sBox: sBox)
//        test = CipherECB(blockCipher: kyz)
        
        test = BlockCipherECB(blockCipher: kyz)
//        test(testArray: Array(repeating: 1, count: 20))
//        test = CrasshopperCipher(key: key, sBox: sBox, mode: .ECB)
    }
    
    var lastPath: URL?
    
    @objc private func didTapopenDocumentsButton() {
        if let lastPath = lastPath {
            do {
                let fileData = try Data(contentsOf: lastPath)
                test?.decrypt(fileData) { result in
                    switch result {
                    case .success(let data):
                        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("savedFile2.txt")

                        do {
                            try data.write(to: path)
                            print("Файл успешно расшифрован и сохранён.")
                        } catch {
                            print("Ошибка записи файла")
                        }
                    case .failure(let error):
                        print("ОШИБКА!!!!! \(error)")
                        return
                    }
                }
            } catch {
                print("Не удалось открыть файл!")
            }
        } else {
            let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypeItem as String], in: .import)
            documentPicker.delegate = self
            documentPicker.modalPresentationStyle = .formSheet
            self.present(documentPicker, animated: true, completion: nil)
        }
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }

//        print(url)


        do {
            let fileData = try Data(contentsOf: url)

            test?.encrypt(fileData) { encryptData in
//                let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("savedFile.txt")

                print("ЩАС БУДЕТ ПУТЬ")
                print(path)
                print("ПУТЬ ЗАКОНЧИЛСЯ")

                self.lastPath = path

//                let outputFilePath = url.deletingLastPathComponent().appendingPathComponent("encryptedFile")
                do {
                    try encryptData.write(to: path)
                    print("Файл успешно зашифрован и сохранён.")
                } catch {
                    print("Ошибка записи файла")
                }
            }

        } catch {
            print("Ошибка при обработке файла: \(error)")
        }
    }
    
//    let queue = DispatchQueue(label: "Test", attributes: .concurrent)
    
    
//    func test(testArray: [Int]) {
//        var copy = testArray
//
//        for i in 0...20 {
//            self.funcAcync { newInt in
//                DispatchQueue.main.async {
//                    <#code#>
//                }
//            }
//        }
//    }
    
//    func funcAcync(completion: @escaping (Int) -> Void) {
//        queue.async {
//            let randonInt = Int.random(in: 0...100)
//            let randomTimeSleep = Double.random(in: 0.1...0.3)
//            
//            sleep(UInt32(randomTimeSleep))
//            
//            completion(randonInt)
//        }
//    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        encryptButton.frame = CGRect(
            x: 0,
            y: 0,
            width: view.bounds.width,
            height: 50
        )
        encryptButton.center = view.center
        
        decryptButton.frame = CGRect(
            x: encryptButton.frame.minX,
            y: encryptButton.frame.maxY + 12,
            width: view.bounds.width,
            height: 50
        )
        
        openDocumentsButton.frame = CGRect(
            x: decryptButton.frame.minX,
            y: decryptButton.frame.maxY + 12,
            width: view.bounds.width,
            height: 50
        )
        
        label.sizeToFit()
        label.frame = CGRect(
            x: view.frame.minX + 12,
            y: 100,
            width: view.bounds.width - 24,
            height: 100
        )

//        label.sizeToFit()
        label.numberOfLines = 0
        
    }
    
    @objc private func didTapEncryptButton() {
//        let test = test?.encrypt("Привет меня зовут ilia Sidorik и мне 27 лет, недавно я поставил что то типо брекетов себе на зубы и теперь я ZYBASTIK000")
        let testText = "Привет меня зовут ilia Sidorik и мне 27 лет, недавно я поставил что то типо брекетов себе на зубы и теперь я ZYBASTIK000Привет меня зовут ilia Sidorik и мне 27 лет, недавно я поставил что то типо брекетов себе на зубы и теперь я ZYBASTIK000Привет меня зовут ilia Sidorik и мне 27 лет, недавно я поставил что то типо брекетов себе на зубы и теперь я ZYBASTIK000Привет меня зовут ilia Sidorik и мне 27 лет, недавно я поставил что то типо брекетов себе на зубы и теперь я ZYBASTIK000Привет меня зовут ilia Sidorik и мне 27 лет, недавно я поставил что то типо брекетов себе на зубы и теперь я ZYBASTIK000Привет меня зовут ilia Sidorik и мне 27 лет, недавно я поставил что то типо брекетов себе на зубы и теперь я ZYBASTIK000Привет меня зовут ilia Sidorik и мне 27 лет, недавно я поставил что то типо брекетов себе на зубы и теперь я ZYBASTIK000Привет меня зовут ilia Sidorik и мне 27 лет, недавно я поставил что то типо брекетов себе на зубы и теперь я ZYBASTIK000Привет меня зовут ilia Sidorik и мне 27 лет, недавно я поставил что то типо брекетов себе на зубы и теперь я ZYBASTIK000Привет меня зовут ilia Sidorik и мне 27 лет, недавно я поставил что то типо брекетов себе на зубы и теперь я ZYBASTIK000Привет меня зовут ilia Sidorik и мне 27 лет, недавно я поставил что то типо брекетов себе на зубы и теперь я ZYBASTIK000Привет меня зовут ilia Sidorik и мне 27 лет, недавно я поставил что то типо брекетов себе на зубы и теперь я ZYBASTIK000Привет меня зовут ilia Sidorik и мне 27 лет, недавно я поставил что то типо брекетов себе на зубы и теперь я ZYBASTIK000Привет меня зовут ilia Sidorik и мне 27 лет, недавно я поставил что то типо брекетов себе на зубы и теперь я ZYBASTIK000Привет меня зовут ilia Sidorik и мне 27 лет, недавно я поставил что то типо брекетов себе на зубы и теперь я ZYBASTIK000Привет меня зовут ilia Sidorik и мне 27 лет, недавно я поставил что то типо брекетов себе на зубы и теперь я ZYBASTIK000Привет меня зовут ilia Sidorik и мне 27 лет, недавно я поставил что то типо брекетов себе на зубы и теперь я ZYBASTIK000Привет меня зовут ilia Sidorik и мне 27 лет, недавно я поставил что то типо брекетов себе на зубы и теперь я ZYBASTIK000Привет меня зовут ilia Sidorik и мне 27 лет, недавно я поставил что то типо брекетов себе на зубы и теперь я ZYBASTIK000Привет меня зовут ilia Sidorik и мне 27 лет, недавно я поставил что то типо брекетов себе на зубы и теперь я ZYBASTIK000Привет меня зовут ilia Sidorik и мне 27 лет, недавно я поставил что то типо брекетов себе на зубы и теперь я ZYBASTIK000Привет меня зовут ilia Sidorik и мне 27 лет, недавно я поставил что то типо брекетов себе на зубы и теперь я ZYBASTIK000Привет меня зовут ilia Sidorik и мне 27 лет, недавно я поставил что то типо брекетов себе на зубы и теперь я ZYBASTIK000Привет меня зовут ilia Sidorik и мне 27 лет, недавно я поставил что то типо брекетов себе на зубы и теперь я ZYBASTIK000Привет меня зовут ilia Sidorik и мне 27 лет, недавно я поставил что то типо брекетов себе на зубы и теперь я ZYBASTIK000Привет меня зовут ilia Sidorik и мне 27 лет, недавно я поставил что то типо брекетов себе на зубы и теперь я ZYBASTIK000Привет меня зовут ilia Sidorik и мне 27 лет, недавно я поставил что то типо брекетов себе на зубы и теперь я ZYBASTIK000Привет меня зовут ilia Sidorik и мне 27 лет, недавно я поставил что то типо брекетов себе на зубы и теперь я ZYBASTIK000Привет меня зовут ilia Sidorik и мне 27 лет, недавно я поставил что то типо брекетов себе на зубы и теперь я ZYBASTIK000Привет меня зовут ilia Sidorik и мне 27 лет, недавно я поставил что то типо брекетов себе на зубы и теперь я ZYBASTIK000Привет меня зовут ilia Sidorik и мне 27 лет, недавно я поставил что то типо брекетов себе на зубы и теперь я ZYBASTIK000Привет меня зовут ilia Sidorik и мне 27 лет, недавно я поставил что то типо брекетов себе на зубы и теперь я ZYBASTIK000Привет меня зовут ilia Sidorik и мне 27 лет, недавно я поставил что то типо брекетов себе на зубы и теперь я ZYBASTIK000Привет меня зовут ilia Sidorik и мне 27 лет, недавно я поставил что то типо брекетов себе на зубы и теперь я ZYBASTIK000Привет меня зовут ilia Sidorik и мне 27 лет, недавно я поставил что то типо брекетов себе на зубы и теперь я ZYBASTIK000Привет меня зовут ilia Sidorik и мне 27 лет, недавно я поставил что то типо брекетов себе на зубы и теперь я ZYBASTIK000Привет меня зовут ilia Sidorik и мне 27 лет, недавно я поставил что то типо брекетов себе на зубы и теперь я ZYBASTIK000Привет меня зовут ilia Sidorik и мне 27 лет, недавно я поставил что то типо брекетов себе на зубы и теперь я ZYBASTIK000Привет меня зовут ilia Sidorik и мне 27 лет, недавно я поставил что то типо брекетов себе на зубы и теперь я ZYBASTIK000Привет меня зовут ilia Sidorik и мне 27 лет, недавно я поставил что то типо брекетов себе на зубы и теперь я ZYBASTIK000Привет меня зовут ilia Sidorik и мне 27 лет, недавно я поставил что то типо брекетов себе на зубы и теперь я ZYBASTIK000Привет меня зовут ilia Sidorik и мне 27 лет, недавно я поставил что то типо брекетов себе на зубы и теперь я ZYBASTIK000Привет меня зовут ilia Sidorik и мне 27 лет, недавно я поставил что то типо брекетов себе на зубы и теперь я ZYBASTIK000Привет меня зовут ilia Sidorik и мне 27 лет, недавно я поставил что то типо брекетов себе на зубы и теперь я ZYBASTIK000Привет меня зовут ilia Sidorik и мне 27 лет, недавно я поставил что то типо брекетов себе на зубы и теперь я ZYBASTIK000Привет меня зовут ilia Sidorik и мне 27 лет, недавно я поставил что то типо брекетов себе на зубы и теперь я ZYBASTIK000Привет меня зовут ilia Sidorik и мне 27 лет, недавно я поставил что то типо брекетов себе на зубы и теперь я ZYBASTIK000Привет меня зовут ilia Sidorik и мне 27 лет, недавно я поставил что то типо брекетов себе на зубы и теперь я ZYBASTIK000Привет меня зовут ilia Sidorik и мне 27 лет, недавно я поставил что то типо брекетов себе на зубы и теперь я ZYBASTIK000Привет меня зовут ilia Sidorik и мне 27 лет, недавно я поставил что то типо брекетов себе на зубы и теперь я ZYBASTIK000Привет меня зовут ilia Sidorik и мне 27 лет, недавно я поставил что то типо брекетов себе на зубы и теперь я "
        
        test?.encrypt(testText) { text in
            self.label.text = text
        }
    }
    
    @objc private func didTapDecryptButton() {
        let testText = label.text!
        
        test?.decrypt(testText) { result in
            switch result {
            case .success(let text):
                self.label.text = text
            case .failure(let error):
                print("ОШИБКА!!!!!!!!!!!!!!!!!!!!!! = \(error)")
            }
        }
    }


}

