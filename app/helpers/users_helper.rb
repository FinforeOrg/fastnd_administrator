module UsersHelper
  def menu_edit_user(user)
    submenus = '<ul class="section_menu left form_tab">'
      submenus << "<li>"
        submenus << main_menu("Edit","/users/#{user.id}/edit","edit,update".include?(controller.action_name) ? true : false, true)
      submenus << "</li>"
      submenus << "<li>"
        submenus << main_menu("Columns","/users/#{user.id}/columns",controller.action_name == "columns" ? true : false, true)
      submenus << "</li>"
      submenus << "<li>"
        submenus << main_menu("Company Tabs","/users/#{user.id}/company_tabs",controller.action_name == "company_tabs" ? true : false, true)
      unless user.new_record?
        submenus << "<li>"
          submenus << main_menu("Histories","/users/#{user.id}/histories",controller.action_name == "histories" ? true : false, true)
        submenus << "</li>"
      end
    submenus << "</ul>"
    submenus.html_safe
  end

  def is_public(user)
    style = user.is_public ? "on_tab" : "add_tab"
    link_to image_tag("layout/space.png",:class=>style,:border=>0),update_public_user_path(user),:class=>"ct_status"
  end

  def detail_activity(activity)
    actor = activity.actor
    actor_name = actor ? actor.full_name.titleize : "Some One"
    humanize_activity(activity, actor, actor_name)
   rescue
     return ""
  end

  def humanize_activity(activity, actor, actor_name)
    if activity.scope == "feed_account"
      return <<-STRING
        #{actor_name} #{activity.action} #{activity.modified["category"]} column with title #{activity.modified["name"]}
      STRING
    elsif activity.scope == "user_company_tab"
      feed_info = FeedInfo.find(activity.modified["feed_info_id"]) if activity.modified["feed_info_id"].present?
      company_name = feed_info ? feed_info.title.titleize : "a"
      return "#{actor_name} #{activity.action} #{company_name} company"
    elsif activity.scope == "user"
      return <<-STRING
        #{actor_name} #{activity.action} user with full name #{activity.modified["full_name"]}
      STRING
    elsif activity.scope == "user_profile"
      return ""
      # profile_owner = User.find(activity.modified["user_id"])
      # owner_name = profile_owner ? profile_owner.full_name : "(user deleted)"
      # return "#{actor_name} #{activity.action} profile from user with full name #{owner_name}"
    elsif activity.scope == "user_feed"
      column_name = "a"
      feed_name = "a"

      if activity.modified["feed_account_id"].present?
        account = FeedAccount.find(activity.modified["feed_account_id"])
        feed_name = activity.modified["title"]
      end

      if account
        column_name = account.name
        feed_name = account.category
      end

      unless feed_name.present?
        feed_info = FeedInfo.find(activity.modified["feed_info_id"])
        feed_name = feed_info.title
      end if activity.modified["feed_info_id"].present?

      return <<-STRING
        #{actor_name} #{activity.action} #{feed_name} feed for #{column_name} column
      STRING
    elsif activity.scope == "access_token"
      connection_name = activity.action.gsub("destroy", "disconnect").gsub("create", "connect")
      appendix_connection = connection_name == "connect" ? "to" : "from"
      return <<-STRING
        #{actor_name} #{activity.action} #{activity.modified["category"]} #{appendix_connection} account
      STRING
    elsif activity.scope == "user"
      if activity.action == "create"
        return <<-STRING
          #{activity.modified["full_name"]} just join
        STRING
      else
        return ""
      end
    else
      ""
    end
      
  end

end

# <HistoryTracker _id: 51307c8f27c48e604b00000d, 
# _type: nil, 
# created_at: 2013-03-01 10:01:51 UTC, 
# updated_at: 2013-03-01 10:01:51 UTC, 
# association_chain: [{"name"=>"FeedAccount", "id"=>BSON::ObjectId('51307c8f27c48e604b00000b')}], 
# modified: {
#   "window_type"=>"tab", 
#   "position"=>-1, 
#   "name"=>"ItalyAllFF", 
#   "category"=>"twitter", 
#   "user_id"=>BSON::ObjectId('512fce1e27c48e2be7001268')}, 
#   original: {}, 
#   version: 1, 
#   action: "create", 
#   scope: "feed_account", 
#   modifier_id: BSON::ObjectId('512fce1e27c48e2be7001268')>
