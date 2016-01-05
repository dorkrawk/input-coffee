require 'sinatra/base'
require 'json'

require_relative 'models/coffee_post'

module InputCoffee
  class App < Sinatra::Base

    get '/' do
      @posts = CoffeePost.get_coffee
      @counts = subject_count(@posts)
      @hours = subject_hours(@posts)
      @this_week = @posts.select { |p| is_this_week?(p) }
      @week_counts = subject_count(@this_week)
      @week_hours = subject_hours(@this_week)
      @last_week = @posts.select { |p| is_last_week?(p) }
      @last_week_counts = subject_count(@last_week)
      @last_week_hours = subject_hours(@last_week)

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

      def subjects
        @posts.map(&:subject).compact
      end

      def subject_count(posts, start_date = nil, end_date = nil)
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

      def subject_hours(posts, start_date = nil, end_date = nil)
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

      def is_this_week?(post)
        now = DateTime.now
        (Date.commercial(now.cwyear, now.cweek, 1)..Date.commercial(now.cwyear, now.cweek, 7)).cover?(post.date.to_date)
      end

      def is_last_week?(post)
        a_week_ago = DateTime.now - 7
        (Date.commercial(a_week_ago.cwyear, a_week_ago.cweek, 1)..Date.commercial(a_week_ago.cwyear, a_week_ago.cweek, 7)).cover?(post.date.to_date)
      end

    end
  end
end