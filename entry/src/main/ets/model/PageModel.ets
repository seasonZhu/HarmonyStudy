
export interface PageModel<T> {
  curPage: number,
  datas: Array<T>,
  offset: number,
  over: boolean,
  pageCount: number,
  size: number,
  total: number,
}