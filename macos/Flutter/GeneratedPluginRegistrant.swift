//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import bridge
import desktop_multi_window
import device_info_plus
import dynamic_color
import irondash_engine_context
import macos_window_utils
import path_provider_foundation
import screen_retriever
import super_native_extensions
import window_manager

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  BridgePlugin.register(with: registry.registrar(forPlugin: "BridgePlugin"))
  FlutterMultiWindowPlugin.register(with: registry.registrar(forPlugin: "FlutterMultiWindowPlugin"))
  DeviceInfoPlusMacosPlugin.register(with: registry.registrar(forPlugin: "DeviceInfoPlusMacosPlugin"))
  DynamicColorPlugin.register(with: registry.registrar(forPlugin: "DynamicColorPlugin"))
  IrondashEngineContextPlugin.register(with: registry.registrar(forPlugin: "IrondashEngineContextPlugin"))
  MacOSWindowUtilsPlugin.register(with: registry.registrar(forPlugin: "MacOSWindowUtilsPlugin"))
  PathProviderPlugin.register(with: registry.registrar(forPlugin: "PathProviderPlugin"))
  ScreenRetrieverPlugin.register(with: registry.registrar(forPlugin: "ScreenRetrieverPlugin"))
  SuperNativeExtensionsPlugin.register(with: registry.registrar(forPlugin: "SuperNativeExtensionsPlugin"))
  WindowManagerPlugin.register(with: registry.registrar(forPlugin: "WindowManagerPlugin"))
}
