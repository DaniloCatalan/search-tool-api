class Developer < ApplicationRecord
  require 'net/http'
  @base_api ='https://api.github.com'

  def self.get_proefiency(user_name)
    proefiency_languages = []

    user_repos = get_user_repositories(user_name)
    total = user_repos.count
    
    languages = user_repos.map { |repo| repo['language'] }.reject(&:blank?)
    grouped_by_name = languages.group_by {|name| name&.split(" ").first.capitalize}
    grouped = grouped_by_name.map{|lang_name, names| [lang_name, names.length]}
    
    grouped.each do |language|
      lang = {
        name: language[0].to_s,
        proefiency: ((language[1].to_f / total) * 100).to_f
      }
      proefiency_languages << lang
    end
    proefiency_languages.sort_by { |l| l[:proefiency] }.reverse!
  end

  def self.get_user_repositories(user_name)
    url = URI("#{@base_api}/users/#{user_name}/repos")
    get_result(url)
  end

  def self.get_user_information(user_name)
    url = URI("#{@base_api}/users/#{user_name}")
    get_result(url) 
  end

  def self.get_by_language(language)
    url = URI("#{@base_api}/search/users?q=language:#{language}")
    get_result(url)
  end

  def self.get_result(url)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)
    request['content-type'] = 'application/x-www-form-urlencoded'

    request.body = url.query

    response = http.request(request)

    return if response.code == 400

    JSON.parse response.read_body if response.is_a?(Net::HTTPSuccess)
  end
  
  def self.get_information(user_name)
    user_information = get_user_information(user_name)

    if user_information
      information = {
        username: user_information['login'],
        name: user_information['name'],
        public_repositories: user_information['public_repos'],
        location: user_information['location'],
        languages: get_proefiency(user_name)
      }
    end
  end
end
