//
//  Enum.swift
//  tachiyomi
//
//  Created by Grace, Mu-Hui Yu on 8/3/23.
//

enum Language: String, CaseIterable, Codable {
    case ar
    case bg
    case bn
    case ca
    case cs
    case da
    case de
    case es
    case el
    case en
    case et
    case fa
    case fi
    case fr
    case he
    case hi
    case hr
    case hu
    case id
    case it
    case ja
    case ko
    case lt
    case lv
    case mk
    case ml
    case ms
    case nl
    case no
    case pl
    case pt
    case ro
    case ru
    case sk
    case sl
    case sr
    case sv
    case sw
    case ta
    case te
    case th
    case tr
    case uk
    case ur
    case vi
    case zh
    
    var localizedName: String {
        switch self {
        case .ar: return "العربية"
        case .bg: return "Български"
        case .bn: return "বাংলা"
        case .ca: return "Català"
        case .cs: return "Čeština"
        case .da: return "Dansk"
        case .de: return "Deutsch"
        case .el: return "Ελληνικά"
        case .en: return "English"
        case .es: return "Español"
        case .et: return "Eesti"
        case .fa: return "فارسی"
        case .fi: return "Suomi"
        case .fr: return "Français"
        case .he: return "עברית"
        case .hi: return "हिन्दी"
        case .hr: return "Hrvatski"
        case .hu: return "Magyar"
        case .id: return "Bahasa Indonesia"
        case .it: return "Italiano"
        case .ja: return "日本語"
        case .ko: return "한국어"
        case .lt: return "Lietuvių"
        case .lv: return "Latviešu"
        case .mk: return "Македонски"
        case .ml: return "മലയാളം"
        case .ms: return "Bahasa Melayu"
        case .nl: return "Nederlands"
        case .no: return "Norsk"
        case .pl: return "Polski"
        case .pt: return "Português"
        case .ro: return "Română"
        case .ru: return "Русский"
        case .sk: return "Slovenčina"
        case .sl: return "Slovenščina"
        case .sr: return "Српски"
        case .sv: return "Svenska"
        case .sw: return "Kiswahili"
        case .ta: return "தமிழ்"
        case .te: return "తెలుగు"
        case .th: return "ไทย"
        case .tr: return "Türkçe"
        case .uk: return "Українська"
        case .ur: return "اردو"
        case .vi: return "Tiếng Việt"
        case .zh: return "中文"
        }
    }
}
