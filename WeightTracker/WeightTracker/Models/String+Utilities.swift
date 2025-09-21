import Foundation

extension String {
    func nilIfEmpty() -> String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}

extension Optional where Wrapped == String {
    func nilIfEmpty() -> String? {
        switch self {
        case .some(let value):
            return value.nilIfEmpty()
        case .none:
            return nil
        }
    }
}
