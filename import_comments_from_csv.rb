require 'csv'
require_relative './config/environment'

module ImportCommentsFromCSV
  def self.import(csv_file_path)
    CSV.foreach(csv_file_path, headers: true) do |row|
      post = Post.find_by(slug: row['Post Slug'])
      user = User.find_or_create_by(name: row['User Name'], email: row['User Email'])

      if post
        comment = Comment.new(
          content: row['Content'],
          post: post,
          user: user
        )

        unless comment.save
          # puts "Failed to import comment for post: #{post.title}. Errors: #{comment.errors.full_messages.join(', ')}"
          # Decided to write everything in log file as it is to much errors
          log_error("Failed to import comment for post: #{post.title}. Errors: #{comment.errors.full_messages.join(', ')}")
        end
      else
        log_error("Post with slug '#{row['Post Slug']}' not found.")
      end
    end
  end
end

def log_error(message)
  File.open('import_comments_log.txt', 'a') do |file|
    file.puts(message)
  end
end

if __FILE__ == $PROGRAM_NAME
  csv_file_path = 'comments.csv'.freeze
  ImportCommentsFromCSV.import(csv_file_path)
end

# Some points about the script
#
# Probably in production more detailed logging is required
# What about comments duplicates?
# What should we do with unsaved comments? Probably they should be stored ins separate CSV for manual review?
# How should it be done? probably some delay jobs
# Should we use concurrency to speed up the process?
