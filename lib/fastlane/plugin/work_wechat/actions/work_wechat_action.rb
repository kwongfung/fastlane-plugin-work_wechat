require 'fastlane/action'
require_relative '../helper/work_wechat_helper'

module Fastlane
  module Actions
    class WorkWechatAction < Action
      require 'net/http'
      require 'net/https'
      require 'json'

      def self.run(params)
        UI.message("The work_wechat plugin is working!")
        webhook = params[:webhook_URL]
        puts "webhook = #{webhook}"
        url = URI(webhook)
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true if url.scheme == 'https'

        headers = { 'Content-Type' => 'application/json' }
        request = Net::HTTP::Post.new(url, headers)

        if params[:markdown_content]
          request.body = markdown_http_body(params)
        elsif params[:image_base64]
          request.body = image_http_body(params)
        elsif params[:news_title]
          request.body = news_http_body(params)
        elsif params[:text_content]
          request.body = text_http_body(params)
        end
        puts http.request(request).body
      end

      def self.text_http_body(params)
        content = params[:text_content]
        mentioned_list = params[:mentioned_list]
        mentioned_mobile_list = params[:mentioned_mobile_list]

        body = {}
        body['msgtype'] = "text"
        
        # 1、文本类型
        # {
        #   "msgtype": "text",
        #   "text": {
        #       "content": "广州今日天气：29度，大部分多云，降雨概率：60%",
        #       "mentioned_list":["devzhang","@all"],
        #       "mentioned_mobile_list":["13800001111","@all"]
        #   }
        # }

        text = { 'content' => content }
        text['mentioned_list'] = mentioned_list if mentioned_list
        text['mentioned_mobile_list'] = mentioned_mobile_list if mentioned_mobile_list
        body['text'] = text
        body.to_json
      end

      def self.markdown_http_body(params)
        markdown_content = params[:markdown_content]
        body = {}
        body['msgtype'] = "markdown"
        
      #   {
      #     "msgtype": "markdown",
      #     "markdown": {
      #         "content": "实时新增用户反馈<font color=\"warning\">132例</font>，请相关同事注意。\n
      #          >类型:<font color=\"comment\">用户反馈</font>
      #          >普通用户反馈:<font color=\"comment\">117例</font>
      #          >VIP用户反馈:<font color=\"comment\">15例</font>"
      #     }
      # }

        markdown = { 'content' => markdown_content }
        body['markdown'] = markdown
        body.to_json
      end

      def self.image_http_body(params)
        image_base64 = params[:image_base64]
        image_md5 = params[:image_md5]

        body = {}
        body['msgtype'] = "image"
        
      #   {
      #     "msgtype": "image",
      #     "image": {
      #         "base64": "DATA",
      #         "md5": "MD5"
      #     }
      # }

        image = { 'base64' => image_base64,'md5' => image_md5 }
        body['image'] = image
        body.to_json
      end

      def self.news_http_body(params)
        news_title = params[:news_title]
        news_description = params[:news_description]
        news_url = params[:news_url]
        news_picurl = params[:news_picurl]



        body = {}
        body['msgtype'] = "news"
        
      #   {
      #     "msgtype": "news",
      #     "news": {
      #        "articles" : [
      #            {
      #                "title" : "中秋节礼品领取",
      #                "description" : "今年中秋节公司有豪礼相送",
      #                "url" : "www.qq.com",
      #                "picurl" : "http://res.mail.qq.com/node/ww/wwopenmng/images/independent/doc/test_pic_msg1.png"
      #            }
      #         ]
      #     }
      # }
        article = { 'title'=>news_title, 'url'=>news_url}
        article['description'] = news_description if news_description
        article['picurl'] = news_picurl if news_picurl
        articles = [article]
        body['news'] = {'articles'=>articles}
        body.to_json
      end

      def self.description
        "work wecaht webhook"
      end

      def self.authors
        ["DevZhang"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
        "send message via work wechat server api"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :webhook_URL,
                               description: "机器人的webhook地址",
                                  optional: false,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :text_content,
                               description: "文本内容，最长不超过2048个字节，必须是utf8编码",
                                  optional: false,
                                      type: String,
                       conflicting_options:[:markdown_content,:image_base64,:image_md5,:news_title,:news_description,:news_url,:news_picurl]),
          FastlaneCore::ConfigItem.new(key: :text_mentioned_list,
                               description: "userid的列表，提醒群中的指定成员(@某个成员)，@all表示提醒所有人，如果开发者获取不到userid，可以使用mentioned_mobile_list",
                                  optional: true,
                                      type: Array,
                       conflicting_options:[:markdown_content,:image_base64,:image_md5,:news_title,:news_description,:news_url,:news_picurl]),
          FastlaneCore::ConfigItem.new(key: :text_mentioned_mobile_list,
                               description: "手机号列表，提醒手机号对应的群成员(@某个成员)，@all表示提醒所有人",
                                  optional: true,
                                      type: Array,
                       conflicting_options:[:markdown_content,:image_base64,:image_md5,:news_title,:news_description,:news_url,:news_picurl]),
          FastlaneCore::ConfigItem.new(key: :markdown_content,
                               description: "markdown内容，最长不超过4096个字节，必须是utf8编码",
                                  optional: false,
                                      type: String,
                       conflicting_options:[:text_content,:text_mentioned_list,:text_mentioned_mobile_list,:image_base64,:image_md5,:news_title,:news_description,:news_url,:news_url,:news_picurl]),
          FastlaneCore::ConfigItem.new(key: :image_base64,
                               description: "图片内容的base64编码",
                                  optional: false,
                                      type: String,
                       conflicting_options:[:text_content,:text_mentioned_list,:text_mentioned_mobile_list,:markdown_content,:news_title,:news_description,:news_url,:news_url,:news_picurl]),
          FastlaneCore::ConfigItem.new(key: :image_md5,
                               description: "图片内容（base64编码前）的md5值",
                                  optional: false,
                                      type: String,
                       conflicting_options:[:text_content,:text_mentioned_list,:text_mentioned_mobile_list,:markdown_content,:news_title,:news_description,:news_url,:news_url,:news_picurl]),
          FastlaneCore::ConfigItem.new(key: :news_title,
                               description: "标题，不超过128个字节，超过会自动截断",
                                  optional: false,
                                      type: String,
                       conflicting_options:[:text_content,:text_mentioned_list,:text_mentioned_mobile_list,:markdown_content,:image_base64,:image_md5]),
          FastlaneCore::ConfigItem.new(key: :news_description,
                               description: "描述，不超过512个字节，超过会自动截断",
                                  optional: true,
                                      type: String,
                       conflicting_options:[:text_content,:text_mentioned_list,:text_mentioned_mobile_list,:markdown_content,:image_base64,:image_md5]),
          FastlaneCore::ConfigItem.new(key: :news_url,
                               description: "点击后跳转的链接。",
                                  optional: false,
                                      type: String,conflicting_options:[:text_content,:text_mentioned_list,:text_mentioned_mobile_list,:markdown_content,:image_base64,:image_md5]),
          FastlaneCore::ConfigItem.new(key: :news_picurl,
                               description: "图文消息的图片链接，支持JPG、PNG格式，较好的效果为大图 1068*455，小图150*150。",
                                  optional: true,
                                      type: String,conflicting_options:[:text_content,:text_mentioned_list,:text_mentioned_mobile_list,:markdown_content,:image_base64,:image_md5])
        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://docs.fastlane.tools/advanced/#control-configuration-by-lane-and-by-platform
        #
        # [:ios, :mac, :android].include?(platform)
        true
      end
    end
  end
end
