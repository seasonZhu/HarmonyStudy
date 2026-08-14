export class ApiConstants {
  static readonly BANNER = 'banner/json'
  static readonly ARTICLE_TOP = 'article/top/json'
  static readonly HOTKEY = 'hotkey/json'
  static readonly USER_INFO = 'lg/coin/userinfo/json'
  static readonly USER_LOGOUT = 'user/logout/json'
  static readonly PROJECT_TREE = 'project/tree/json'
  static readonly WX_ARTICLE_CHAPTERS = 'wxarticle/chapters/json'
  static readonly TREE = 'tree/json'

  static articleList(page: number): string {
    return 'article/list/' + page.toString() + '/json'
  }

  static articleQuery(page: number): string {
    return 'article/query/' + page.toString() + '/json'
  }

  static userLogin(username: string, password: string): string {
    return 'user/login?username=' + username + '&password=' + password
  }

  static userRegister(username: string, password: string, repassword: string): string {
    return 'user/register?username=' + username + '&password=' + password + '&repassword=' + repassword
  }

  static collectList(page: number): string {
    return 'lg/collect/list/' + page.toString() + '/json'
  }

  static collectAdd(id: number): string {
    return 'lg/collect/' + id.toString() + '/json'
  }

  static collectCancel(id: number): string {
    return 'lg/uncollect_originId/' + id.toString() + '/json'
  }

  static coinList(page: number): string {
    return 'lg/coin/list/' + page.toString() + '/json'
  }

  static coinRank(page: number): string {
    return 'coin/rank/' + page.toString() + '/json'
  }

  static projectList(page: number, cid: number): string {
    return 'project/list/' + page.toString() + '/json?cid=' + cid.toString()
  }

  static wxArticleList(cid: number, page: number): string {
    return 'wxarticle/list/' + cid.toString() + '/' + page.toString() + '/json'
  }

  static treeDetailList(page: number, cid: number): string {
    return 'article/list/' + page.toString() + '/json?cid=' + cid.toString()
  }
}
