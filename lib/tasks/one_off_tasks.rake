desc "Calculates profile completeness score for each member profile"
task :update_profile_completeness_scores => :environment do
  puts "Updating profile completeness score for all members"
  EtkhProfile.all.each do |profile|
    profile.completeness_score = profile.get_profile_completeness
    profile.save
  end
  puts "done."
end

desc 'One-off task to fix personal website bug'
task :fix_personal_website_bug => :environment do 
  puts "Starting..."
  User.all.each do |user|
    if user.external_website
      if user.external_website && !user.external_website.empty? && user.external_website[0..6] != "http://" && user.external_website[0..7] != "https://"
        new_address = "http://" + user.external_website
        user.update_attributes(external_website: new_address)
      end
    end
  end
  puts "Done."
end

task :read_memcache_list => :environment do 
  require 'net/telnet'
 
  cache_dump_limit = 100
  localhost = Net::Telnet::new("Host" => "localhost", "Port" => 11211, "Timeout" => 3)
  slab_ids = []
  localhost.cmd("String" => "stats items", "Match" => /^END/) do |c|
    matches = c.scan(/STAT items:(\d+):/)
    slab_ids = matches.flatten.uniq
  end
   
   
  puts
  puts "Expires At\t\t\t\tCache Key"
  puts '-'* 80 
  slab_ids.each do |slab_id|
    localhost.cmd("String" => "stats cachedump #{slab_id} #{cache_dump_limit}", "Match" => /^END/) do |c|
      matches = c.scan(/^ITEM (.+?) \[(\d+) b; (\d+) s\]$/).each do |key_data|
       (cache_key, bytes, expires_time) = key_data
       humanized_expires_time = Time.at(expires_time.to_i).to_s     
      puts "[#{humanized_expires_time}]\t#{cache_key}"
      end
    end  
  end
  puts
   
  localhost.close
end