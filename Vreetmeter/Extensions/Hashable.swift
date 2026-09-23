extension Hashable where Self: AnyObject {
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
    
extension Equatable where Self: AnyObject {
    static func == (lhs:Self, rhs:Self) -> Bool {
        return lhs === rhs
    }
}
