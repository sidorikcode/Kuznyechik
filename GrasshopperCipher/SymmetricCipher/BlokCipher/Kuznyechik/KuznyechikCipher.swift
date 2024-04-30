import Foundation

final class KuznyechikCipher {
    
    // MARK: - Private properties
    
    private let key: [UInt8]
    private let sBox: [UInt8]
    private let sBoxRevert: [UInt8]
    private let roundKeys: [[UInt8]]
    
    private let queue = DispatchQueue(label: String(describing: KuznyechikCipher.self), qos: .userInteractive, attributes: [.concurrent])
    
    // MARK: - Lifecycles
    
    init(key: [UInt8], sBox: [UInt8]) {
        let sBoxRevert = {
            var sBoxRevert = sBox
            for (i, value) in sBox.enumerated() {
                sBoxRevert[Int(value)] = UInt8(i)
            }
            return sBoxRevert
        }()
        
        self.key = key
        self.sBox = sBox
        self.sBoxRevert = sBoxRevert
        self.roundKeys = KuznyechikTransformations.generateRoundKey(masterKey: key, sBox: sBox)
    }
    
    // MARK: - Encrypt
    
    private func fullEncryptRound(block: [UInt8], roundKey: [UInt8]) -> [UInt8] {
        let resultX = KuznyechikTransformations.X(block, roundKey)
        let resultS = KuznyechikTransformations.S(resultX, sBox: sBox)
        let resutL = KuznyechikTransformations.L(resultS)
        
        return resutL
    }
    
    private func encryptBlock(for block: [UInt8], roundKeys: [[UInt8]]) -> [UInt8] {
        var resultBlock = block
        
        for roundKey in roundKeys.dropLast() {
            resultBlock = self.fullEncryptRound(block: resultBlock, roundKey: roundKey)
        }
        
        resultBlock = KuznyechikTransformations.X(resultBlock, roundKeys[9])
        
        return resultBlock
    }
    
    // MARK: - Decrypt

    private func fullDecryptRound(block: [UInt8], roundKey: [UInt8]) -> [UInt8] {
        let resultRevertL = KuznyechikTransformations.revertL(block)
        let resultRevertS = KuznyechikTransformations.revertS(resultRevertL, sBoxRevert: sBoxRevert)
        let resultX = KuznyechikTransformations.X(resultRevertS, roundKey)
        
        return resultX
    }

    private func decryptBlock(for block: [UInt8], roundKeys: [[UInt8]]) -> [UInt8] {
        var resultBlock = block
        
        resultBlock = KuznyechikTransformations.X(resultBlock, roundKeys[9])
        
        for roundKey in roundKeys.dropLast().reversed() {
            resultBlock = fullDecryptRound(block: resultBlock, roundKey: roundKey)
        }
        
        return resultBlock
    }
}

// MARK: - BlockCipher

extension KuznyechikCipher: BlockCipher {
    func encrypt(_ block: [UInt8]) -> [UInt8] {
        encryptBlock(for: block, roundKeys: roundKeys)
    }
    
    func decrypt(_ block: [UInt8]) -> [UInt8] {
        decryptBlock(for: block, roundKeys: roundKeys)
    }
}
