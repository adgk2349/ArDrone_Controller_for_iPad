import Foundation

final class MSPDecoder {
    private var buffer = Data()

    func append(_ incoming: Data) -> [MSPPacket] {
        buffer.append(incoming)

        var packets: [MSPPacket] = []

        while buffer.count >= 6 {
            guard let startIndex = buffer.firstIndex(of: 0x24) else {
                buffer.removeAll()
                break
            }

            if startIndex > 0 {
                buffer.removeSubrange(0..<startIndex)
            }

            guard buffer.count >= 6 else { break }
            guard buffer[1] == 0x4D else {
                buffer.removeFirst()
                continue
            }

            guard let direction = MSPPacket.Direction(byte: buffer[2]) else {
                buffer.removeFirst()
                continue
            }

            let payloadSize = Int(buffer[3])
            let packetLength = payloadSize + 6
            guard buffer.count >= packetLength else { break }

            let command = buffer[4]
            let payload = buffer.subdata(in: 5..<(5 + payloadSize))
            let checksum = buffer[5 + payloadSize]

            var computedChecksum = buffer[3] ^ command
            for byte in payload {
                computedChecksum ^= byte
            }

            if checksum == computedChecksum {
                packets.append(MSPPacket(command: command, payload: payload, direction: direction))
                buffer.removeSubrange(0..<packetLength)
            } else {
                buffer.removeFirst()
            }
        }

        return packets
    }
}
