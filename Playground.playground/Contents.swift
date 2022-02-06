import Foundation

func djb2(_ key: String, _ inputHash: Int32 = 5381) -> Int32 {
    let scalarStrings = key.unicodeScalars.map { $0.value }
    let value = scalarStrings.reversed().reduce(inputHash) {
        ($0 << 5) &+ $0 &+ Int32($1)
    }
    return value
}

print(djb2("__len:31"))
