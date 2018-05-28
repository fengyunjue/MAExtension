/// A generic collection for storing key-value pairs in an ordered manner.
///
/// Same as in a dictionary all keys in the collection are unique and have an associated value.
/// Same as in an array, all key-value pairs (elements) are kept sorted and accessible by
/// a zero-based integer index.
public struct OrderedDictionary<Key: Hashable, Value>: BidirectionalCollection {
    
    // ======================================================= //
    // MARK: - Type Aliases
    // ======================================================= //
    
    /// The type of the key-value pair stored in the ordered dictionary.
    public typealias Element = (key: Key, value: Value)
    
    /// The type of the index.
    public typealias Index = Int
    
    /// The type of the indices collection.
    public typealias Indices = CountableRange<Int>
    
    /// The type of the contiguous subrange of the ordered dictionary's elements.
    ///
    /// - SeeAlso: OrderedDictionarySlice
    public typealias SubSequence = OrderedDictionarySlice<Key, Value>
    
    // ======================================================= //
    // MARK: - Initialization
    // ======================================================= //
    
    /// Creates an empty ordered dictionary.
    public init() {}
    
    /// Creates an ordered dictionary from a sequence of values keyed by a key which gets extracted
    /// from the value in the provided closure.
    ///
    /// - Parameter values: The sequence of values.
    /// - Parameter getKey: The closure which provides a key for the given value from the values
    ///   sequence.
    public init<Values: Sequence>(values: Values, keyedBy getKey: (Value) -> Key) where Values.Element == Value {
        self.init(values.map { (getKey($0), $0) })
    }
    
    /// Creates an ordered dictionary from a sequence of values keyed by a key loaded from the value
    /// at the given key path.
    ///
    /// - Parameter values: The sequence of values.
    /// - Parameter keyPath: The key path for the value to locate its key at.
    public init(values: [Value], keyedBy keyPath: KeyPath<Value, Key>) {
        self.init(values.map { ($0[keyPath: keyPath], $0) })
    }
    
    /// Creates an ordered dictionary from a sequence of key-value pairs.
    ///
    /// - Parameter elements: The key-value pairs that will make up the new ordered dictionary.
    ///   Each key in `elements` must be unique.
    public init<S: Sequence>(_ elements: S) where S.Element == Element {
        for (key, value) in elements {
            precondition(!containsKey(key), "Elements sequence contains duplicate keys")
            self[key] = value
        }
    }
    
    // ======================================================= //
    // MARK: - Ordered Keys & Values
    // ======================================================= //
    
    /// A collection containing just the keys of the ordered dictionary in the correct order.
    public var orderedKeys: LazyMapCollection<OrderedDictionary<Key, Value>, Key> {
        return self.lazy.map { $0.key }
    }
    
    /// A collection containing just the values of the ordered dictionary in the correct order.
    public var orderedValues: LazyMapCollection<OrderedDictionary<Key, Value>, Value> {
        return self.lazy.map { $0.value }
    }
    
    // ======================================================= //
    // MARK: - Dictionary
    // ======================================================= //
    
    /// Converts itself to a common unsorted dictionary.
    public var unorderedDictionary: Dictionary<Key, Value> {
        return _keysToValues
    }
    
    // ======================================================= //
    // MARK: - Key-based Access
    // ======================================================= //
    
    /// Accesses the value associated with the given key for reading and writing.
    ///
    /// This key-based subscript returns the value for the given key if the key is found in the
    /// ordered dictionary, or `nil` if the key is not found.
    ///
    /// When you assign a value for a key and that key already exists, the ordered dictionary
    /// overwrites the existing value and preservers the index of the key-value pair. If the ordered
    /// dictionary does not contain the key, a new key-value pair is appended to the end of the
    /// ordered dictionary.
    ///
    /// If you assign `nil` as the value for the given key, the ordered dictionary removes that key
    /// and its associated value if it exists.
    ///
    /// - Parameter key: The key to find in the ordered dictionary.
    /// - Returns: The value associated with `key` if `key` is in the ordered dictionary; otherwise,
    ///   `nil`.
    public subscript(key: Key) -> Value? {
        get {
            return value(forKey: key)
        }
        set(newValue) {
            if let newValue = newValue {
                updateValue(newValue, forKey: key)
            } else {
                removeValue(forKey: key)
            }
        }
    }
    
    /// Returns a Boolean value indicating whether the ordered dictionary contains the given key.
    ///
    /// - Parameter key: The key to be looked up.
    /// - Returns: `true` if the ordered dictionary contains the given key; otherwise, `false`.
    public func containsKey(_ key: Key) -> Bool {
        return _orderedKeys.contains(key)
    }
    
    /// Returns the value associated with the given key if the key is found in the ordered
    /// dictionary, or `nil` if the key is not found.
    ///
    /// - Parameter key: The key to find in the ordered dictionary.
    /// - Returns: The value associated with `key` if `key` is in the ordered dictionary; otherwise,
    ///   `nil`.
    public func value(forKey key: Key) -> Value? {
        return _keysToValues[key]
    }
    
    /// Updates the value stored in the ordered dictionary for the given key, or appends a new
    /// key-value pair if the key does not exist.
    ///
    /// - Parameter value: The new value to add to the ordered dictionary.
    /// - Parameter key: The key to associate with `value`. If `key` already exists in the ordered
    ///   dictionary, `value` replaces the existing associated value. If `key` is not already a key
    ///   of the ordered dictionary, the `(key, value)` pair is appended at the end of the ordered
    ///   dictionary.
    @discardableResult
    public mutating func updateValue(_ value: Value, forKey key: Key) -> Value? {
        if _orderedKeys.contains(key) {
            let currentValue = _unsafeValue(forKey: key)
            
            _keysToValues[key] = value
            
            return currentValue
        } else {
            _orderedKeys.append(key)
            _keysToValues[key] = value
            
            return nil
        }
    }
    
    /// Removes the given key and its associated value from the ordered dictionary.
    ///
    /// If the key is found in the ordered dictionary, this method returns the key's associated
    /// value. On removal, the indices of the ordered dictionary are invalidated. If the key is
    /// not found in the ordered dictionary, this method returns `nil`.
    ///
    /// - Parameter key: The key to remove along with its associated value.
    /// - Returns: The value that was removed, or `nil` if the key was not present in the
    ///   ordered dictionary.
    ///
    /// - SeeAlso: remove(at:)
    @discardableResult
    public mutating func removeValue(forKey key: Key) -> Value? {
        guard let index = index(forKey: key) else { return nil }
        
        let currentValue = self[index].value
        
        _orderedKeys.remove(at: index)
        _keysToValues[key] = nil
        
        return currentValue
    }
    
    /// Removes all key-value pairs from the ordered dictionary and invalidates all indices.
    ///
    /// - Parameter keepCapacity: Whether the ordered dictionary should keep its underlying storage.
    ///   If you pass `true`, the operation preserves the storage capacity that the collection has,
    ///   otherwise the underlying storage is released. The default is `false`.
    public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
        _orderedKeys.removeAll(keepingCapacity: keepCapacity)
        _keysToValues.removeAll(keepingCapacity: keepCapacity)
    }
    
    private func _unsafeValue(forKey key: Key) -> Value {
        let value = _keysToValues[key]
        precondition(value != nil, "Inconsistency error occured in OrderedDictionary")
        return value!
    }
    
    // ======================================================= //
    // MARK: - Index-based Access
    // ======================================================= //
    
    /// Accesses the key-value pair at the specified position.
    ///
    /// The specified position has to be a valid index of the ordered dictionary. The index-base
    /// subscript returns the key-value pair corresponding to the index.
    ///
    /// - Parameter position: The position of the key-value pair to access. `position` must be
    ///   a valid index of the ordered dictionary and not equal to `endIndex`.
    /// - Returns: A tuple containing the key-value pair corresponding to `position`.
    ///
    /// - SeeAlso: update(:at:)
    public subscript(position: Index) -> Element {
        precondition(indices.contains(position), "OrderedDictionary index is out of range")
        
        let key = _orderedKeys[position]
        let value = _unsafeValue(forKey: key)
        
        return (key, value)
    }
    
    /// Returns the index for the given key.
    ///
    /// - Parameter key: The key to find in the ordered dictionary.
    /// - Returns: The index for `key` and its associated value if `key` is in the ordered
    ///   dictionary; otherwise, `nil`.
    public func index(forKey key: Key) -> Index? {
        return _orderedKeys.index(of: key)
    }
    
    /// Returns the key-value pair at the specified index, or `nil` if there is no key-value pair
    /// at that index.
    ///
    /// - Parameter index: The index of the key-value pair to be looked up. `index` does not have to
    ///   be a valid index.
    /// - Returns: A tuple containing the key-value pair corresponding to `index` if the index is
    ///   valid; otherwise, `nil`.
    public func elementAt(_ index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
    
    /// Checks whether the given key-value pair can be inserted into the ordered dictionary. This
    /// is not the case if the key is already present in the ordered dictionary.
    ///
    /// - Parameter newElement: The key-value pair to be inserted into the ordered dictionary.
    /// - Returns: `true` if the key-value pair can be safely inserted; otherwise, `false`.
    public func canInsert(_ newElement: Element) -> Bool {
        return !containsKey(newElement.key)
    }
    
    /// Inserts a new key-value pair at the specified position.
    ///
    /// If the key of the inserted pair already exists in the ordered dictionary, a runtime error
    /// is triggered. Use `canInsert(_:)` for performing a check first, so that this method can
    /// be executed safely.
    ///
    /// - Parameter newElement: The new key-value pair to insert into the ordered dictionary. The
    ///   key contained in the pair must not be already present in the ordered dictionary.
    /// - Parameter index: The position at which to insert the new key-value pair. `index` must be
    ///   a valid index of the ordered dictionary or equal to `endIndex` property.
    ///
    /// - SeeAlso: canInsert(_:)
    /// - SeeAlso: update(:at:)
    public mutating func insert(_ newElement: Element, at index: Index) {
        precondition(index >= startIndex, "Negative OrderedDictionary index is out of range")
        precondition(index <= endIndex, "OrderedDictionary index is out of range")
        precondition(canInsert(newElement), "Cannot insert duplicate key in OrderedDictionary")
        
        let (key, value) = newElement
        
        _orderedKeys.insert(key, at: index)
        _keysToValues[key] = value
    }
    
    /// Checks whether the key-value pair at the given index can be updated with the given key-value
    /// pair. This is not the case if the key of the updated element is already present in the
    /// ordered dictionary and located at another index than the updated one.
    ///
    /// Although this is a checking method, a valid index has to be provided.
    ///
    /// - Parameter newElement: The key-value pair to be set at the specified position.
    /// - Parameter index: The position at which to set the key-value pair. `index` must be a valid
    ///   index of the ordered dictionary.
    public func canUpdate(_ newElement: Element, at index: Index) -> Bool {
        var keyPresentAtIndex = false
        return _canUpdate(newElement, at: index, keyPresentAtIndex: &keyPresentAtIndex)
    }
    
    /// Updates the key-value pair located at the specified position.
    ///
    /// If the key of the updated pair already exists in the ordered dictionary *and* is located at
    /// a different position than the specified one, a runtime error is triggered. Use
    /// `canUpdate(_:at:)` for performing a check first, so that this method can be executed safely.
    ///
    /// - Parameter newElement: The key-value pair to be set at the specified position.
    /// - Parameter index: The position at which to set the key-value pair. `index` must be a valid
    ///   index of the ordered dictionary.
    ///
    /// - SeeAlso: canUpdate(_:at:)
    /// - SeeAlso: insert(:at:)
    @discardableResult
    public mutating func update(_ newElement: Element, at index: Index) -> Element? {
        // Store the flag indicating whether the key of the inserted element
        // is present at the updated index
        var keyPresentAtIndex = false
        
        precondition(
            _canUpdate(newElement, at: index, keyPresentAtIndex: &keyPresentAtIndex),
            "OrderedDictionary update duplicates key"
        )
        
        // Decompose the element
        let (key, value) = newElement
        
        // Load the current element at the index
        let replacedElement = self[index]
        
        // If its key differs, remove its associated value
        if (!keyPresentAtIndex) {
            _keysToValues.removeValue(forKey: replacedElement.key)
        }
        
        // Store the new position of the key and the new value associated with the key
        _orderedKeys[index] = key
        _keysToValues[key] = value
        
        return replacedElement
    }
    
    /// Removes and returns the key-value pair at the specified position if there is any key-value
    /// pair, or `nil` if there is none.
    ///
    /// - Parameter index: The position of the key-value pair to remove.
    /// - Returns: The element at the specified index, or `nil` if the position is not taken.
    ///
    /// - SeeAlso: removeValue(forKey:)
    @discardableResult
    public mutating func remove(at index: Index) -> Element? {
        guard let element = elementAt(index) else { return nil }
        
        _orderedKeys.remove(at: index)
        _keysToValues.removeValue(forKey: element.key)
        
        return element
    }
    
    private func _canUpdate(_ newElement: Element, at index: Index, keyPresentAtIndex: inout Bool) -> Bool {
        precondition(indices.contains(index), "OrderedDictionary index is out of range")
        
        let currentIndexOfKey = self.index(forKey: newElement.key)
        
        let keyNotPresent = currentIndexOfKey == nil
        keyPresentAtIndex = currentIndexOfKey == index
        
        return keyNotPresent || keyPresentAtIndex
    }
    
    // ======================================================= //
    // MARK: - Sorting
    // ======================================================= //
    
    /// Sorts the ordered dictionary in place, using the given predicate as the comparison between
    /// elements.
    ///
    /// The predicate must be a *strict weak ordering* over the elements.
    ///
    /// - Parameter areInIncreasingOrder: A predicate that returns `true` if its first argument
    ///   should be ordered before its second argument; otherwise, `false`.
    ///
    /// - SeeAlso: MutableCollection.sort(by:), sorted(by:)
    public mutating func sort(by areInIncreasingOrder: (Element, Element) -> Bool) {
        _orderedKeys = _sortedElements(by: areInIncreasingOrder).map { $0.key }
    }
    
    /// Returns a new ordered dictionary, sorted using the given predicate as the comparison between
    /// elements.
    ///
    /// The predicate must be a *strict weak ordering* over the elements.
    ///
    /// - Parameter areInIncreasingOrder: A predicate that returns `true` if its first argument
    ///   should be ordered before its second argument; otherwise, `false`.
    /// - Returns: A new ordered dictionary sorted according to the predicate.
    ///
    /// - SeeAlso: MutableCollection.sorted(by:), sort(by:)
    /// - MutatingVariant: sort
    public func sorted(by areInIncreasingOrder: (Element, Element) -> Bool) -> OrderedDictionary<Key, Value> {
        return OrderedDictionary(_sortedElements(by: areInIncreasingOrder))
    }
    
    private func _sortedElements(by areInIncreasingOrder: (Element, Element) -> Bool) -> [Element] {
        return sorted(by: areInIncreasingOrder)
    }
    
    // ======================================================= //
    // MARK: - Slices
    // ======================================================= //
    
    /// Accesses a contiguous subrange of the ordered dictionary.
    ///
    /// - Parameter bounds: A range of the ordered dictionary's indices. The bounds of the range
    ///   must be valid indices of the ordered dictionary.
    /// - Returns: The slice view at the ordered dictionary in the specified subrange.
    public subscript(bounds: Range<Index>) -> SubSequence {
        return OrderedDictionarySlice(base: self, bounds: bounds)
    }
    
    // ======================================================= //
    // MARK: - Indices
    // ======================================================= //
    
    /// The indices that are valid for subscripting the ordered dictionary.
    public var indices: Indices {
        return _orderedKeys.indices
    }
    
    /// The position of the first key-value pair in a non-empty ordered dictionary.
    public var startIndex: Index {
        return _orderedKeys.startIndex
    }
    
    /// The position which is one greater than the position of the last valid key-value pair in the
    /// ordered dictionary.
    public var endIndex: Index {
        return _orderedKeys.endIndex
    }
    
    /// Returns the position immediately after the given index.
    public func index(after i: Index) -> Index {
        return _orderedKeys.index(after: i)
    }
    
    /// Returns the position immediately before the given index.
    public func index(before i: Index) -> Index {
        return _orderedKeys.index(before: i)
    }
    
    // ======================================================= //
    // MARK: - Internal Storage
    // ======================================================= //
    
    /// The backing storage for the ordered keys.
    fileprivate var _orderedKeys = [Key]()
    
    /// The backing storage for the mapping of keys to values.
    fileprivate var _keysToValues = [Key: Value]()
    
}

// ======================================================= //
// MARK: - Literals
// ======================================================= //

extension OrderedDictionary: ExpressibleByArrayLiteral {
    
    /// Creates an ordered dictionary initialized from an array literal containing a list of
    /// key-value pairs.
    public init(arrayLiteral elements: Element...) {
        self.init(elements)
    }
    
}

extension OrderedDictionary: ExpressibleByDictionaryLiteral {
    
    /// Creates an ordered dictionary initialized from a dictionary literal.
    public init(dictionaryLiteral elements: (Key, Value)...) {
        self.init(elements.map { element in
            let (key, value) = element
            return (key: key, value: value)
        })
    }
    
}

// ======================================================= //
// MARK: - Equatable Conformance
// ======================================================= //

extension OrderedDictionary /* : Equatable */ where Value: Equatable {
    
    /// Returns a Boolean value that indicates whether the two given ordered dictionaries with
    /// equatable values are equal.
    public static func == (lhs: OrderedDictionary, rhs: OrderedDictionary) -> Bool {
        return lhs._orderedKeys == rhs._orderedKeys
            && lhs._keysToValues == rhs._keysToValues
    }
    
}




extension OrderedDictionary: Encodable /* where Key: Encodable, Value: Encodable */ {
    
    /// __inheritdoc__
    public func encode(to encoder: Encoder) throws {
        assertTypeIsEncodable(Key.self, in: type(of: self))
        assertTypeIsEncodable(Value.self, in: type(of: self))
        
        var container = encoder.unkeyedContainer()
        
        for (key, value) in self {
            // Using the magic desribed here:
            // https://github.com/apple/swift/blob/master/stdlib/public/core/Codable.swift#L4114-L4116
            let keyEncoder = container.superEncoder()
            try (key as! Encodable).encode(to: keyEncoder)
            
            let valueEncoder = container.superEncoder()
            try (value as! Encodable).encode(to: valueEncoder)
        }
    }
    
    /// This assertion is used for checking the conformance to `Encodable` of `Key` and `Value`
    /// types in `OrderedDictionary`. This workaround is necessary due to the limitation of missing
    /// conditional protocol conformance in Swift.
    ///
    /// The code is take from the Swift repository:
    /// https://github.com/apple/swift/blob/master/stdlib/public/core/Codable.swift#L3963-L3981
    private func assertTypeIsEncodable<T>(_ type: T.Type, in wrappingType: Any.Type) {
        guard T.self is Encodable.Type else {
            if T.self == Encodable.self || T.self == Codable.self {
                preconditionFailure("\(wrappingType) does not conform to Encodable because Encodable does not conform to itself. You must use a concrete type to encode or decode.")
            } else {
                preconditionFailure("\(wrappingType) does not conform to Encodable because \(T.self) does not conform to Encodable.")
            }
        }
    }
    
}

extension OrderedDictionary: Decodable /* where Key: Decodable, Value: Decodable */ {
    
    /// __inheritdoc__
    public init(from decoder: Decoder) throws {
        self.init()
        
        assertTypeIsDecodable(Key.self, in: type(of: self))
        assertTypeIsDecodable(Value.self, in: type(of: self))
        
        var container = try decoder.unkeyedContainer()
        
        let keyMetaType = (Key.self as! Decodable.Type)
        let valueMetaType = (Value.self as! Decodable.Type)
        
        while !container.isAtEnd {
            // Using the magic desribed here:
            // https://github.com/apple/swift/blob/master/stdlib/public/core/Codable.swift#L4181-L4184
            let keyDecoder = try container.superDecoder()
            let key = try keyMetaType.init(from: keyDecoder) as! Key
            
            guard !container.isAtEnd else {
                let error = DecodingError.Context(codingPath: decoder.codingPath,
                                                  debugDescription: "Unkeyed container reached end before value in key-value pair.")
                throw DecodingError.dataCorrupted(error)
            }
            
            let valueDecoder = try container.superDecoder()
            let value = try valueMetaType.init(from: valueDecoder) as! Value
            
            self[key] = value
        }
    }
    
    /// This assertion is used for checking the conformance to `Decodable` of `Key` and `Value`
    /// types in `OrderedDictionary`. This workaround is necessary due to the limitation of missing
    /// conditional protocol conformance in Swift.
    ///
    /// The code is take from the Swift repository:
    /// https://github.com/apple/swift/blob/master/stdlib/public/core/Codable.swift#L3963-L3981
    private func assertTypeIsDecodable<T>(_ type: T.Type, in wrappingType: Any.Type) {
        guard T.self is Decodable.Type else {
            if T.self == Decodable.self || T.self == Codable.self {
                preconditionFailure("\(wrappingType) does not conform to Decodable because Decodable does not conform to itself. You must use a concrete type to encode or decode.")
            } else {
                preconditionFailure("\(wrappingType) does not conform to Decodable because \(T.self) does not conform to Decodable.")
            }
        }
    }
    
}



extension OrderedDictionary: CustomStringConvertible {
    
    /// A textual representation of the ordered dictionary.
    public var description: String {
        return makeDescription(debug: false)
    }
    
}

extension OrderedDictionary: CustomDebugStringConvertible {
    
    /// A textual representation of the ordered dictionary, suitable for debugging.
    public var debugDescription: String {
        return makeDescription(debug: true)
    }
    
}

extension OrderedDictionary {
    
    fileprivate func makeDescription(debug: Bool) -> String {
        // The implementation of the description is inspired by zwaldowski's implementation of the
        // ordered dictionary. See http://bit.ly/2iqGhrb
        
        if isEmpty { return "[:]" }
        
        let printFunction: (Any, inout String) -> () = {
            if debug {
                return { debugPrint($0, separator: "", terminator: "", to: &$1) }
            } else {
                return { print($0, separator: "", terminator: "", to: &$1) }
            }
        }()
        
        let descriptionForItem: (Any) -> String = { item in
            var description = ""
            printFunction(item, &description)
            return description
        }
        
        let bodyComponents = map { element in
            return descriptionForItem(element.key) + ": " + descriptionForItem(element.value)
        }
        
        let body = bodyComponents.joined(separator: ", ")
        
        return "[\(body)]"
    }
    
}

/// A view into an ordered dictionary.
///
/// - SeeAlso: OrderedDictionary
/// - SeeAlso: BidirectionalSlice
public struct OrderedDictionarySlice<Key: Hashable, Value>: BidirectionalCollection {
    
    // ======================================================= //
    // MARK: - Type Aliases
    // ======================================================= //
    
    /// The type of the base ordered dictionary.
    public typealias Base = OrderedDictionary<Key, Value>
    
    /// The type of the elements of the base ordered dictionary.
    public typealias Element = Base.Element
    
    /// The type of a single index of the base ordered dictionary.
    public typealias Index = Base.Index
    
    /// The type of the indices collection of the slice.
    public typealias Indices = Slice<Base>.Indices
    
    /// The type of the contiguous subrange of the ordered dictionary's slice.
    public typealias SubSequence = OrderedDictionarySlice<Key, Value>
    
    // ======================================================= //
    // MARK: - Initialization
    // ======================================================= //
    
    /// Initializes the view into the given ordered dictionary that allows access to elements within
    /// the given range.
    ///
    /// - Parameter base: The ordered dictionary to create a view into.
    /// - Parameter bounds: The range of indices to allow access to in the new slice.
    internal init(base: Base, bounds: Range<Index>) {
        self._slice = Slice(base: base, bounds: bounds)
    }
    
    // ======================================================= //
    // MARK: - BidirectionalCollection Conformance
    // ======================================================= //
    
    /// Accesses the key-value pair at the specified position.
    public subscript(position: Index) -> Element {
        return _slice[position]
    }
    
    /// The indices that are valid for subscripting the ordered dictionary slice.
    public var indices: Indices {
        return _slice.indices
    }
    
    /// The position of the first key-value pair in the ordered dictionary slice.
    public var startIndex: Index {
        return _slice.startIndex
    }
    
    /// The position which is one greater than the position of the last valid key-value pair in the
    /// ordered dictionary slice.
    public var endIndex: Index {
        return _slice.endIndex
    }
    
    /// Returns the position immediately after the given index.
    public func index(after i: Index) -> Index {
        return _slice.index(after: i)
    }
    
    /// Returns the position immediately before the given index.
    public func index(before i: Index) -> Index {
        return _slice.index(before: i)
    }
    
    // ======================================================= //
    // MARK: - Internal Storage
    // ======================================================= //
    
    /// The underlying slice value.
    private var _slice: Slice<Base>
    
}


extension OrderedDictionary {
    public var allKey: [Key] {
       return self.map { (key, _) -> Key in
            return key
        }
    }
    public var allValue: [Value] {
        return self.map({ (_, value) -> Value in
            return value
        })
    }
}
