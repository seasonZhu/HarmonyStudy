export class StringUtils {
  static replaceHtmlElement(htmlElement: string) {
    return htmlElement
      .replace(RegExp("(<em[^>]*>)|(</em>)"), "")
      .replace(RegExp("\n{2,}"), "\n")
      .replace(RegExp("s{2,}"), " ")
      .replace("&ndash;", "–")
      .replace("&mdash;", "—")
      .replace("&lsquo;", "‘")
      .replace("&rsquo;", "’")
      .replace("&sbquo;", "‚")
      .replace("&ldquo;", "“")
      .replace("&rdquo;", "”")
      .replace("&bdquo;", "„")
      .replace("&permil;", "‰")
      .replace("&lsaquo;", "‹")
      .replace("&rsaquo;", "›")
      .replace("&euro;", "€")
      .replace("<p>", "")
      .replace("</p>", "")
      .replace("</br>", "\n")
      .replace("<br>", "\n")
      .replace("&lt;", "<")
      .replace("&gt;", ">")
      .replace("&nbsp;", " ")
      .replace("&amp;", "&")
      .replace("&quot;", "\"")
      .replace("&yen;", "¥");
  }
}