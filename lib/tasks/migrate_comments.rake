desc 'migrate comments fields to new model'
task :migrate_comments => :environment do 
	Comment.all.each do |comment|
		begin
			if !comment.blog_post_id.nil?
				comment.commentable_id = comment.blog_post_id
				comment.commentable_type = "BlogPost"
				puts "Comment #{comment.id} successfully migrated"
			end
			comment.save
		rescue
			puts "Error migrating comment: #{comment.id}"
		end
	end
end
