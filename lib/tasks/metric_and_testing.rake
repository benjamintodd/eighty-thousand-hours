namespace :donations do
  desc 'Calculates the percentage of members who have opted-in for donation declaration since a specified date'
  task :opted_in, [:day, :month, :year] => :environment do |t, args|
    # get start_date from args
    start_date = DateTime.new(args[:year].to_i, args[:month].to_i, args[:day].to_i)
    
    puts "Getting members who joined since #{start_date}"

    # get all members who have signed up since date argument
    members = User.where("created_at >= :start_date", start_date: start_date)

    # cycle through members and calculate percentage
    opted_in = 0
    opted_out = 0
    members.each do |member|
      if member.etkh_profile
        member.etkh_profile.donation_percentage_optout ? opted_out+=1 : opted_in+=1
      end
    end

    percentage_opted_in = opted_in.to_f / members.length.to_f * 100
    puts "Percentage opted in: #{percentage_opted_in}"
  end

  desc 'Calculates the median donation percentage value for members who have opted-in, after a certain date'
  task :median, [:day, :month, :year] => :environment do |t, args|
    # get start_date from args
    start_date = DateTime.new(args[:year].to_i, args[:month].to_i, args[:day].to_i)
    
    puts "Getting members who joined since #{start_date}"

    # get all members who have signed up since date argument
    members = User.where("created_at >= :start_date", start_date: start_date)

    # cycle through members and create array of donation percentage values
    donations = []
    members.each do |member|
      if member.etkh_profile
        if member.etkh_profile.donation_percentage_optout == false
          donations << member.etkh_profile.donation_percentage
        end
      end
    end

    # sort values into order
    donations.sort

    # calculate median
    median = donations[donations.length/2]

    puts "Sample size: #{donations.length}"
    puts "Median donation percentage: #{median}"
  end
end