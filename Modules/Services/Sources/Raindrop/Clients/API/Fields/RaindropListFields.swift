// Copyright © Fleuronic LLC. All rights reserved.

import enum Dewdrop.ItemType
import struct Dewdrop.Raindrop
import struct Dewdrop.Collection
import struct DewdropService.IdentifiedRaindrop
import struct DewdropService.RaindropDetailsFields
import struct Catena.IDFields
import struct Foundation.URL
import protocol DewdropService.RaindropFields

public struct RaindropListFields: RaindropFields {
	public let id: Raindrop.ID
	public let url: URL
	public let title: String
	public let itemType: ItemType
	public let isFavorite: Bool
	public let isBroken: Bool
	public let collection: IDFields<Collection.Identified>?
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
			isFavorite: raindropContainer.decodeIfPresent(for: .isFavorite) ?? false,
			isBroken: raindropContainer.decodeIfPresent(for: .isBroken) ?? false,
			collection: detailsContainer.decodeIfPresent(for: .collection)
		)
	}
}
