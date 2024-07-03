import { WebLink } from '../entity/WebLink';

export interface Article extends WebLink {
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
  tags: ArticleTag[]
  title: string
  type: number
  userId: number
  visible: number
  zan: number

  //收藏列表 coolect list返回的文章参数
  originId: number

  //额外添加 收藏中
  extIsCollecting: boolean
}

export interface ArticleTag {
  name: string
  url: string
}