RMSHostSelector 
===============

Manages server selection for iOS apps

Use `RMSHostSelector` to allow user-selection of a server host when
testing/debugging iOS apps. Host choices are defined in a Hosts.plist
file that you add to your app's resources. Each host is defined as a
key/value pair (i.e. production => myserver.com)

Release builds should not permit user-selection of a back-end server.
For these builds, preference is given to the `production` key in the
Hosts.plist file. All other keys will be stripped out of the bundled
Hosts.plist file and the user will not be prompted for server selection.
The special handling is performed by the `host_selector_build_phase.sh`
that must be added as a "Run Script" build phase in order to take
effect.

A key other than `production` can be coerced by defining the
`RMS_HOST_KEY` preprocessor macro. The value specified by this key must
be quoted and must match one of the keys in the Hosts.plist file.

Non-release builds can also make use of the `RMS_HOST_KEY` override. For
non-release builds where `RMS_HOST_KEY` is defined, the Hosts.plist file
is left in tact, but user-selection of the host is circumvented.

Custom Build Phase
------------------

Once you've installed this CocoaPod, you'll need to set up a custom
build phase to incorporate `host_selector_build_phase.sh` into your
project. Do this by navigating to the application target in Xcode
and selecting *Add Build Phase -> Add Run Script Build Phase* from the 
*Editor* menu. 

![Add run script build phase](https://raw.github.com/RoleModel/RMSHostSelector/854ea9b2ecfa04935a71a5df16fee708bc8481cd/Screenshots/Add%20Run%20Script.png?login=tingraldi&token=e6be81f186e32e5d8ac5f4c45f844632)

Then, in the shell script entry area for the newly
added run build phase enter the following:

`"${SRCROOT}"/Pods/RMSHostSelector/Resources/host_selector_build_phase.sh`

That's all you need to do to get the default behavior, provided that
your `Hosts.plist` file contains an entry for the `production` host.



![Run script configuration](https://raw.github.com/RoleModel/RMSHostSelector/854ea9b2ecfa04935a71a5df16fee708bc8481cd/Screenshots/Run%20Script%20Configuration.png?login=tingraldi&token=efa9853fa21ee863751fb6fec121cfed)

