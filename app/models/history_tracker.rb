class HistoryTracker
  include Mongoid::History::Tracker

  def actor
    result = modifier
    return result if modifier.present?
    AdminCore.find(modifier_id)
  end
end