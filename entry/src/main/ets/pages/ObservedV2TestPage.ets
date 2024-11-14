// [Harmony 状态管理神器 @ObservedV2](https://juejin.cn/post/7391704406327164982)
import { openUniMP,isExistsUniMP, releaseWgtToRunPath } from '@dcloudio/uni-app-runtime';
import { FileUtil } from '@pura/harmony-utils';

@ObservedV2
class Person {
  @Trace
  age: number = 100

  son = new Son()
}

@ObservedV2
class Son {
  @Trace
  weight: number = 200
}

// @Entry
// @Component
// export struct ObservedV2TestPage {
//   person = new Person()
//
//   build() {
//     RelativeContainer() {
//       Column({ space: 10 }) {
//         Button("person的age" + this.person.age)
//           .onClick(() => {
//             this.person.age++
//           })
//
//         Button("son的weight" + this.person.son.weight)
//           .onClick(() => {
//             this.person.son.weight++
//           })
//       }
//     }
//     .height('100%')
//     .width('100%')
//   }
// }

@Entry
@Component
struct ObservedV2TestPage {
  @State message: string = 'Hello World';

  aboutToAppear(): void {
    let fileDir: string = getContext().filesDir
    let fileName = "__UNI__98AF8A0.wgt"

    getContext().resourceManager.getRawFileContent(fileName, (error, value) => {
      console.debug(`${"UniApp#"}[${"wgt File"}] ${"getRawFile:__UNI__.wgt"}`)
      if (error != null) {
        console.error("error is " + error.message)
        return
      }
      let filePath = fileDir + "/" + fileName
      let file = FileUtil.openSync(filePath)
      FileUtil.writeSync(file.fd, value.buffer)
      FileUtil.closeSync(file.fd) //关闭文件
      console.debug(`${"UniApp#"}[${"wgt File"}] ${"filePath:" + filePath}`)
    })
  }

  build() {
    RelativeContainer() {
      Text(this.message)
        .id('HelloWorld')
        .fontSize(50)
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
        .onClick(async ()=>{
          const mpId = "__UNI__98AF8A0"

          await new Promise<void>((resolve, reject) => {
            try {
              // 判断应用是否已释放到运行目录
              let isExists = isExistsUniMP(mpId)
              console.log("isExists:"+isExists)

              let fileDir: string = getContext().filesDir
              // 拼接wgt包路径
              let path = fileDir + "/"+mpId+".wgt"
              // 释放 wgt 包到运行目录
              releaseWgtToRunPath(mpId, path, (code:number, data: object)=>{
                console.log(JSON.stringify({code,data}))
                resolve()
                // 启动小程序
                const mp = openUniMP(mpId)
                mp.on('close',()=>{
                  console.log('UniMP-close')
                })
                mp.on('show',()=>{
                  console.log('UniMP-show')
                })
                mp.on('hide',()=>{
                  console.log('UniMP-hide')
                })
              })
            } catch(err){
              reject(err)
            }
          }).then(() => {

          })
        })
    }
    .height('100%')
    .width('100%')
  }
}
