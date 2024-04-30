//import Foundation
//
//enum KuznyechikTransformations {
//    // MARK: - Main ransformations
//    
//    /// Addition function in the Galois Field `(GF(2^8))`
//    static func X(_ lhs: [UInt8], _ rhs: [UInt8]) -> [UInt8] {
//        zip(lhs, rhs).map { $0 ^ $1 }
//    }
//    
//    /// Substitution function using an S-box.
//    static func S(_ butes: [UInt8], sBox: [UInt8]) -> [UInt8] {
//        butes.map { sBox[Int($0)] }
//    }
//
//    /// Inverse substitution function using an S-box.
//    static func revertS(_ butes: [UInt8], sBoxRevert: [UInt8]) -> [UInt8] {
//        butes.map { sBoxRevert[Int($0)] }
//    }
//    
//    /// Multiplication function in the Galois Field `(GF(2^8))`
//    static func galoisMultiply(_ a: UInt8, _ b: UInt8) -> UInt8 {
//        var result: UInt8 = 0
//        var x = a
//        var y = b
//        while y > 0 {
//            if y & 1 == 1 {
//                result ^= x
//            }
//            
//            x = x & 0x80 == 0
//            ? x << 1
//            : UInt8((UInt16(x) << 1) ^ 0x1C3)
//            
//            y >>= 1
//        }
//        return result
//    }
//    
//    /// Linear transformation function `l: V8^16 → V8`
//    static func l(_ block: [UInt8]) -> UInt8 {
//        let coefficients: [UInt8] = [148, 32, 133, 16, 194, 192, 1, 251, 1, 192, 194, 16, 133, 32, 148, 1] // Коэффициенты из ГОСТ (константы для линейной комбинации)
//
//        var result: UInt8 = 0
//
//        for (i, byte) in block.enumerated() {
//            let multiplied = galoisMultiply(byte, coefficients[i])
//            result ^= multiplied
//        }
//
//        return result
//    }
//    
//    static func R(_ block: [UInt8]) -> [UInt8] {
//        [l(block)] + block.dropLast()
//    }
//    
//    static func revertR(_ block: [UInt8]) -> [UInt8] {
//        let blockForLinearT: [UInt8] = block.dropFirst() + [block[0]]
//        
//        return block.dropFirst() + [l(blockForLinearT)]
//    }
//    
//    static func L(_ block: [UInt8]) -> [UInt8] {
//        var result = block
//        (0..<16).forEach { _ in
//            result = R(result)
//        }
//        return result
//    }
//
//    static func revertL(_ block: [UInt8]) -> [UInt8] {
//        var result = block
//        (0..<16).forEach { _ in
//            result = revertR(result)
//        }
//        return result
//    }
//    
//    // MARK: - Generate round key
//    
//    static func F(k constant: [UInt8], keys: (a1: [UInt8], a0: [UInt8]), sBox: [UInt8]) -> ([UInt8], [UInt8]) {
//        let resultX = X(constant, keys.a1)
//        let resultS = S(resultX, sBox: sBox)
//        let resutL = L(resultS)
//        
//        return (X(resutL, keys.a0), keys.a1)
//    }
//    
//    static func generateRoundKey(masterKey: [UInt8], sBox: [UInt8]) -> [[UInt8]] {
//        let constansForGenerageRoundKey = {
//            (0..<32).map {
//                var block = [UInt8](repeating: 0, count: 16)
//                block[15] = UInt8($0 + 1)
//                return block
//            }
//        }()
//        
//        var keys: [[UInt8]] = []
//
//        keys.append(Array(masterKey.prefix(16)))
//        keys.append(Array(masterKey.suffix(16)))
//
//        for i in 0...3 {
//            let upperBound = (8 * i) + 7
//            let lowerBound = (8 * i)
//            
//            let a1 = keys[2 * i]
//            let a0 = keys[(2 * i) + 1]
//
//            var iKeys = (a1, a0)
//            
//            (lowerBound...upperBound).reversed().enumerated().forEach {
//                iKeys = F(k: constansForGenerageRoundKey[$1], keys: iKeys, sBox: sBox)
//            }
//            
//            keys.append(contentsOf: [iKeys.0, iKeys.1])
//        }
//        
//        return keys
//    }
//}
//
//
//
//
//
//import Foundation
//
//final class CrasshopperCipher {
//    
//    // MARK: - Private properties
//    private let key: [UInt8]
//    private let sBox: SBox
//    private let sBoxRevert: SBox
//    private let roundKeys: [[UInt8]]
//    private var mode: Mode
//    
//    private let queue = DispatchQueue(label: String(describing: CrasshopperCipher.self), qos: .userInteractive, attributes: [.concurrent])
//    
//    // MARK: - Lifecycles
//    init(key: [UInt8], sBox: SBox, mode: Mode) {
//        let sBoxRevert = {
//            var sBoxRevert = sBox
//            for (i, value) in sBox.enumerated() {
//                sBoxRevert[Int(value)] = UInt8(i)
//            }
//            return sBoxRevert
//        }()
//        
//        self.key = key
//        self.sBox = sBox
//        self.sBoxRevert = sBoxRevert
//        self.roundKeys = KuznyechikTransformations.generateRoundKey(masterKey: key, sBox: sBox)
//        self.mode = mode
//    }
//    
//    // MARK: - Public methods
//    func encrypt(_ text: String, completion: @escaping (String) -> Void) {
//        let blocks = getBlocks(fromOpenText: text)
////        print("ЗАШИФРОВКА")
//        print(blocks.count)
//        var encryptBlocks: [[UInt8]] = blocks
//        print(blocks.count)
//        
//        let group = DispatchGroup()
//        
//        
//        for (i, block) in blocks.enumerated() {
//            group.enter()
//            queue.async {
//                let encryptBlock = self.encryptBlock(for: block, whith: self.roundKeys)
//                DispatchQueue.main.async {
//                    encryptBlocks[i] = encryptBlock
//                    group.leave()
//                }
//            }
//        }
//        
//        group.notify(queue: .main) {
//            completion(Data(encryptBlocks.flatMap({ $0 })).base64EncodedString())
//        }
////        return Data(encryptBlocks.flatMap({ $0 })).base64EncodedString()
//    }
//    
//    func decrypt(_ text: String) throws -> String {
//        guard let blocks = getBlocks(fromCipherText: text) else {
//            throw CrasshopperCipherErrors.canNotEncoding
//        }
//        print("ЗАШИФРОВКА")
//        print(blocks)
//        
//        
//        var decryptBlocks: [[UInt8]] = blocks
//        
//        for (i, block) in blocks.enumerated() {
//            decryptBlocks[i] = decryptBlock(for: block, whith: roundKeys, isLastBlock: i == blocks.count - 1)
//        }
//        
//        print(decryptBlocks)
//        
//        guard let openText = String(bytes: decryptBlocks.flatMap({ $0 }), encoding: .utf8) else {
//            throw CrasshopperCipherErrors.canNotEncoding
//        }
//        print(openText)
//        return openText
//    }
//    
//    // MARK: - Private methods
//    private func fullEncryptRound(block: [UInt8], roundKey: [UInt8]) -> [UInt8] {
//        let resultX = KuznyechikTransformations.X(block, roundKey)
//        let resultS = KuznyechikTransformations.S(resultX, sBox: sBox)
//        let resutL = KuznyechikTransformations.L(resultS)
//        
//        return resutL
//    }
//    
//    private func encryptBlock(for block: [UInt8], whith roundKeys: [[UInt8]]) -> [UInt8] {//, completion: @escaping ([UInt8]) -> Void) {
////        queue.async {
//            var resultBlock = block
//            
//            for roundKey in roundKeys.dropLast() {
//                resultBlock = self.fullEncryptRound(block: resultBlock, roundKey: roundKey)
//            }
//            
//            resultBlock = KuznyechikTransformations.X(resultBlock, roundKeys[9])
//            
////            completion(resultBlock)
//                    return resultBlock
////        }
//    }
//    
//    private func fullDecryptRound(block: [UInt8], roundKey: [UInt8]) -> [UInt8] {
//        let resultRevertL = KuznyechikTransformations.revertL(block)
//        let resultRevertS = KuznyechikTransformations.revertS(resultRevertL, sBoxRevert: sBoxRevert)
//        let resultX = KuznyechikTransformations.X(resultRevertS, roundKey)
//        
//        return resultX
//    }
//
//    private func decryptBlock(for block: [UInt8], whith roundKeys: [[UInt8]], isLastBlock: Bool) -> [UInt8] {
//        var resultBlock = block
//        
//        resultBlock = KuznyechikTransformations.X(resultBlock, roundKeys[9])
//        
//        for roundKey in roundKeys.dropLast().reversed() {
//            resultBlock = fullDecryptRound(block: resultBlock, roundKey: roundKey)
//        }
//        
////        if isLastBlock {
////            return resultBlock
////                .reversed()
////                .drop(while: { $0 == 0 })
////                .reversed()
////        } else {
////            return resultBlock
////        }
////        String(bytes: <#T##Sequence#>, encoding: <#T##String.Encoding#>) сам убирает последние 0
//        return resultBlock
//    }
//    
//    // MARK: - Text and Bytes Conversion
//    private func getBlocks(from bytes: [UInt8]) -> [[UInt8]] {
//        let blockSize = 16
//        
//        return stride(from: 0, to: bytes.count, by: blockSize).map { start in
//            let end = min(start + blockSize, bytes.count)
//            var block = Array(bytes[start..<end])
//            
//            if block.count < blockSize {
//                print("Добавили!")
//                block.append(contentsOf: Array(repeating: 0, count: blockSize - block.count))
//            }
//            return block
//        }
//    }
//    
//    private func getBlocks(fromOpenText text: String) -> [[UInt8]] {
//        let byteArray = Array(text.utf8)
//        
//        let blocks = getBlocks(from: byteArray)
//        return blocks
//    }
//    
//    private func getBlocks(fromCipherText text: String) -> [[UInt8]]? {
//        guard let byteArray = base64ToBytes(text) else { return nil }
//        
//        let blocks = getBlocks(from: byteArray)
//        return blocks
//    }
//    
//    private func getOpenText(from decryptBlocks: [[UInt8]]) -> String? {
////        guard let lastBlock = decryptBlocks.last else { return nil }
//        
////        let validLastBlock: [UInt8] = lastBlock
////            .reversed()
////            .drop(while: { $0 == 0 })
////            .reversed()
////
////        let butes = decryptBlocks.flatMap {
////            return $0 == lastBlock ? validLastBlock : $0
////        }
//        
////        return String(bytes: butes, encoding: .utf8)
//        return String(bytes: decryptBlocks.flatMap { $0 }, encoding: .utf8)
//    }
//    
//    private func getCipherText(from encryptBlocks: [[UInt8]]) -> String {
//        bytesToBase64(encryptBlocks.flatMap { $0 })
//    }
//    
//    private func bytesToBase64(_ bytes: [UInt8]) -> String {
//        Data(bytes).base64EncodedString()
//    }
//    
//    private func base64ToBytes(_ base64String: String) -> [UInt8]? {
//        guard let data = Data(base64Encoded: base64String) else {
//            return nil
//        }
//        return [UInt8](data)
//    }
//}
//
//
//// MARK: - Extensions
//
//extension CrasshopperCipher {
//    enum Mode {
//        case ECB
//    }
//}
//
//extension CrasshopperCipher {
//    typealias SBox = [UInt8]
//}
//
//extension CrasshopperCipher {
//    typealias ConstansForGenerageRoundKey = [[UInt8]]
//}
//
//extension CrasshopperCipher.ConstansForGenerageRoundKey {
//    static func generate() -> Self {
//        (0..<32).map {
//            var block = [UInt8](repeating: 0, count: 16)
//            block[15] = UInt8($0 + 1)
//            return block
//        }
//    }
//}
//
//extension CrasshopperCipher {
//    enum CrasshopperCipherErrors: Error {
//        case canNotEncoding
//    }
//}
//
