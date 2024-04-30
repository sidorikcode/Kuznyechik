import Foundation

private let blockSize = 16

final class BlockCipherECB {
    
    // MARK: - Private properties
    
    private let blockCipher: BlockCipher
    
    private let queue = DispatchQueue(
        label: String(describing: BlockCipherECB.self),
        qos: .userInteractive,
        attributes: [.concurrent]
    )
        
    // MARK: - Lifecycles
    
    init(blockCipher: BlockCipher) {
        self.blockCipher = blockCipher
    }
    
    // MARK: - Public methods encrypt
    
    func encrypt(_ text: String, completion: @escaping (String) -> Void) {
        let blocks = getBlocks(fromOpenText: text)
        
        encrypt(blocks: blocks) { encryptBlocks in
            let cipherText = Data(encryptBlocks.flatMap { $0 } ).base64EncodedString()
            completion(cipherText)
        }
    }
    
    func encrypt(_ data: Data, completion: @escaping (Data) -> Void) {
        let blocks = getBlocks(fromOpenBytes: [UInt8](data))
        
        encrypt(blocks: blocks) { encryptBlocks in
            print("ИТОГО! БЫЛО \(blocks.count) стало \(encryptBlocks.count)")
            completion(Data(encryptBlocks.flatMap { $0 } ))
        }
    }
    
    // MARK: - Public methods decrypt
    
    func decrypt(_ text: String, completion: @escaping (Result<String, Errors>) -> Void) {
        guard let blocks = getBlocks(fromCipherText: text) else {
            completion(.failure(.canNotEndcodeCipherText))
            return
        }
        
        decrypt(blocks: blocks) { decryptBlocks in
            guard let openText = String(bytes: decryptBlocks.flatMap { $0 }, encoding: .utf8) else {
                completion(.failure(.canNotEndcodeEncryptBlocks))
                return
            }
            completion(.success(openText))
        }
    }
    
    func decrypt(_ data: Data, completion: @escaping (Result<Data, Errors>) -> Void) {
        guard let blocks = getBlocks(fromCipherBytes: [UInt8](data)) else {
            completion(.failure(.cipherBlocksNotFull))
            return
        }
        
        decrypt(blocks: blocks) { decryptBlocks in
            completion(.success(Data(decryptBlocks.flatMap { $0 } )))
        }
    }
    
    // MARK: - Private methods
    
    private func encrypt(blocks: [[UInt8]], completion: @escaping ([[UInt8]]) -> Void) {
        var encryptBlocks: [[UInt8]] = blocks
        
        let group = DispatchGroup()
        
        for (i, block) in blocks.enumerated() {
            group.enter()
            queue.async {
                let encryptBlock = self.blockCipher.encrypt(block)
                
                DispatchQueue.main.async {
                    encryptBlocks[i] = encryptBlock
                    group.leave()
                }
            }
        }

        group.notify(queue: .main) {
            completion(encryptBlocks)
        }
    }
    
    private func decrypt(blocks: [[UInt8]], completion: @escaping ([[UInt8]]) -> Void) {
        var decryptBlocks: [[UInt8]] = blocks
        
        let group = DispatchGroup()
        
        for (i, block) in blocks.enumerated() {
            group.enter()
            queue.async {
                let decryptBlock = self.blockCipher.decrypt(block)
                
                DispatchQueue.main.async {
                    decryptBlocks[i] = decryptBlock
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            completion(decryptBlocks)
        }
    }
    
    // MARK: - Text and Bytes Conversion

    private func createBlocks(fromBytes: [UInt8]) -> [[UInt8]] {
        stride(from: 0, to: fromBytes.count, by: blockSize).map { start in
            let end = min(start + blockSize, fromBytes.count)
            return Array(fromBytes[start..<end])
        }
    }
    
    private func createBlocksWithFullBlock(fromBytes: [UInt8]) -> [[UInt8]] {
        var bytes = fromBytes
        
        let sizeLastBlock = bytes.count % blockSize
        
        bytes.append(1)
        bytes.append(contentsOf: Array(repeating: 0, count: blockSize - 1 - sizeLastBlock))

        return createBlocks(fromBytes: bytes)
    }
    
    private func getBlocks(fromOpenBytes: [UInt8]) -> [[UInt8]] {
        createBlocksWithFullBlock(fromBytes: fromOpenBytes)
    }
    
    private func getBlocks(fromCipherBytes: [UInt8]) -> [[UInt8]]? {
        guard fromCipherBytes.count % blockSize == 0 else {
            return nil
        }
        return createBlocks(fromBytes: fromCipherBytes)
    }
    
    private func getBlocks(fromOpenText text: String) -> [[UInt8]] {
        createBlocksWithFullBlock(fromBytes: [UInt8](text.utf8))
    }
    
    private func getBlocks(fromCipherText text: String) -> [[UInt8]]? {
        guard let data = Data(base64Encoded: text) else {
            return nil
        }
        
        let blockSize = 16
        let bytes = [UInt8](data)
        
        guard bytes.count % blockSize == 0 else {
            return nil
        }
        
        return createBlocks(fromBytes: bytes)
    }
}

// MARK: - CipherECBError
extension BlockCipherECB {
    enum Errors: Error {
        case canNotEndcodeCipherText
        case canNotEndcodeEncryptBlocks
        case cipherBlocksNotFull
    }
}
