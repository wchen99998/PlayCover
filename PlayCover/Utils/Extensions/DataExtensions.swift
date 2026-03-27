//
//  DataExtensions.swift
//  PlayCover
//

import Foundation

// swiftlint:disable force_unwrapping
extension String {
    init(data: Data, offset: Int, commandSize: Int, loadCommandString: lc_str) {
        let loadCommandStringOffset = Int(loadCommandString.offset)
        let stringOffset = offset + loadCommandStringOffset
        let commandEnd = offset + commandSize

        guard loadCommandStringOffset > 0,
              stringOffset >= data.startIndex,
              stringOffset <= commandEnd,
              commandEnd <= data.endIndex else {
            self = ""
            return
        }

        let rawStringData = data[stringOffset..<commandEnd].prefix { $0 != 0 }
        self = String(decoding: rawStringData, as: UTF8.self)
            .trimmingCharacters(in: .controlCharacters)
    }
}

extension Data {
    func extract<T>(_ type: T.Type, offset: Int = 0,
                    swap: ((UnsafeMutablePointer<T>, NXByteOrder) -> Void)? = nil) -> T {
        let data = self[offset..<offset + MemoryLayout<T>.size]
        var result = data.withUnsafeBytes { dataBytes in
            dataBytes.baseAddress!
                .assumingMemoryBound(to: UInt8.self)
                .withMemoryRebound(to: T.self, capacity: 1) { (pointer) -> T in
                return pointer.pointee
            }
        }
        swap?(&result, NXHostByteOrder())
        return result
    }
}
// swiftlint:enable force_unwrapping
