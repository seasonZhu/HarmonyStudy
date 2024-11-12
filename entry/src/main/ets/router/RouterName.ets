/// 如果需要在App端也能够像模块一样进行路由，也必须使用import()这样操作
import ("entry/ets/pages/Index")
import ("entry/ets/pages/Login")
import ("entry/ets/pages/Register")
import ("entry/ets/pages/MyCoin")
import ("entry/ets/pages/Rank")
import ("entry/ets/pages/SearchResult")
import ("entry/ets/pages/MyCollect")
import ("entry/ets/pages/WebPage")
import ("entry/ets/pages/HotKey")
import ("entry/ets/pages/TreeDetail")
import ("entry/ets/pages/Setting")
import ("entry/ets/pages/WebExample")
import ("entry/ets/pages/WebComponent")
import ("entry/ets/pages/ObservedV2TestPage")


export enum RouterName {
  Splash = "Splash",
  Index = "Index",
  Login = "Login",
  Register = "Register",
  MyCoin = "MyCoin",
  Rank = "Rank",
  SearchResult = "SearchResult",
  MyCollect = "MyCollect",
  Web = "WebPage",
  Hotkey = "HotKey",
  TreeDetail = "TreeDetail",
  Setting = "Setting",
  WebExample =  "WebExample",
  WebComponent =  "WebComponent",
  ObservedV2TestPage = "ObservedV2TestPage"
}