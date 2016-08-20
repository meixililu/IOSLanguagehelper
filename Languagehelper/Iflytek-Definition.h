//
//  Iflytek-Definition.h
//  Languagehelper
//
//  Created by luli on 16/7/2.
//  Copyright © 2016年 luli. All rights reserved.
//

#ifndef Iflytek_Definition_h
#define Iflytek_Definition_h

#import <Foundation/Foundation.h>
#define Margin                5
#define Padding               10
#define iOS7TopMargin         64 //导航栏44，状态栏20
#define IOS7_OR_LATER         ( [[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending )
#define ButtonHeight          44
#define NavigationBarHeight   44
#define APPID_VALUE           @"53bfecad"
#define URL_VALUE             @""                 // url
#define TIMEOUT_VALUE         @"20000"            // timeout      连接超时的时间，以ms为单位
#define BEST_URL_VALUE        @"1"                // best_search_url 最优搜索路径


#define SEARCH_AREA_VALUE     @"安徽省合肥市"
#define ASR_PTT_VALUE         @"1"
#define VAD_BOS_VALUE         @"5000"
#define VAD_EOS_VALUE         @"1800"
#define PLAIN_RESULT_VALUE    @"1"
#define ASR_SCH_VALUE         @"1"

#define TTS_SAMPLE_TEXT       @"       科大讯飞作为中国最大的智能语音技术提供商，在智能语音技术领域有着长期的研究积累、并在中文语音合成、语音识别、口语评测等多项技术上拥有国际领先的成果。科大讯飞是我国唯一以语音技术为产业化方向的“国家863计划成果产业化基地”、“国家规划布局内重点软件企业”、“国家火炬计划重点高新技术企业”、“国家高技术产业化示范工程”，并被信息产业部确定为中文语音交互技术标准工作组组长单位，牵头制定中文语音技术标准。2003年，科大讯飞获迄今中国语音产业唯一的“国家科技进步奖（二等）”，2005年获中国信息产业自主创新最高荣誉“信息产业重大技术发明奖”。2006年至2009年，连续四届英文语音合成国际大赛（Blizzard Challenge ）荣获第一名。2008年获国际说话人识别评测大赛（美国国家标准技术研究院—NIST 2008）桂冠，2009年获得国际语种识别评测大赛（NIST 2009）高难度混淆方言测试指标冠军、通用测试指标亚军"

#define IAT_SAMPLE_USERWORDS   @"{\"userword\":[{\"name\":\"iflytek\",\"words\":[\"德国盐猪手\",\"1912酒吧街\",\"清蒸鲈鱼\",\"挪威三文鱼\",\"黄埔军校\",\"横沙牌坊\",\"科大讯飞\"]}]}"

#define ASR_SAMPLE_ABNFGRAMMAR    @"#ABNF 1.0 UTF-8;\n language zh-CN;\n mode voice;\n root $main;\n $main = $place1 到 $place2;\n $place1 = 北京 | 武汉 | 南京 | 天津 | 天京 |东京;\n $place2 = 上海 | 合肥;\n "

#define ASR_SAMPLE_TIPINFO   @"开始识别前请先点击“上传”按钮上传语法。\n\t上传内容为：\n\t#ABNF 1.0 gb2312;\n\tlanguage zh-CN;\n\tmode voice;\n\troot $main;\n\t$main = $place1 到$place2 ;\n\t$place1 = 北京 | 武汉 | 南京 | 天津 | 天京 | 东京;\n\t$place2 = 上海 | 合肥"

#endif /* Iflytek_Definition_h */
