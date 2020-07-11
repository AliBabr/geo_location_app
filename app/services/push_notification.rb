# app/services/PushNotification.rb
class PushNotification
  def initialize(current_user, title, message, type)
    @current_user = current_user
    
    @options = {}

    @options[:notification] = {}
    @options[:notification][:title] = title
    @options[:notification][:body] = message
    @options[:notification][:type] = type
    @options[:notification][:content_available] = true
  
    @options[:data] = {}
    @options[:data][:title] = title
    @options[:data][:message] = message
    @options[:data][:type] = type
    @options[:data][:content_available] = true
    puts @options.inspect

  end

  def send_notification(registration_ids)
    fcm = FCM.new("AIzaSyCh2bV09Kdjxig-bwnmPfZNNtPDdo4tHN4")
    response = fcm.send(registration_ids, @options)
    puts response.inspect
    response
  end

end


# registration_ids = @current_user.fcm_token.present? ? @current_user.fcm_token : 1
# PushNotification.new(@current_user, 'New Message', 'New message been received', 'chat' ).send_notification([registration_ids])