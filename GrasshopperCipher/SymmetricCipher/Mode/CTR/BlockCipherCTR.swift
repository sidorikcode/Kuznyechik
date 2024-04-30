import Foundation

private let blockSize = 16

// Для целей тестирвоания у параметров iv: [UInt8] в методах есть дефолтное значение
private let _iv: [UInt8] = [251, 230, 47, 86, 53, 50, 127, 226]

typealias ProcessDataCompletion = (Result<[[UInt8]], BlockCipherCTR.Errors>) -> Void
typealias StringCompletion = (Result<String, BlockCipherCTR.Errors>) -> Void
typealias DataCompletion = (Result<Data, BlockCipherCTR.Errors>) -> Void

final class BlockCipherCTR {
    
    // MARK: - Private properties
    
    private let blockCipher: BlockCipher
    
    private let queue = DispatchQueue(
        label: String(describing: BlockCipherCTR.self),
        qos: .userInteractive,
        attributes: [.concurrent]
    )
    
    // MARK: - Lifecycles
    
    init(blockCipher: BlockCipher) {
        self.blockCipher = blockCipher
    }
    
    // MARK: - Public methods encrypt

    func encrypt(_ text: String, iv: [UInt8] = _iv, completion: @escaping StringCompletion) {
        let blocks = createBlocks(fromBytes: [UInt8](text.utf8))
        
        processData(blocks: blocks, iv: iv, isEncrypt: true) { result in
            switch result {
            case .success(let encryptBlocks):
                let cipherText = Data(encryptBlocks.flatMap { $0 } ).base64EncodedString()
                completion(.success(cipherText))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func encrypt(_ data: Data, iv: [UInt8] = _iv, completion: @escaping DataCompletion) {
        let blocks = createBlocks(fromBytes: [UInt8](data))
        
        processData(blocks: blocks, isEncrypt: true) { result in
            switch result {
            case .success(let encryptBlocks):
                completion(.success(Data(encryptBlocks.flatMap { $0 })))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Public methods decrypt

    func decrypt(_ text: String, iv: [UInt8] = _iv, completion: @escaping StringCompletion) {
        guard let data = Data(base64Encoded: text) else {
            completion(.failure(.canNotEndcodeCipherText))
            return
        }
        
        let blocks = createBlocks(fromBytes: [UInt8](data))
        
        processData(blocks: blocks, iv: iv, isEncrypt: false) { result in
            
            switch result {
            case .success(let decryptBlocks):
                guard let openText = String(bytes: decryptBlocks.flatMap { $0 }, encoding: .utf8) else {
                    completion(.failure(.canNotEndcodeEncryptBlocks))
                    return
                }
                completion(.success(openText))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func decrypt(_ data: Data, iv: [UInt8] = _iv, completion: @escaping DataCompletion) {
        let blocks = createBlocks(fromBytes: [UInt8](data))
        
        processData(blocks: blocks, isEncrypt: false) { result in
            switch result {
            case .success(let encryptBlocks):
                completion(.success(Data(encryptBlocks.flatMap { $0 })))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Private methods
    
    private func processData(blocks: [[UInt8]], iv: [UInt8] = _iv, isEncrypt: Bool, completion: @escaping ProcessDataCompletion) {
        guard iv.count == 8 else {
            completion(.failure(.invadlidIV))
            return
        }
        
        let initCtr = iv + Array(repeating: 0, count: 8)
        
        var encryptBlocks = blocks
        
        let group = DispatchGroup()
        
        for (i, block) in blocks.enumerated() {
            group.enter()
            queue.async {
                let blockSize = block.count
                
                let ctr = self.incrementedCounter(initCtr, by: UInt64(i))
                let encryptCtr: [UInt8] = Array(self.blockCipher.encrypt(ctr)[0..<blockSize])
                
                let encryptBlock: [UInt8]
                if isEncrypt {
                    encryptBlock = KuznyechikTransformations.X(block, encryptCtr)
                } else {
                    encryptBlock = KuznyechikTransformations.X(encryptCtr, block)
                }
                
                DispatchQueue.main.async {
                    encryptBlocks[i] = encryptBlock
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            completion(.success(encryptBlocks))
        }
    }
    
    private func createBlocks(fromBytes: [UInt8]) -> [[UInt8]] {
        stride(from: 0, to: fromBytes.count, by: blockSize).map { start in
            let end = min(start + blockSize, fromBytes.count)
            return Array(fromBytes[start..<end])
        }
    }
    
    private func incrementedCounter(_ counter: [UInt8], by increment: UInt64) -> [UInt8] {
        var result = counter
        var carry = increment
        
        for i in (0..<result.count).reversed() {
            if carry == 0 {
                break
            }
            
            let addition = UInt64(result[i]) + (carry & 0xFF)
            result[i] = UInt8(addition & 0xFF)
            carry = addition >> 8
        }
        
        return result
    }
}

extension BlockCipherCTR {
    enum Errors: Error {
        case invadlidIV
        case canNotEndcodeCipherText
        case canNotEndcodeEncryptBlocks
    }
}






//
//
//private func incrementedCounter(_ counter: [UInt8], by increment: UInt64) -> [UInt8] {
//    guard counter.count == 16 else {
//        print("Invalid counter size.") // ERROR!
//        return counter
//    }
//
//    var result = counter
//    var carry = increment
//
//    for i in (0..<result.count).reversed() {
//        if carry == 0 {
//            break // Если не осталось ничего для прибавления, прекращаем цикл
//        }
//
//        let addition = UInt64(result[i]) + (carry & 0xFF) // Прибавляем младший байт оставшегося инкремента
//        result[i] = UInt8(addition & 0xFF) // Записываем младший байт результата в счетчик
//        carry = addition >> 8 // Переносим оставшиеся биты в carry для следующего байта
//    }
//
//    return result
//}
