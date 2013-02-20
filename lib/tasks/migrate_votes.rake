desc 'migrate votes fields to new model'
task :migrate_votes => :environment do
	Vote.all.each do |vote|
		begin
			if !vote.blog_post_id.nil?
				vote.post_id = vote.blog_post_id
				vote.post_type = "BlogPost"
			else
				vote.post_id = vote.discussion_post_id
				vote.post_type = "DiscussionPost"
			end

			vote.save
			puts "Vote #{vote.id} successfully migrated"
		rescue
			puts "Error migrating vote: #{vote.id}"
		end
	end
end