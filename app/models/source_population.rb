class SourcePopulation
  include Mongoid::Document
  include Mongoid::Timestamps
  
  # 3 fields below are shortcut fields to find population instead of profile_ids
  field :country_ids,    type: Array
  field :sector_ids,     type: Array
  field :profession_ids, type: Array

  # profile ids is field to store selected profiles for population
  field :profile_ids,    type: Array
  
  # it is a category of population (Rss, Podcast, Company, Twitter)
  field :category,       type: String
  # list of sources from feed_info that are marked as population
  # it should be list of feed_info_ids
  field :sources,        type: Array

end