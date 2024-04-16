#!/usr/bin/env ruby
# frozen_string_literal: true

require 'net/http'
require 'json'
require 'io/console'
require 'base64'

# SppotifyStatus class for getting the status of the Spotify API
class SpotifyStatus
  attr_reader :base_url, :access_token

  def initialize
    load_dotenv
    @client_id = ENV['SPOTIFY_CLIENT_ID']
    @secret = ENV['SPOTIFY_SECRET']
    @redirect_uri = 'http://localhost:8080'

    raise 'Client ID or secret not found in environment variables' unless @client_id && @secret
  end

  def now_playing
    authorize unless File.exist?('credentials')
    access_token = read_credentials

    uri = URI('https://api.spotify.com/v1/me/player/currently-playing')
    request = Net::HTTP::Get.new(uri)
    request['Authorization'] = "Bearer #{access_token}"
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    if response.code == '200'
      json_response = JSON.parse(response.body)
      icon = json_response['is_playing'] ? '' : ''
      "#{icon} #{json_response['item']['name']} by #{json_response['item']['artists'][0]['name']}"
    elsif response.code == '204'
      ' No music playing'
    else
      "Error getting currently playing; response #{response.code}"
    end
  end

  private

  def authorize
    uri = URI('https://accounts.spotify.com/authorize')
    params = {
      'client_id' => @client_id,
      'response_type' => 'code',
      'redirect_uri' => @redirect_uri,
      'scope' => 'user-read-playback-state user-read-currently-playing'
    }
    uri.query = URI.encode_www_form(params)
    response = Net::HTTP.get_response(uri)

    if response.is_a?(Net::HTTPRedirection)
      puts "Please visit the following URL to authorize the application:\n\n"
      puts uri
      puts "\nand Enter the code from the URL:"

      code = gets.chomp
      token(code)
    else
      puts "Error getting authorization URL; response #{response.code}"
    end
  end

  def load_dotenv
    return unless File.exist?('~/.env')

    dotenv_path = File.expand_path('.env', __dir__)
    File.readlines(dotenv_path).each do |line|
      key, value = line.strip.split('=')
      ENV[key] = value if key && value
    end
  end

  def new_token(refresh_token)
    uri = URI("https://accounts.spotify.com/api/token")
    request = Net::HTTP::Post.new(uri)
    params = {
      "grant_type" => "refresh_token",
      "refresh_token" => refresh_token,
    }
    auth_string = Base64.strict_encode64("#{@client_id}:#{@secret}")
    request['Authorization'] = "Basic #{auth_string}"
    request["Content-Type"] = "application/x-www-form-urlencoded"
    request.set_form_data(params)

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    raise "Error: #{response.code}" unless response.code == '200'

    data = JSON.parse(response.body)
    unless data["refresh_token"]
      data["refresh_token"] = refresh_token
    end
      
    File.open("credentials", "w") do |file|
      file.puts(JSON.dump(data))
    end

    data["access_token"]
  end

  def read_credentials
    data = JSON.parse(File.read('credentials'))
    expires_in = data['expires_in']
    token_file_last_modified = File.mtime('credentials')

    expiry_time = token_file_last_modified + expires_in
    if Time.now >= expiry_time
      new_token(data['refresh_token'])
    else
      data['access_token']
    end
  end

  def token(code)
    uri = URI('https://accounts.spotify.com/api/token')
    request = Net::HTTP::Post.new(uri)
    params = {
      'grant_type' => 'authorization_code',
      'code' => code,
      'redirect_uri' => @redirect_uri
    }
    auth_string = Base64.strict_encode64("#{@client_id}:#{@secret}")
    request['Content-Type'] = 'application/x-www-form-urlencoded'
    request['Authorization'] = "Basic #{auth_string}"
    request.set_form_data(params)

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    raise "Error: #{response.code}" unless response.code == '200'

    File.open('credentials', 'w') do |file|
      file.puts(response.body)
    end
  end
end

puts SpotifyStatus.new.now_playing
