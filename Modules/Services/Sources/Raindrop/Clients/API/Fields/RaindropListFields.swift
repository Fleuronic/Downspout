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

public struct RaindropListFields: RaindropFields {
	public let id: Raindrop.ID
	public let url: URL
	public let title: String
	public let itemType: ItemType
	public let collection: IDFields<Collection.Identified>?
	public let tags: [TagNameFields]
	public let highlights: [HighlightListFields]?
	public let isFavorite: Bool
	public let isBroken: Bool
}

// MARK: -
extension RaindropListFields: Decodable {
	public init(from decoder: Decoder) throws {
		let raindropContainer = try decoder.container(keyedBy: Raindrop.CodingKeys.self)
		let detailsContainer = try decoder.container(keyedBy: RaindropDetailsFields.CodingKeys.self)
		
		try self.init(
			id: detailsContainer.decode(for: .id),
			url: raindropContainer.decode(for: .url),
			title: raindropContainer.decode(for: .title),
			itemType: raindropContainer.decode(for: .itemType),
			collection: detailsContainer.decodeIfPresent(for: .collection),
			tags: detailsContainer.decode(for: .tags),
			highlights: detailsContainer.decodeIfPresent(for: .highlights),
			isFavorite: raindropContainer.decodeIfPresent(for: .isFavorite) ?? false,
			isBroken: raindropContainer.decodeIfPresent(for: .isBroken) ?? false
		)
	}
}
