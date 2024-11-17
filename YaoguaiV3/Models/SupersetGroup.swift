//
//  SupersetGroup.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 17/11/2024.
//

import Foundation

struct SupersetGroup: Identifiable, Codable {
	var id = UUID()
	var endTimer: TimeInterval? // optionally, the timer that runs at the end of the group
}
