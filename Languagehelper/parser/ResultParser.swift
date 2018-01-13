//
//  ResultParser.swift
//  Languagehelper
//
//  Created by luli on 16/7/31.
//  Copyright © 2016年 luli. All rights reserved.
//

import Foundation
import SwiftyJSON
import Kanna


class ResultParser {
    
    class func getIcibaiNewRusult(_ json: JSON, resultModel: DictionaryResultModel){
        print("getIcibaiNewRusult")
        var sb:    String = ""
        var sbp:   String = ""
        let ph_en: String = json["content","ph_en"].string!
        if !ph_en.isEmpty {
            sb += "英[" + ph_en + "]    "
        }
        let ph_am = json["content","ph_am"].string!
        if !ph_am.isEmpty {
            sb += "美[" + ph_am + "]  "
        }
        if let word_mean = json["content","word_mean"].array {
            for (index,item) in word_mean.enumerated() {
                if index == 0 && !sb.isEmpty{
                    sb += "\n"
                }else if index > 0 {
                    sb += "\n"
                }
                sbp += item.string!
                sb += item.string!
            }
        }
        if let ph_am_mp3 = json["content","ph_am_mp3"].string {
            resultModel.ph_am_mp3 = ph_am_mp3
        }
        if let ph_en_mp3 = json["content","ph_en_mp3"].string {
            resultModel.ph_en_mp3 = ph_en_mp3
        }
        if let ph_tts_mp3 = json["content","ph_tts_mp3"].string {
            resultModel.ph_tts_mp3 = ph_tts_mp3
        }
        resultModel.result = sb
        resultModel.resultForPlay = sbp
    }

    class func getIcibaiRusult(_ html: String) -> String {
        print("getIcibaiRusult")
        var sb = ""
        if let doc = Kanna.HTML(html: html, encoding: String.Encoding.utf8) {
            for link in doc.css("span.dd") {
                let tem = link.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                if !tem.isEmpty {
                    sb += tem
                }
            }
        }
        return sb
    }
 
    class func parseYoudaoWeb(_ result: String, question: String, resultModel:DictionaryResultModel){
        print("parseYoudaoWeb")
        var sb:    String = ""
        var sbp:   String = ""
        if let doc = Kanna.HTML(html: result, encoding: String.Encoding.utf8) {
            if Utile.isChinese(question) {
                resultModel.from = "zh-CN"
                resultModel.to = "en-US"
            }else{
                resultModel.from = "en-US"
                resultModel.to = "zh-CN"
            }
            resultModel.question = question
            sbp += question + ","
            var isHasPronounce: Bool = false
            for link in doc.css("h2.wordbook-js > div.baav > span.pronounce") {
                print("------")
                sb += link.text!.removingWhitespaces()
                    .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    .replacingOccurrences(
                        of:
                        "\n",
                        with: " ")
                sb += "  "
                isHasPronounce = true
            }
            if isHasPronounce {
                sb += "\n"
            }
            if let link = doc.css("div#phrsListTab > div.trans-container > ul").first {
                for li in link.css("li"){
                    let tem = li.text!.removingWhitespaces().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                        .replacingOccurrences(
                            of:
                            "\n",
                            with: " ")
                    sb += tem
                    sb += "\n"
                    sbp += tem + ","
                    
                }
                for li in link.css("p"){
                    let tem = li.text!.removingWhitespaces().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                        .replacingOccurrences(
                            of:
                            "\n",
                            with: " ")
                    sb += tem
                    sb += "\n"
                    sbp += tem + ","
                    
                }
            }
            if let link = doc.css("div#phrsListTab > div.trans-container > p.additional").first {
                let tem = link.text!.removingWhitespaces().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    .replacingOccurrences(
                        of:
                        "\n",
                        with: " ")
                sb += tem
                sb += "\n"
                sbp += tem + ","
            }
            
            if let link = doc.css("div#tWebTrans > div.wt-container > div.title > span").first {
                sb += "\n"
                sb += "网络释义:"
                sb += "\n"
                let tem = link.text!.removingWhitespaces().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    .replacingOccurrences(
                        of:
                        "\n",
                        with: " ")
                sb += tem
                sb += "\n"
                sbp += tem + ","
            }
            for link in doc.css("div#tWebTrans > div.wt-container.wt-collapse > div.title > span") {
                let tem = link.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    .replacingOccurrences(
                        of:
                        "\\s+",
                        with: " ",
                        options: .regularExpression)
                sb += tem
                sb += "\n"
                sbp += tem + ","
            }
            if let link = doc.css("div#webPhrase > div.title").first {
                let tem = link.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    .replacingOccurrences(
                        of:
                        "\\s+",
                        with: " ",
                        options: .regularExpression)
                sb += "\n"
                sb += tem
                sb += "\n"
                sbp += tem + ","
            }
            for link in doc.css("div#webPhrase > p") {
                let tem = link.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    .replacingOccurrences(
                        of:
                        "\\s+",
                        with: " ",
                        options: .regularExpression)
                sb += tem
                sb += "\n"
                sbp += tem + ","
            }
            if let link = doc.css("div#authTrans > div#authTransToggle > div#authDictTrans > h4.wordGroup").first {
                sb += "\n"
                sb += "21世纪大英汉词典:"
                sb += "\n"
                let tem = link.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    .replacingOccurrences(
                        of:
                        "\\s+",
                        with: " ",
                        options: .regularExpression)
                sb += tem
                sb += "\n"
                sbp += tem + ","
            }
            for item in doc.css("div#authTrans > div#authTransToggle > div#authDictTrans > ul > li") {
                if let span = item.css("span").first {
                    let tem = span.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                        .replacingOccurrences(
                            of:
                            "\\s+",
                            with: " ",
                            options: .regularExpression)
                    sb += tem
                    sb += "\n"
                    sbp += tem + ","
                }
                for link in item.css("ul > li") {
                    let tem = link.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                        .replacingOccurrences(
                            of:
                            "\\s+",
                            with: " ",
                            options: .regularExpression)
                    sb += tem
                    sb += "\n"
                    sbp += tem + ","
                }
            }
            for (index,link) in doc.css("div#eTransform > div#transformToggle > div#wordGroup > p").enumerated() {
                if index == 0 {
                    sb += "\n"
                    sb += "词组短语:"
                    sb += "\n"
                }
                let tem = link.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    .replacingOccurrences(
                        of:
                        "\\s+",
                        with: " ",
                        options: .regularExpression)
                sb += tem
                sb += "\n"
                sbp += tem + ","
            }
            if let container = doc.css("div#eTransform > div#transformToggle > div#discriminate > div.wt-container").first {
                sb += "\n"
                sb += "词语辨析:"
                sb += "\n"
                if let title = container.css("div.title").first{
                    let tem = title.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                        .replacingOccurrences(
                            of:
                            "\\s+",
                            with: " ",
                            options: .regularExpression)
                    sb += tem
                    sb += "\n"
                    sbp += tem + ","
                }
                if let ptitle = container.css("div.collapse-content > p").first{
                    let tem = ptitle.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                        .replacingOccurrences(
                            of:
                            "\\s+",
                            with: " ",
                            options: .regularExpression)
                    sb += tem
                    sb += "\n"
                    sbp += tem + ","
                }
                for link in container.css("div.collapse-content > div.wordGroup") {
                    let tem = link.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                        .replacingOccurrences(
                            of:
                            "\\s+",
                            with: " ",
                            options: .regularExpression)
                    sb += tem
                    sb += "\n"
                    sbp += tem + ","
                }
            }
            for (index,link) in doc.css("div#examples > div#examplesToggle > div#bilingual > ul.ol > li").enumerated() {
                if index == 0 {
                    sb += "\n"
                    sb += "双语例句:"
                    sb += "\n"
                }
                for (n,p) in link.css("p").enumerated() {
                    if n < 2 {
                        let tem = p.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                            .replacingOccurrences(
                                of:
                                "\\s+",
                                with: " ",
                                options: .regularExpression)
                        sb += tem
                        sb += "\n"
                        sbp += tem + ","
                    }
                }
            }
            for (index,link) in doc.css("div#examples > div#examplesToggle > div#originalSound > ul.ol > li").enumerated() {
                if index == 0 {
                    sb += "\n"
                    sb += "原声例句:"
                    sb += "\n"
                }
                for (n,p) in link.css("p").enumerated() {
                    if n < 2 {
                        let tem = p.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                            .replacingOccurrences(
                                of:
                                "\\s+",
                                with: " ",
                                options: .regularExpression)
                        sb += tem
                        sb += "\n"
                        sbp += tem + ","
                    }
                }
            }
            let position = sb.range(of: "\n",options: .backwards)
            resultModel.result = sb.substring(to: (position?.upperBound)!)
            resultModel.resultForPlay = sbp
        }
    }
    
    class func parseBiyingWeb(_ result: String, question: String, resultModel:DictionaryResultModel){
        print("parseBiyingWeb")
        var sb:    String = ""
        var sbp:   String = ""
        if let doc = Kanna.HTML(html: result, encoding: String.Encoding.utf8) {
            if Utile.isChinese(question) {
                resultModel.from = "zh-CN"
                resultModel.to = "en-US"
            }else{
                resultModel.from = "en-US"
                resultModel.to = "zh-CN"
            }
            resultModel.question = question
            sbp += question + ","
            if let link = doc.css("div.hd_p1_1").first {
                sb += link.text!
                sb += "\n"
                sbp += link.text! + ","
            }
            if let link = doc.css("div.p1-11").first {
                sb += link.text!
                sb += "\n"
                sbp += link.text! + ","
            }
            for link in doc.css("div.qdef > ul > li") {
                for (index,span) in link.css("span").enumerated() {
                    if index < 2 {
                        sb += span.text!
                        sb += "  "
                    }
                }
                sb += "\n"
                sbp += link.text! + ","
            }
            if let link = doc.css("div.qdef > div.hd_div1 > div.hd_if").first {
                sb += link.text!
                sb += "\n"
                sbp += link.text! + ","
            }
            for (index,li) in doc.css("div.wd_div > div#thesaurusesid > div#colid > div.df_div2").enumerated(){
                if index == 0 {
                    sb += "\n"
                    sb += "搭配:"
                    sb += "\n"
                }
                for div in li.css("div") {
                    sb += div.text!
                    sb += "  "
                }
                sb += "\n"
                sbp += li.text! + ","
            }
            if let authid = doc.css("div.df_div > div#defid > div#authid").first {
                sb += "\n"
                sb += "权威英汉双解:"
                sb += "\n"
                if let title = authid.css("div.hw_ti > div.hw_area2 > div.hd_div2 > span").first {
                    sb += title.text!
                    sb += "\n"
                    sbp += title.text! + ","
                }
                for seg in authid.css("div.li_sen > div.each_seg"){
                    if let pos = seg.css("div.li_pos > div.pos_lin > div.pos").first {
                        sb += pos.text!
                        sb += "\n"
                        sbp += pos.text! + ","
                    }
                    for segdiv in seg.css("div.li_pos > div.de_seg > div.se_lis") {
                        sb += segdiv.text!
                        sb += "\n"
                        sbp += segdiv.text! + ","
                    }
                    if let pos = seg.css("div.li_id > div.idm_ti").first {
                        sb += pos.text!
                        sb += "\n"
                        sbp += pos.text! + ","
                    }
                    for (_,segdiv) in seg.css("div.li_id > div.idm_seg > div.idm_s").enumerated() {
                        sb += segdiv.text!
                        sb += "\n"
                        sbp += segdiv.text! + ","
                        if let def_pa = segdiv.css("div.li_id > div.idm_seg > div.li_ids_co > div > div > div > div.def_pa").first{
                            for span in def_pa.css("span") {
                                sb += span.text!
                                sb += "  "
                                sbp += segdiv.text! + ","
                            }
                            sb += "\n"
                        }
                    }
                }
            }
            for (index,seli) in doc.css("div#sentenceCon > div#sentenceSeg > div.se_li").enumerated() {
                if index == 0 {
                    sb += "\n"
                    sb += "例句:"
                    sb += "\n"
                }
                if let se_li1 = seli.css("div.se_li1").first {
                    for (index,div) in se_li1.css("div").enumerated() {
                        if index < 2 {
                            sb += div.text!
                            sb += "\n"
                            sbp += div.text! + ","
                        }
                    }
                }
            }
            resultModel.result = sb
            resultModel.resultForPlay = sbp
        }
    }
    
}

extension String {
    func removingWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
}
