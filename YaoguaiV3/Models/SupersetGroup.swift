//
//  SupersetGroup.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 25/11/2024.
//

import Foundation
import SwiftData

protocol SupersetGroupCommon: Observable, AnyObject, Identifiable, PersistentModel, Comparable {
	associatedtype ExerciseType: ExerciseCommon
	
	var order: Int { get set }
	var exercises: [ExerciseType] { get set }
	
	init(order: Int)
}

extension SupersetGroupCommon {
	static func < (lhs: Self, rhs: Self) -> Bool {
		lhs.order < rhs.order
	}
}

enum SingleOrGroup<T: ExerciseCommon, U: SupersetGroupCommon>: Comparable, Identifiable where U.ExerciseType == T {
	case single(T)
	case group(U)
	
	var id: PersistentIdentifier {
		switch self {
		case .single(let item):
			return item.id
		case .group(let group):
			return group.id
		}
	}
	
	var order: Int {
		switch self {
		case .single(let item):
			return item.order
		case .group(let group):
			return group.order
		}
	}
	
	static func < (lhs: SingleOrGroup, rhs: SingleOrGroup) -> Bool {
		lhs.order < rhs.order
	}
}

extension Array where Element: ExerciseCommon, Element.SupersetGroupType.ExerciseType == Element {
	func makeItemsToRender() -> [SingleOrGroup<Element, Element.SupersetGroupType>] {
		var seenGroups = Set<Element.SupersetGroupType>() // Track seen superset groups
		var itemsToRender: [SingleOrGroup<Element, Element.SupersetGroupType>] = []

		for child in self {
			if let group = child.supersetGroup {
				if seenGroups.insert(group).inserted { // Insert into the set, check if it's new
					itemsToRender.append(.group(group))
				}
			} else {
				itemsToRender.append(.single(child))
			}
		}
		
		return itemsToRender.sorted() // Ensure final order by the `order` property
	}
}


@Model class SupersetGroupRecord: SupersetGroupCommon {
	typealias ExerciseType = ExerciseRecord

	var order: Int
	@Relationship(deleteRule: .nullify, inverse: \ExerciseRecord.supersetGroup) var exercises: [ExerciseRecord] = []
	
	required init(order: Int) {
		self.order = order
	}
}

@Model class SupersetGroupTemplate: SupersetGroupCommon {
	typealias ExerciseType = ExerciseTemplate
	
	var order: Int
	@Relationship(deleteRule: .nullify, inverse: \ExerciseTemplate.supersetGroup) var exercises: [ExerciseTemplate] = []
	
	required init(order: Int) {
		self.order = order
	}
}
