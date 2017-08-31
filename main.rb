require 'slack-ruby-bot'

NGINX_LOG = '/var/log/nginx/access.log'
DB_LOG = '/var/log/mysql/query.log'

Slack.configure do |config|
  config.token = ENV['SLACK_API_TOKEN']
end

client = Slack::Web::Client.new
fail 'auth failed : invalid token' unless client.auth_test

rtm_client = Slack::RealTime::Client.new

rtm_client.on :message do |data|
  case data.text
  when 'kataribe' then
    file_path = kataribe
    client.files_upload(
      channels: data.channel,
      as_user: true,
      file: Faraday::UploadIO.new(file_path, 'text'),
      title: 'Kataribe Result',
      filename: "kataribe-#{Time.now.format('%H-%m')}.txt"
    )
  when 'querylog' then
    file_path = DB_LOG
    client.files_upload(
      channels: data.channel,
      file: Faraday::UploadIO.new(file_path, 'text'),
      title: 'MySQL QueryLog',
      filename: 'querylog.log'
    )
  when 'resetlog' then
    reset_log
    client.message channel: data.channel, text: 'ログを消去しました'
  else
    help_message = <<-"EOS"
      isucon-slacl-bot　(´・ω・｀)
      command :
        "kataribe" : nginxのアクセスログを解析,結果を添付
　　　　"querylog" : mysqlのクエリログを添付します
        "resetlog" : ログファイルを消去
    EOS
    client.message channel: data.channel, text: help_message
  end
end


def reset_log
  File.delete NGINX_LOG
  `systemctl restart nginx`
  File.delete DB_LOG
end

def kataribe
  file_name = "res/kataribe-#{Time.now.format('%H-%M')}"
  File.open(file_name, 'w') do |f|
    log_path = '/var/log/nginx/access.log'
    kataribe_path = './kataribe'
    cmd = "cat #{log_path} | #{kataribe_path}"

    f.puts(`#{cmd}`)
  end
  file_name
end