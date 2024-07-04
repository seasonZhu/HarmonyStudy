export interface UserInfoModel {
  coinCount?: number
  level?: number
  nickname?: string
  rank?: string
  userId?: number
  username?: string
}

export function proccessUserInfo(model: UserInfoModel): string {
  if (model.rank && model.level && model.coinCount) {
    return model.username + `\n` + "排名：" + model.rank + "   " + "等级：" + model.level + "   " + "积分：" + model.coinCount
  } else {
    return "排名：--  等级：--  积分：--"
  }
}