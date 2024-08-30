// Copyright © Fleuronic LLC. All rights reserved.

import enum Dewdrop.ItemType
import struct Dewdrop.Raindrop
import struct Dewdrop.Collection
import struct Dewdrop.Tag
import struct DewdropService.IdentifiedRaindrop
import struct DewdropService.RaindropDetailsFields
import struct DewdropService.TagNameFields
import struct Catena.IDFields
import struct Foundation.URL
import protocol DewdropService.RaindropFields

struct RaindropCreationFields: RaindropFields {
	let id: Raindrop.ID
	let url: URL
	let title: String
	let itemType: ItemType
}

// MARK: -
extension RaindropCreationFields: Decodable {
	init(from decoder: Decoder) throws {
		let raindropContainer = try decoder.container(keyedBy: Raindrop.CodingKeys.self)
		let detailsContainer = try decoder.container(keyedBy: RaindropDetailsFields.CodingKeys.self)

		try self.init(
			id: detailsContainer.decode(for: .id),
			url: raindropContainer.decode(for: .url),
			title: raindropContainer.decode(for: .title),
			itemType: raindropContainer.decode(for: .itemType)
		)
	}
}
