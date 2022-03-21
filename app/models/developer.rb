class Developer < ApplicationRecord
  require 'net/http'
  @base_api = 'https://api.github.com'

  has_many :languages, dependent: :destroy
  validates :username, presence: true, uniqueness: { case_sensitive: false }

  # group languages to calculate their proficiency
  def self.get_proefiency(user_name)
    user_repos = get_user_repositories(user_name)

    languages = user_repos.map { |repo| repo['language'] }.reject(&:blank?)
    grouped_by_name = languages.group_by { |name| name.split(' ').first.capitalize }
    grouped = grouped_by_name.map { |lang_name, names| [lang_name, names.length] }

    calculate_prcentaje(grouped, user_repos.count)
  end

  # calculates percentage depending on the repositories present
  def self.calculate_prcentaje(grouped, total)
    proefiency_languages = []
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

  def self.get_developers_by_language(language)
    Developer.joins(:languages).where('languages.name like ?', "%#{language}%")
  end

  # used for all requests
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

  # hash return so that it can then be stored
  def self.get_information(user_name)
    user_information = get_user_information(user_name)
    return if user_information.nil?

    {
      username: user_information['login'],
      name: user_information['name'],
      repositories: user_information['public_repos'].to_i,
      location: user_information['location'],
      languages: get_proefiency(user_name)
    }
  end
end
