require 'sinatra/base'
require 'json'

require_relative 'models/coffee_post'

module InputCoffee
  class App < Sinatra::Base

    get '/' do
      @posts = CoffeePost.get_coffee
      @counts = subject_count
      @hours = subject_hours

      erb :index
    end

    get '/:date/:subject' do
      post_filename = "#{params[:date]}-#{params[:subject]}.md"

      post = CoffeePost.build_post(post_filename)

      content_type :json
      post.to_json
    end

    get '/hours' do
      hours = subject_hours

      content_type :json
      hours.to_json
    end

    helpers do

      def posts
        @posts ||= CoffeePost.get_coffee
      end

      def subject_count(start_date = nil, end_date = nil)
        subject_count = {}
        posts.each do |post|
          if subject_count.has_key?(post.subject)
            subject_count[post.subject] += 1
          else
            subject_count[post.subject] = 1
          end
        end

        subject_count
      end

      def subject_hours(start_date = nil, end_date = nil)
        subject_hours = {}
        posts.each do |post|
          if subject_hours.has_key?(post.subject)
            subject_hours[post.subject] += post.hours
          else
            subject_hours[post.subject] = post.hours
          end
        end

        subject_hours
      end

    end
  end
end