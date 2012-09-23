module Finforenet
  module Models
    module Revise

      def self.update_feed_info_follower
        user_feeds = UserFeed.all
        user_feeds.each do |user_feed|
          user_feed.send(:after_creation)
        end
      end

      def self.update_feed_info_follower_by_user_company
      end

    end
  end
end