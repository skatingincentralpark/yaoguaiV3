//
//  Alert.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 7/10/2024.
//

import Foundation
import SwiftUI

enum AlertType {
	case success
	case warning
	case error
	case info
	
	var backgroundColor: Color {
		switch self {
		case .success: return Color.green.opacity(0.8)
		case .warning: return Color.yellow.opacity(0.8)
		case .error: return Color.red.opacity(0.8)
		case .info: return Color.blue.opacity(0.8)
		}
	}
	
	var icon: String {
		switch self {
		case .success: return "checkmark.circle.fill"
		case .warning: return "exclamationmark.triangle.fill"
		case .error: return "xmark.octagon.fill"
		case .info: return "info.circle.fill"
		}
	}
	
	var emoji: String {
		switch self {
		case .success: return "✅"
		case .warning: return "⚠️"
		case .error: return "❌"
		case .info: return "ℹ️"
		}
	}
}

struct Alert: Identifiable {
	var id: UUID = UUID()
	var message: String
	var type: AlertType
}

@Observable @MainActor
class AlertManager {
	static let shared = AlertManager()
	private(set) var alerts: [Alert] = []
	
	func addAlert(_ message: String, type: AlertType, file: String = #file, function: String = #function, line: Int = #line) {
		print("\(type.emoji) \(message).  Called from \(function) \(readablePath(from: file)):\(line)")
		let newAlert = Alert(message: message, type: type)
		alerts.append(newAlert)
		
		DispatchQueue.main.asyncAfter(deadline: .now() + (2)) {
			withAnimation {
				self.removeAlert(newAlert)
			}
		}
	}
	
	func removeAlert(_ alert: Alert) {
		alerts.removeAll { $0.id == alert.id } // Remove alert using its ID
	}
	
	private init() {}
}

func readablePath(from fullPath: String) -> String {
	// Define the project folder name (e.g., "YaoguaiV3")
	let projectFolder = "YaoguaiV3"
	
	// Split the path by the project folder name and rejoin starting from the second occurrence
	let components = fullPath.components(separatedBy: projectFolder)
	
	// Ensure we have at least two components and return the desired part
	if components.count > 2 {
		return projectFolder + components[2] // Rebuild path from second occurrence
	} else if components.count == 2 {
		return projectFolder + components[1]
	}
	
	// Fallback: Return the full path if we don't find the project name
	return fullPath
}

public func track(_ message: String, file: String = #file, function: String = #function, line: Int = #line ) {
	print("\(message).  Called from \(function) \(readablePath(from: file)):\(line)")
}
