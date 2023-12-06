
import Foundation

let META_START = "%vreetmeter_meta_start%"
let META_END = "%vreetmeter_meta_end%"
let META_PATTERN = /%vreetmeter_meta_start%(.+)%vreetmeter_meta_end%/

func decodeVreetmeterMeta<T: Decodable>(input: String) throws -> T? {
    let match = input.firstMatch(of: META_PATTERN)
    
    if (match == nil) { return nil }
    
    return try JSONDecoder().decode(T.self, from: (match!.output.1).data(using: .utf8)!)
}

func encodeVreetmeterMeta<T: Encodable>(input: T) throws -> String {
    let encoded = try JSONEncoder().encode(input)
    return META_START + String(decoding: encoded, as: UTF8.self) + META_END
}
