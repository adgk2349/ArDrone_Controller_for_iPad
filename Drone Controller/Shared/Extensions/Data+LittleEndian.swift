import Foundation

extension Data {
    func uint16LE(at offset: Int) -> UInt16? {
        guard count >= offset + 2 else { return nil }
        return UInt16(self[offset]) | (UInt16(self[offset + 1]) << 8)
    }

    func int16LE(at offset: Int) -> Int16? {
        guard let value = uint16LE(at: offset) else { return nil }
        return Int16(bitPattern: value)
    }

    func uint32LE(at offset: Int) -> UInt32? {
        guard count >= offset + 4 else { return nil }
        let byte0 = UInt32(self[offset])
        let byte1 = UInt32(self[offset + 1]) << 8
        let byte2 = UInt32(self[offset + 2]) << 16
        let byte3 = UInt32(self[offset + 3]) << 24
        return byte0 | byte1 | byte2 | byte3
    }
}
