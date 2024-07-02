export interface TabModel {
  children?: [TabModel]
  courseId?: number
  id?: number
  name?: string
  order?: number
  parentChapterId?: number
  userControlSetTop?: boolean
  visible?: number
}