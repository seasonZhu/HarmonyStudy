@ObservedV2
export class AreaHeight {
  @Trace topHeight: number
  @Trace bottomHeight: number
  constructor(top: number, bottom: number) {
    this.topHeight = top
    this.bottomHeight = bottom
  }
}