protocol BlockCipher {
    func encrypt(_ block: [UInt8]) -> [UInt8]
    func decrypt(_ block: [UInt8]) -> [UInt8]
}
