import func Foundation.sysctlbyname
import class Foundation.NSBundle
import class Foundation.NSDate
import class UIKit.UIDevice
import class UIKit.UIScreen

public final class Koala {
  private let client: TrackingClientType

  public init(client: TrackingClientType = KoalaTrackingClient()) {
    self.client = client
  }

  public func trackAppOpen() {
    self.track(event: "App Open")
  }

  public func trackAppClose() {
    self.track(event: "App Close")
  }

  /**
   Call when a discovery search is made, including pagination.
   */
  public func trackDiscovery() {
    self.track(event: "Discovery List View")
  }

  public func trackLoginTout(intent: String) {
    self.track(event: "Application Login or Signup", properties: ["intent": intent])
  }

  public func trackLoginSuccess() {
    self.track(event: "Login")
  }

  public func trackLoginError() {
    self.track(event: "Errored User Login")
  }

  public func trackResetPassword() {
    self.track(event: "Forgot Password View")
  }

  public func trackResetPasswordSuccess() {
    self.track(event: "Forgot Password Requested")
  }

  public func trackResetPasswordError() {
    self.track(event: "Forgot Password Errored")
  }

  public func trackSignupSuccess() {
    self.track(event: "New User")
  }

  public func trackSignupNewsletterToggle(sendNewsletters: Bool) {
    self.track(event: "Signup Newsletter Toggle", properties: ["send_newsletters": sendNewsletters])
  }

  public func trackFacebookConfirmation() {
    self.track(event: "Facebook Confirm")
  }

  public func trackTfa() {
    self.track(event: "Two-factor Authentication Confirm View")
  }

  public func trackTfaResendCode() {
    self.track(event: "Two-factor Authentication Resend Code")
  }

  /**
   Call once when the search view is initially shown.
   */
  public func trackProjectSearchView() {
    self.track(event: "Discover Search")
  }

  /**
   Call when projects have been obtained from a search.
   */
  public func trackSearchResults(query query: String, pageCount: Int) {
    let properties: [String:AnyObject] = ["search_term": query, "page_count": pageCount]

    if pageCount == 1 {
      self.track(event: "Discover Search Results", properties: properties)
    } else {
      self.track(event: "Discover Search Results Load More", properties: properties)
    }
  }

  // Private tracking method that merges in default properties.
  private func track(event event: String, properties: [String:AnyObject] = [:]) {
    self.client.track(
      event: event,
      properties: self.defaultProperties().withAllValuesFrom(properties)
    )
  }

  private func defaultProperties() -> [String : AnyObject] {
    var props: [String:AnyObject] = [:]

    props["manufacturer"] = "Apple"
    props["app_version"] = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"]
    props["app_release"] = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"]
    props["model"] = deviceModel
    props["os"] = UIDevice.currentDevice().systemName
    props["os_version"] = UIDevice.currentDevice().systemVersion
    props["screen_width"] = UInt(UIScreen.mainScreen().bounds.width)
    props["screen_height"] = UInt(UIScreen.mainScreen().bounds.height)

    props["koala_lib"] = "iphone"

    props["client_type"] = "native"
    props["device_format"] = deviceFormat
    props["client_platform"] = clientPlatform

    // TODO: device_fingerprint, apple_pay_capable, iphone_uuid, preferred_content_size_category,
    //       device_orientation

    return props
  }

  private lazy var deviceModel: String? = {
    var size : Int = 0
    sysctlbyname("hw.machine", nil, &size, nil, 0)
    var machine = [CChar](count: Int(size), repeatedValue: 0)
    sysctlbyname("hw.machine", &machine, &size, nil, 0)
    return String.fromCString(machine)
  }()

  private lazy var deviceFormat: String = {
    switch UIDevice.currentDevice().userInterfaceIdiom {
    case .Phone: return "phone"
    case .Pad:   return "tablet"
    case .TV:    return "tv"
    default:     return "unspecified"
    }
  }()

  private lazy var clientPlatform: String = {
    switch UIDevice.currentDevice().userInterfaceIdiom {
    case .Phone, .Pad: return "ios"
    case .TV:         return "tvos"
    default:           return "unspecified"
    }
  }()
}