//
//  SceneDelegate.swift
//  ToDoList_UIKit
//
//  Created by Даниил Суханов on 17.06.2023.
//

import UIKit
import SwiftUI
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard
            let scene = (scene as? UIWindowScene)
        else {
            return
        }
        window = UIWindow(windowScene: scene)
        let view = TodoListView()
        window?.rootViewController = UIHostingController(rootView: view)
        // window?.rootViewController = ViewController(store: .init())
        window?.windowScene = scene
        window?.makeKeyAndVisible()
        
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        
    }

    func sceneWillResignActive(_ scene: UIScene) {
        
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
       
    }

}
