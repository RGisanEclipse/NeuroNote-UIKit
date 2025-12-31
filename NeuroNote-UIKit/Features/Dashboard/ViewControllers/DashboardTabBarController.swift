//
//  DashboardTabBarController.swift
//  NeuroNote-UIKit
//
//  Created by Eclipse on 31/12/25.
//

import UIKit

class DashboardTabBarController: UITabBarController {
    
    // MARK: - Tabs
    
    enum Tab: Int, CaseIterable {
        case home = 0
        case journal
        case insights
        case profile
        
        var title: String {
            switch self {
            case .home: return "Home"
            case .journal: return "Journal"
            case .insights: return "Insights"
            case .profile: return "Profile"
            }
        }
        
        var iconName: String {
            switch self {
            case .home: return "house.fill"
            case .journal: return "book.fill"
            case .insights: return "chart.bar.fill"
            case .profile: return "person.fill"
            }
        }
        
        var selectedIconName: String {
            switch self {
            case .home: return "house.fill"
            case .journal: return "book.closed.fill"
            case .insights: return "chart.bar.xaxis.ascending"
            case .profile: return "person.crop.circle.fill"
            }
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        configureTabBarAppearance()
    }
    
    // MARK: - Setup
    
    private func setupTabs() {
        let homeVC = HomeViewController()
        let journalVC = createPlaceholderVC(for: .journal)
        let insightsVC = createPlaceholderVC(for: .insights)
        let profileVC = createPlaceholderVC(for: .profile)
        
        // Configure tab bar items
        homeVC.tabBarItem = createTabBarItem(for: .home)
        journalVC.tabBarItem = createTabBarItem(for: .journal)
        insightsVC.tabBarItem = createTabBarItem(for: .insights)
        profileVC.tabBarItem = createTabBarItem(for: .profile)
        
        viewControllers = [homeVC, journalVC, insightsVC, profileVC]
    }
    
    private func createTabBarItem(for tab: Tab) -> UITabBarItem {
        let item = UITabBarItem(
            title: tab.title,
            image: UIImage(systemName: tab.iconName),
            selectedImage: UIImage(systemName: tab.selectedIconName)
        )
        item.tag = tab.rawValue
        return item
    }
    
    private func createPlaceholderVC(for tab: Tab) -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .systemBackground
        
        let label = UILabel()
        label.text = "\(tab.title) Coming Soon"
        label.font = UIFont(name: Fonts.MontserratMedium, size: 20) ?? .systemFont(ofSize: 20, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        
        vc.view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])
        
        return vc
    }
    
    private func configureTabBarAppearance() {
        tabBar.isTranslucent = true
        
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemThinMaterial)
        
        let itemAppearance = UITabBarItemAppearance()
        
        itemAppearance.normal.iconColor = .secondaryLabel
        itemAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.secondaryLabel,
            .font: UIFont(name: Fonts.MontserratMedium, size: 10) ?? .systemFont(ofSize: 10, weight: .medium)
        ]
        
        itemAppearance.selected.iconColor = .systemCyan
        itemAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.systemCyan,
            .font: UIFont(name: Fonts.MontserratSemiBold, size: 10) ?? .systemFont(ofSize: 10, weight: .semibold)
        ]
        
        appearance.stackedLayoutAppearance = itemAppearance
        appearance.inlineLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance
        
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
}

// MARK: - Preview

#Preview {
    DashboardTabBarController()
}

