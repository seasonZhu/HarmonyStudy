/**
 * 业务页面名称由 routerMap.json 映射到 Builder。
 * App 内命名路由的动态导入演示见 RoutingExamples.ets。
 * 示例写法 import('entry/ets/pages/RouterPageExample')。
 * 目标页声明 @Entry({ routeName: 'RouterPageExample' }) 后，
 * 使用 router.pushNamedRoute({ name: 'RouterPageExample' }) 打开。
 * 如需演示 HotKey，也需配套声明 routeName 并使用 Router 页面栈接收参数及返回。
 */
export enum RouterName {
  RoutingExamples = "RoutingExamples",
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
