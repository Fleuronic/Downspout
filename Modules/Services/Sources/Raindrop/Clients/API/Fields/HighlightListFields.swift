// Copyright © Fleuronic LLC. All rights reserved.

import struct Dewdrop.Highlight
import struct Dewdrop.Raindrop
import struct DewdropService.IdentifiedHighlight
import struct DewdropService.HighlightInRaindropFields
import struct Catena.IDFields
import protocol DewdropService.HighlightFields

struct HighlightListFields: HighlightFields {
	let id: Highlight.ID
}

// MARK: -
extension HighlightListFields: Decodable {
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: HighlightInRaindropFields.CodingKeys.self)
		try self.init(id: container.decode(for: .id))
	}
}
