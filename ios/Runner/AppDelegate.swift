import UIKit
import Flutter
import CryptoSwift
import Siren


@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // app update checker
               Siren.shared.wail()


        
       GeneratedPluginRegistrant.register(with: self)


        
    
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController;
        let PLATFORM_CHANNEL = FlutterMethodChannel.init(name: "com.ag.facilities.portal/platform_channel", binaryMessenger: controller as! FlutterBinaryMessenger);
    
    PLATFORM_CHANNEL.setMethodCallHandler({
        (call: FlutterMethodCall, result: FlutterResult) -> Void in
        // if ("demoFunction" == call.method) { // INFO: method check
        //     let arguments = call.arguments as! NSDictionary // INFO: get arguments
        //     demoFunction(result: result, data: arguments["data"] as! String) // INFO: method call, every method call should pass result parameter
        // } else
        if ("loginEncryption" == call.method) {
            
            let arguments = call.arguments as! NSDictionary
            
//            demoFunction(result: result,key: arguments["key"] as! String,text: arguments["text"] as! String)
            
          print( aesEncrypt(value: arguments["text"] as! String,key: arguments["key"] as! String))
            
            result(aesEncrypt(value: arguments["text"] as! String,key: arguments["key"] as! String))
            
            
        }
        else if ("connectNetwork" == call.method) {
            // Connect to a network with provided SSID & Password
            // This will not work, because we have no permission. So always return an error message.
            result(FlutterError.init(
                code: "NO_PERMISSION",
                message: "Auto connect not possible in iOS devices! Please connect to network manually.",
                details: nil
            ))
        }
        else {
            result(FlutterMethodNotImplemented)
        }
    })
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  - (void)applicationWillResignActive:(UIApplication *)application{
      self.window.hidden = YES;
  }

  - (void)applicationDidBecomeActive:(UIApplication *)application{
      self.window.hidden = NO;
  }
}

func demoFunction(result: FlutterResult, key: String,text: String) {
    
     print(text)
    // INFO: function implementation
    if (true) { // INFO: check for some condition
        
      result("ios call success with data \(key)") // INFO: success response should return through this method
    } else {
      result(FlutterError.init(
            code: "ERROR",
            message: "Error message description!",
            details: nil
        )) // INFO: error response should return through this method
    }
}


 func aesEncrypt(value: String, key: String) -> String {
    
    // byte has been sliced to match the bit range with iv.
    let ivSlice = key.bytes[0..<16]
    let ivArray = Array<UInt8>(ivSlice)
    let data = Array(value.utf8)
        
    do {
         let encrypted = try AES(key: ivArray, blockMode: CBC(iv: ivArray),
               padding: .pkcs5).encrypt(data)
        
    let encryptedData = Data(encrypted)
        return  getUrlSafeString(value:encryptedData.base64EncodedString())
        
    }
    catch {
    print(error)
    return ""
    }

   }

func getUrlSafeString(value: String) -> String {
    
    return value.replacingOccurrences(of: "+", with: "-").replacingOccurrences(of: "/", with: "_")
    .replacingOccurrences(of: "%", with: "%25").replacingOccurrences(of: "\n", with: "%0A")
    
}



