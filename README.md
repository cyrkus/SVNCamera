# SVNCamera
A generic camera ViewController intended for the SVNAppBuilder project.
Submodules include:
SVNModalViewController

#To Use this framework
Instantiate SVNViewController with init(:theme, :delegate) or init(nibName: bundleName: theme: delegate:)
You can pass in your own SVNTheme or an instance of SVNTheme_default ...

If you haven't added camera access request to your info.plist:
  Add

    Key       :  Privacy - Camera Usage Description   
    Value     :  $(PRODUCT_NAME) camera use
    to info.plist


## To install this framework
Add Carthage files to your .gitignore

    #Carthage
    Carthage/Build

Check your Carthage Version to make sure Carthage is installed locally:

    Carthage version

Create a CartFile to manage your dependencies:

    Touch CartFile

Open the Cartfile and add this as a dependency. (in OGDL):

    github "sevenapps/PathToRepo*" "master"

Update your project to include the framework:

    Carthage update --platform iOS

*IMPORTANT*
Add the framework to 'Embedded Binaries' in the Xcode Project by dragging and dropping the framework created in

    Carthage/Build/iOS/pathToFramework*.framework

Add this run Script to your xcodeproj

    /usr/local/bin/carthage copy-frameworks

Add this input file to the run script:

    $(SRCROOT)/Carthage/Build/iOS/pathToFramework*.framework

If Xcode has issues finding your framework Add

    $(SRCROOT)/Carthage/Build/iOS

To 'Framework Search Paths' in Build Settings
