describe Fastlane::Actions::WorkWechatAction do
  describe '#run' do

    webhook = 'https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=2333'

    it 'send text massage' do
      expect(Fastlane::UI).to receive(:message).with("The work_wechat plugin is working!")
      Fastlane::Actions::WorkWechatAction.run(
        webhook_URL: webhook,
        text_content: '测试纯文本发送'
      )
    end

    it 'send markdown massage' do
      expect(Fastlane::UI).to receive(:message).with("The work_wechat plugin is working!")
      Fastlane::Actions::WorkWechatAction.run(
        webhook_URL: webhook,
        markdown_content: '# markdown 消息类型测试'
      )
    end

    it 'send news massage' do
      expect(Fastlane::UI).to receive(:message).with("The work_wechat plugin is working!")
      Fastlane::Actions::WorkWechatAction.run(
        webhook_URL: webhook,
        news_title: 'news消息类型测试',
        news_description: 'description信息',
        news_url: 'https://www.pgyer.com/devzhang',
        news_picurl: 'https://www.pgyer.com/app/qrcode/devzhang'
      )
    end
  end
end
