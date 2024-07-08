#include "include/bridge/bridge_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "bridge_plugin.h"

void BridgePluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  bridge::BridgePlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
