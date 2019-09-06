module Fastlane
  module Actions
    module SharedValues
      DINGDINGTALK_ROBOT_CUSTOM_VALUE = :DINGDINGTALK_ROBOT_CUSTOM_VALUE
    end

    class DingdingtalkRobotAction < Action
      def self.run(params)
        # fastlane will take care of reading in the parameter and fetching the environment variable:
        # UI.message "Parameter API Token: #{params[:api_token]}"
        # sh "shellcommand ./path"
        # Actions.lane_context[SharedValues::DINGDINGTALK_ROBOT_CUSTOM_VALUE] = "my_val"
        appPath = params[:appPath]
        appUrl = params[:appUrl]
        appIcon = params[:appIcon]
        dingUrl = params[:dingUrl]
        markdownText = params[:markdownText]

        appName    = other_action.get_ipa_info_plist_value(ipa: appPath, key: "CFBundleDisplayName")
        appVersion = other_action.get_ipa_info_plist_value(ipa: appPath, key: "CFBundleShortVersionString")
        appBuild   = other_action.get_ipa_info_plist_value(ipa: appPath, key: "CFBundleVersion")
        ipaName    = other_action.get_ipa_info_plist_value(ipa: appPath, key: "CFBundleName")#备用

        appName = appName.empty? == false ? appName : other_action.get_ipa_info_plist_value(ipa: appPath, key: "CFBundleBundleName")

        platformInfo = appPath.include?("fir") == true ? "已更新至fir" : "已上传至AppStoreConnect"

        title = "iOS #{appName} #{appVersion} #{platformInfo}"

        markdown ={
          msgtype: "link",
          link: {
              title: title,
              text: "版  本：#{appBuild}\n地  址：#{appUrl}\n时  间：#{Time.new.strftime('%Y-%m-%d %H:%M')}",
              picUrl: "#{appIcon}",
              messageUrl: "#{appUrl}"
          }
        }

        if markdownText
          markdownText = "#{markdownText}   \n  - [Download](#{appUrl})"
          markdown ={
               "msgtype": "markdown",
               "markdown": {"title": "#{title}",
                            "text": "### #{title}\n#{markdownText}",
               }
           }
        end

        uri = URI.parse(dingUrl)
        https = Net::HTTP.new(uri.host, uri.port)
        https.use_ssl = true

        request = Net::HTTP::Post.new(uri.request_uri)
        request.add_field('Content-Type', 'application/json')
        request.body = markdown.to_json

        response = https.request(request)
        puts "-----------#{uri.request_uri}-------------------"
        puts "Response #{response.code} #{response.message}: #{response.body}"
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "A short description with <= 80 characters of what this action does"
      end

      def self.details
        # Optional:
        # this is your chance to provide a more detailed description of this action
        "You can use this action to do cool things..."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :appPath,
                                     env_name: "GET_IPA",
                                  description: "ipa文件所在的文件夹路径",
                                     optional: false,
                                         type: String),
             FastlaneCore::ConfigItem.new(key: :appUrl,
                                  description: "fir的ipa文件下载网址",
                                     optional: false,
                                         type: String),
             FastlaneCore::ConfigItem.new(key: :appIcon,
                                  description: "ipa图标网络地址",
                                     optional: true,
                                         type: String),
             FastlaneCore::ConfigItem.new(key: :dingUrl,
                                  description: "钉钉机器人网络接口",
                                     optional: false,
                                         type: String),
             FastlaneCore::ConfigItem.new(key: :markdownText,
                                  description: "钉钉机器人 msgtype: markdown时的text",
                                     optional: true,
                                         type: String),
        ]
      end

      def self.output
        # Define the shared values you are going to provide
        # Example
        [
          ['DINGDINGTALK_ROBOT_CUSTOM_VALUE', 'A description of what this value contains']
        ]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.authors
        # So no one will ever forget your contribution to fastlane :) You are awesome btw!
        ["Your GitHub/Twitter Name"]
      end

      def self.is_supported?(platform)
        # you can do things like
        #
        #  true
        #
        #  platform == :ios
        #
        #  [:ios, :mac].include?(platform)
        #

        platform == :ios
      end
    end
  end
end
