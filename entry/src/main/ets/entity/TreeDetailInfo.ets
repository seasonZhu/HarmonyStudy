import { ContentType } from '../enum/ContentType';
import { TabModel } from '../model/TabModel';

export interface TreeDetailInfo {
  contentType: ContentType
  tab: TabModel
}