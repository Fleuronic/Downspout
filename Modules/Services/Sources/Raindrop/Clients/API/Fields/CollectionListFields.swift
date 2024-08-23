// Copyright © Fleuronic LLC. All rights reserved.

import struct Dewdrop.Raindrop
import struct Dewdrop.Collection
import struct DewdropService.IdentifiedCollection
import struct Catena.IDFields
import struct Foundation.URL
import struct DewdropService.CollectionDetailsFields
import protocol DewdropService.CollectionFields

struct CollectionListFields: CollectionFields {
	let id: Collection.ID
	let title: String
	let count: Int
	let isShared: Bool
	let sortIndex: Int
	let parent: IDFields<Collection.Identified>?
}

// MARK: -
extension CollectionListFields: Decodable {
	init(from decoder: Decoder) throws {
		let collectionContainer = try decoder.container(keyedBy: Collection.CodingKeys.self)
		let detailsContainer = try decoder.container(keyedBy: CollectionDetailsFields.CodingKeys.self)

		try self.init(
			id: detailsContainer.decode(for: .id),
			title: collectionContainer.decode(for: .title),
			count: collectionContainer.decode(for: .count),
			isShared: collectionContainer.contains(.isShared),
			sortIndex: collectionContainer.decode(for: .sortIndex) ?? 0,
			parent: detailsContainer.decodeIfPresent(for: .parent)
		)
	}
}
