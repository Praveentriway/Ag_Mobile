 # agfsportalflutter

A multi-tenant flutter application for portal.

 ## Getting Started


Core component of the application is done on webpart and integrated with flutter engine.


––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––


 ## This project has following features
 

 1.User Login with AES/PKS7 Encryption
 2.Pin & Biometric login
 3.Settings control.
 4.Push Notification.
 
 
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––– 
 
 
 ## Project has three sets of flavour
 
 
 1. AGFS Mobile - flavour name is 'agfs' - lib/agfs.dart
 2. EMCO Mobile - flavour name is 'emco' - lib/emco.dart
 3. MBMB Mobile - flavour name is 'mbm' - lib/mbm.dart
 
 
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––  

 
  ## Inorder to generate an release apk do the following steps 
  
 
 1. Open android module from flutter project
 2. Under gradle/app - change properties value of signingConfigs - release 
 3. Increase the build number and version code under gradle properties.
 4. Clean project on android module and flutter.
 5. use this command to create signed release apk. 
 
    - flutter build apk --release --flavor agfs -t lib/src/profiling/agfs.dart
    - flutter build apk --release --flavor mbm -t lib/src/profiling/mbm.dart
    - flutter build apk --release --flavor emco -t lib/src/profiling/emco.dart
    
    
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––-    
    
    
  ## To generate IOS .IPA 
 
 
 
 1. Set profiling to respective flavour name, remove build flavour name in edit config.
 2. Export ios project
 3. Rename app name, build version, app version and package name.
 4. Change the app icon to respective app and build archive.
 
 
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––