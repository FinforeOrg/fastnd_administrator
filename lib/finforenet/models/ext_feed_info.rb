module Finforenet
  module Models
    module ExtFeedInfo
      extend ActiveSupport::Concern
      
      included do
        include Mongoid::Voteable
        include Mongoid::Followable
      end

      def profiles
        Profile.find(self.feed_info_profiles.map(&:profile_id))
      end

    end
  end
end