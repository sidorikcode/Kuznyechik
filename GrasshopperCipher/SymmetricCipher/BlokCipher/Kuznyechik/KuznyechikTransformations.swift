enum KuznyechikTransformations {
    // MARK: - Main ransformations
    
    /// `X[k](a)`
    static func X(_ lhs: [UInt8], _ rhs: [UInt8]) -> [UInt8] {
        zip(lhs, rhs).map { $0 ^ $1 }
    }
    
    /// Substitution function using an S-box.
    static func S(_ butes: [UInt8], sBox: [UInt8]) -> [UInt8] {
        butes.map { sBox[Int($0)] }
    }

    /// Inverse substitution function using an S-box.
    static func revertS(_ butes: [UInt8], sBoxRevert: [UInt8]) -> [UInt8] {
        butes.map { sBoxRevert[Int($0)] }
    }
    
    /// Multiplication function in the Galois Field `(GF(2^8))`
    static func galoisMultiply(_ a: UInt8, _ b: UInt8) -> UInt8 {
        var result: UInt8 = 0
        var x = a
        var y = b
        while y > 0 {
            if y & 1 == 1 {
                result ^= x
            }
            
            x = x & 0x80 == 0
            ? x << 1
            : UInt8((UInt16(x) << 1) ^ 0x1C3)
            
            y >>= 1
        }
        return result
    }
    
    /// Linear transformation function `l: V8^16 → V8`
    static func l(_ block: [UInt8]) -> UInt8 {
        let coefficients: [UInt8] = [148, 32, 133, 16, 194, 192, 1, 251, 1, 192, 194, 16, 133, 32, 148, 1] // Коэффициенты из ГОСТ (константы для линейной комбинации)

        var result: UInt8 = 0

        for (i, byte) in block.enumerated() {
            let multiplied = galoisMultiply(byte, coefficients[i])
            result ^= multiplied
        }

        return result
    }
    
    static func R(_ block: [UInt8]) -> [UInt8] {
        [l(block)] + block.dropLast()
    }
    
    static func revertR(_ block: [UInt8]) -> [UInt8] {
        let blockForLinearT: [UInt8] = block.dropFirst() + [block[0]]
        
        return block.dropFirst() + [l(blockForLinearT)]
    }
    
    static func L(_ block: [UInt8]) -> [UInt8] {
        var result = block
        (0..<16).forEach { _ in
            result = R(result)
        }
        return result
    }

    static func revertL(_ block: [UInt8]) -> [UInt8] {
        var result = block
        (0..<16).forEach { _ in
            result = revertR(result)
        }
        return result
    }
    
    // MARK: - Generate round key
    
    static func F(k constant: [UInt8], keys: (a1: [UInt8], a0: [UInt8]), sBox: [UInt8]) -> ([UInt8], [UInt8]) {
        let resultX = X(constant, keys.a1)
        let resultS = S(resultX, sBox: sBox)
        let resutL = L(resultS)
        
        return (X(resutL, keys.a0), keys.a1)
    }
    
    static func generateRoundKey(masterKey: [UInt8], sBox: [UInt8]) -> [[UInt8]] {
        let constansForGenerageRoundKey = {
            (0..<32).map {
                var block = [UInt8](repeating: 0, count: 16)
                block[15] = UInt8($0 + 1)
                return block
            }
        }()
        
        var keys: [[UInt8]] = []

        keys.append(Array(masterKey.prefix(16)))
        keys.append(Array(masterKey.suffix(16)))

        for i in 0...3 {
            let upperBound = (8 * i) + 7
            let lowerBound = (8 * i)
            
            let a1 = keys[2 * i]
            let a0 = keys[(2 * i) + 1]

            var iKeys = (a1, a0)
            
            (lowerBound...upperBound).reversed().enumerated().forEach {
                iKeys = F(k: constansForGenerageRoundKey[$1], keys: iKeys, sBox: sBox)
            }
            
            keys.append(contentsOf: [iKeys.0, iKeys.1])
        }
        
        return keys
    }
}
