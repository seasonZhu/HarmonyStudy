/**
 * WanAndroid API 数据模型
 * @description 基于真实的 WanAndroid API 接口定义的数据结构
 */

/**
 * 首页轮播图
 */
export interface Banner {
  id: number
  desc: string
  imagePath: string
  isVisible: number
  order: number
  title: string
  type: number
  url: string
}

/**
 * 文章标签
 */
export interface Tag {
  name: string
  url: string
}

/**
 * 文章作者信息
 */
export interface Author {
  chapterId: number
  chapterName: string
  courseId: number
  id: number
  link: string
  name: string
  order: number
  parentChapterId: number
  userControlSetTop: boolean
  visible: number
}

/**
 * WanAndroid 文章
 */
export interface Article {
  adminAdd: boolean
  apkLink: string
  audit: number
  author: string
  canEdit: boolean
  chapterId: number
  chapterName: string
  collect: boolean
  courseId: number
  desc: string
  descMd: string
  envelopePic: string
  fresh: boolean
  host: string
  id: number
  isAdminAdd: boolean
  link: string
  niceDate: string
  niceShareDate: string
  origin: string
  prefix: string
  projectLink: string
  publishTime: number
  realSuperChapterId: number
  selfVisible: number
  shareDate: number
  shareUser: string
  superChapterId: number
  superChapterName: string
  tags: Array<Tag>
  title: string
  type: number
  userId: number
  visible: number
  zan: number
}

/**
 * 文章列表分页响应
 */
export interface ArticlePageResponse {
  curPage: number
  datas: Article[]
  offset: number
  over: boolean
  pageCount: number
  size: number
  total: number
}

/**
 * 登录响应
 */
export interface LoginResponse {
  admin: boolean
  chapterTops: string[]
  collectIds: number[]
  email: string
  icon: string
  id: number
  nickname: string
  password: string
  publicName: string
  token: string
  type: number
  username: string
}

/**
 * 排名用户
 */
export interface RankUser {
  coinCount: number
  level: number
  rank: number
  username: string
}

/**
 * 常用网站
 */
export interface UsefulSite {
  icon: string
  id: number
  link: string
  name: string
  order: number
  visible: number
}

/**
 * 搜索热词
 */
export interface HotKey {
  id: number
  link: string
  name: string
  order: number
  visible: number
}

/**
 * 用户积分响应
 */
export interface UserCoinResponse {
  coinCount: number
}
