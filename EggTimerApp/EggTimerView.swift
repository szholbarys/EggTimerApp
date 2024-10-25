//
//  EggTimerView.swift
//  EggTimerApp
//
//  Created by Zholbarys on 25.10.2024.
//

import SwiftUI

struct EggTimerView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> EggTimerViewController {
        return EggTimerViewController()
    }
    
    func updateUIViewController(_ uiViewController: EggTimerViewController, context: Context) {
        // Update the view controller if needed
    }
}
