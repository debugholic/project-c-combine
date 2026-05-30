import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard let windowScene = scene as? UIWindowScene else { return }

    let window = UIWindow(windowScene: windowScene)
    let store = TripStore()
    window.rootViewController = UINavigationController(
      rootViewController: TripListViewController(viewModel: TripListViewModel(store: store), store: store)
    )
    window.makeKeyAndVisible()
    self.window = window
  }
}
