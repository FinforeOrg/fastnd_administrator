# Module Extention for user_feed.rb
# Additional Modules: none
# The extention includes:
#   * Auto score feed_info as +1 and mark as follower if user add feed_info to their account
#   * Auto unscore feed_info as -1 and unmark as follower if user remove feed_info from their account
module Finforenet
  module Models
    module ExtUserFeed
      extend ActiveSupport::Concern
      
      included do
        after_create  :after_creation
        after_destroy :after_deletion
      end

      private
        def after_creation
          user, source = update_feed_info_score(1)
          user.follow(source) if source && !user.follower_of?(source)
        end

        def after_deletion
          user, source = update_feed_info_score(-1)
          user.unfollow(source) if source && user.follower_of?(source)
        end

        def update_feed_info_score(score)
          user = feed_account.user
          source = self.feed_info
          source.vote score, user if can_score_feed_info?(source, user, score)
          return user, source
        end

        def can_score_feed_info?(source, user, score)
          source && ((score > 0 && !source.voted?(user)) || (score < 0 && source.voted?(user)))
        end

    end
  end
end