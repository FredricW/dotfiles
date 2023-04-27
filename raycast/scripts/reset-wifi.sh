#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Reset Wifi
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🤖
# @raycast.packageName wifi

networksetup -setnetworkserviceenabled Wi-Fi off && sleep 15 && networksetup -setnetworkserviceenabled Wi-Fi on
