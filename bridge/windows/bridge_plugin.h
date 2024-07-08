#ifndef FLUTTER_PLUGIN_BRIDGE_PLUGIN_H_
#define FLUTTER_PLUGIN_BRIDGE_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace bridge {

class BridgePlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  BridgePlugin();

  virtual ~BridgePlugin();

  // Disallow copy and assign.
  BridgePlugin(const BridgePlugin&) = delete;
  BridgePlugin& operator=(const BridgePlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace bridge

#endif  // FLUTTER_PLUGIN_BRIDGE_PLUGIN_H_
