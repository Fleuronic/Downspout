// Copyright © Fleuronic LLC. All rights reserved.

import struct Dewdrop.Raindrop
import struct Dewdrop.Collection
import struct DewdropService.IdentifiedCollection
import struct Catena.IDFields
import struct Foundation.URL
import struct DewdropService.CollectionDetailsFields
import protocol DewdropService.CollectionFields

public struct CollectionListFields: CollectionFields {
	public let id: Collection.ID
	public let title: String
	public let count: Int
	public let isShared: Bool
	public let sortIndex: Int
	public let parent: IDFields<Collection.Identified>?
}

// MARK: -
extension CollectionListFields: Decodable {
	public init(from decoder: Decoder) throws {
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
