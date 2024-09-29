/// 如果需要在App端也能够像模块一样进行路由，也必须使用import()这样操作
import("entry/ets/pages/MyCoin")

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
}