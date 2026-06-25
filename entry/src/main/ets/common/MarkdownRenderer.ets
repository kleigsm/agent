import {
  COLOR_TEXT_PRIMARY, C_TEXT_PRIMARY_DARK,
  COLOR_TEXT_SECONDARY, C_TEXT_SECONDARY_DARK,
  COLOR_ACCENT_BLUE, dc
} from './Constants'
import { pasteboard } from '@kit.BasicServicesKit'

interface MdSegment {
  type: 'text' | 'code-block' | 'inline-code' | 'bold'
  content: string
  language?: string
}

@Component
export struct MarkdownRenderer {
  @StorageLink('isDarkMode') isDark: boolean = false
  @Prop content: string = ''
  @State segments: MdSegment[] = []

  aboutToAppear(): void {
    this.segments = this.parseMarkdown(this.content)
  }

  /** Parse markdown into typed segments */
  private parseMarkdown(text: string): MdSegment[] {
    let result: MdSegment[] = []
    let i = 0
    let len = text.length

    while (i < len) {
      // Code block: ``` ... ```
      if (text.substring(i, i + 3) === '```' && (i === 0 || text[i - 1] === '\n' || i === 0)) {
        let end = text.indexOf('\n', i + 3)
        let lang = ''
        if (end === -1) { result.push({ type: 'text', content: text.substring(i) }); break }
        lang = text.substring(i + 3, end).trim()
        let closeAt = text.indexOf('\n```', end + 1)
        if (closeAt === -1) { result.push({ type: 'text', content: text.substring(i) }); break }
        let code = text.substring(end + 1, closeAt).trimEnd()
        result.push({ type: 'code-block', content: code, language: lang })
        i = closeAt + 4
        continue
      }

      // Inline code: `code`
      if (text[i] === '`' && text[i + 1] !== '`' && text[i - 1] !== '`') {
        let close = text.indexOf('`', i + 1)
        if (close === -1) { result.push({ type: 'text', content: text.substring(i) }); break }
        result.push({ type: 'inline-code', content: text.substring(i + 1, close) })
        i = close + 1
        continue
      }

      // Bold: **text**
      if (text.substring(i, i + 2) === '**') {
        let close = text.indexOf('**', i + 2)
        if (close === -1) { result.push({ type: 'text', content: text.substring(i) }); break }
        result.push({ type: 'bold', content: text.substring(i + 2, close) })
        i = close + 2
        continue
      }

      // Regular text — collect until next special marker
      let next = len
      let markers = [text.indexOf('```', i), text.indexOf('`', i), text.indexOf('**', i)]
      for (let m of markers) { if (m > i && m < next) next = m }

      // Don't split on ``` if not at line start
      if (next > i && text.substring(next, next + 3) === '```' && next > 0 && text[next - 1] !== '\n') {
        let after = text.indexOf('\n', next)
        let searchFrom = after > next ? after + 1 : next + 3
        let m2 = [text.indexOf('`', searchFrom), text.indexOf('**', searchFrom)]
        next = len
        for (let m of m2) { if (m > i && m < next) next = m }
      }

      if (next === i) next = len
      result.push({ type: 'text', content: text.substring(i, next) })
      i = next
    }

    return result
  }

  build() {
    Column() {
      ForEach(this.segments, (seg: MdSegment, idx: number) => {
        if (seg.type === 'code-block') {
          Column() {
            Row() {
              Text(seg.language || 'code').fontSize(10).fontColor('#AEAEB2')
              Blank()
              Text('复制').fontSize(10).fontColor(COLOR_ACCENT_BLUE)
                .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                .borderRadius(4).backgroundColor(COLOR_ACCENT_BLUE + '18')
                .onClick(() => {
                  pasteboard.getSystemPasteboard().setData(
                    pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, seg.content)
                  )
                })
            }.width('100%').padding({ left: 12, right: 8, top: 6, bottom: 6 })

            Text(seg.content).fontSize(12).fontColor('#E5E5EA').fontFamily('monospace').lineHeight(18)
              .padding({ left: 12, right: 12, bottom: 10 }).width('100%')
          }
          .backgroundColor('#1D1D1F').borderRadius(10).width('100%').margin({ top: 6, bottom: 6 })
        } else if (seg.type === 'inline-code') {
          Text(seg.content).fontSize(13).fontFamily('monospace')
            .fontColor('#FF6B35')
            .backgroundColor('#FF6B35' + '15').borderRadius(4)
            .padding({ left: 4, right: 4, top: 1, bottom: 1 })
        } else if (seg.type === 'bold') {
          Text(seg.content).fontSize(14).fontColor(dc(this.isDark, COLOR_TEXT_PRIMARY, C_TEXT_PRIMARY_DARK)).fontWeight(FontWeight.Bold).lineHeight(20)
        } else {
          Text(seg.content).fontSize(14).fontColor(dc(this.isDark, COLOR_TEXT_PRIMARY, C_TEXT_PRIMARY_DARK)).lineHeight(20)
        }
      }, (seg: MdSegment, idx: number) => idx.toString())
    }.width('100%')
  }
}
