export class StringUtils {
  static replaceHtmlElement(htmlElement: string) {
    return htmlElement
      .replace(/(<em[^>]*>)|(<\/em>)/g, "")
      .replace(/\n{2,}/g, "\n")
      .replace(/s{2,}/g, " ")
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