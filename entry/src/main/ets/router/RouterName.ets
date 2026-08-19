/// 如果需要在App端也能够像模块一样进行路由，也必须使用import()这样操作
import ("entry/ets/pages/Index")
import ("entry/ets/pages/Login")
import ("entry/ets/pages/Register")
import ("entry/ets/pages/MyCoin")
import ("entry/ets/pages/Rank")
import ("entry/ets/pages/SearchResult")
import ("entry/ets/pages/MyCollect")
import ("entry/ets/pages/WebBrowser")
import ("entry/ets/pages/HotKey")
import ("entry/ets/pages/TreeDetail")
import ("entry/ets/pages/EnvironmentSwitch")
import ("entry/ets/pages/Setting")
import ("entry/ets/pages/WebExample")
import ("entry/ets/pages/WebComponent")
import ("entry/ets/pages/ObservedV2Test")
import ("entry/ets/network/examples/pages/NetworkExample")
import ("entry/ets/pages/NativeComponentsDemo")
import ("entry/ets/pages/NetworkComparison")
import ("entry/ets/pages/Profile")
import ("entry/ets/pages/Tree")
import ("entry/ets/pages/Home")
import ("entry/ets/pages/TabsDetail")
import ("entry/ets/pages/TabScaffold")
import ("entry/ets/pages/NavPathStackTest")


export enum RouterName {
  Splash = "Splash",
  Index = "Index",
  Login = "Login",
  Register = "Register",
  MyCoin = "MyCoin",
  Rank = "Rank",
  SearchResult = "SearchResult",
  MyCollect = "MyCollect",
  WebBrowser = "WebBrowser",
  HotKey = "HotKey",
  TreeDetail = "TreeDetail",
  EnvironmentSwitch = "EnvironmentSwitch",
  Setting = "Setting",
  WebExample = "WebExample",
  WebComponent = "WebComponent",
  ObservedV2Test = "ObservedV2Test",
  NetworkExample = "NetworkExample",
  NativeComponentsDemo = "NativeComponentsDemo",
  NetworkComparison = "NetworkComparison",
  Profile = "Profile",
  Tree = "Tree",
  Home = "Home",
  TabsDetail = "TabsDetail",
  TabScaffold = "TabScaffold",
  NavPathStackTest = "NavPathStackTest"
}
