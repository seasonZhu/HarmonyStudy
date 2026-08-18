export enum ContentType {
  project,
  publicNumber,
  tree
}

export function getTitle(type: ContentType): string {
  switch (type) {
    case ContentType.project:
      return "项目"
    case ContentType.publicNumber:
      return "公众号"
    case ContentType.tree:
      return "体系"
  }
}