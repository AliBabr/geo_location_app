# cronotab.rb — Crono configuration file
#
# Here you can specify periodic jobs and schedule.
# You can use ActiveJob's jobs from `app/jobs/`
# You can use any class. The only requirement is that
# class should have a method `perform` without arguments.
#
# class TestJob
#   def perform
#     puts 'Test!'
#   end
# end
#
# Crono.perform(TestJob).every 2.days, at: '15:30'
#


require "rake"

Rails.app_class.load_tasks

class Test
  def perform
    
    all_bookings = Booking.where(booking_status: "active")
    all_bookings.each do |booking|
      if booking.start_time.present? && booking.start_time.today?
        start_time = booking.start_time.present? ? booking.start_time : Time.now
        time_diff = (Time.now - start_time)/60
        if time_diff < 17 && time_diff > 13
          coach = User.find(booking.coach_id)
          student = booking.user
          session_name = booking.lesson.present? ?  booking.lesson.title : ''

          coach_registration_ids = coach.fcm_token.present? ? coach.fcm_token : 1
          PushNotification.new(coach, 'Start Session ',  session_name + " with " + student.name + "  will start in 15 minutes", 'Session' ).send_notification([coach_registration_ids])

          registration_ids = student.fcm_token.present? ? student.fcm_token : 1
          PushNotification.new(student, 'Start Session',  session_name + " with " + coach.name + " will start in 15 minutes", 'Session' ).send_notification([registration_ids])
          
        end 

      end
    end
    Rake::Task["crono:hello"].invoke
  end
end

Crono.perform(Test).every 3.minutes
