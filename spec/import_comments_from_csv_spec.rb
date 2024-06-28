# spec/import_comments_spec.rb
require 'rails_helper'
require 'csv'
require_relative '../import_comments_from_csv'

RSpec.describe ImportCommentsFromCSV, type: :model do
  subject { ImportCommentsFromCSV.import(csv_file_path) }

  let(:csv_file_path) { 'spec/fixtures/comments.csv' }

  before do
    @post = Post.create(title: "Sample Post", content: "This is a sample post.", slug: "sample-post", user: User.create(name: "Author", email: "author@example.com"), category: Category.create(name: "Sample Category"))
  end

  describe '#import' do
    context 'when data is valid' do
      context 'when user exists' do
        it 'imports comments successfully' do
          expect { subject }.to change { Comment.count }.by(1)
        end

        it 'associates the comment with the correct post and user' do
          subject

          comment = Comment.last
          expect(comment.post.slug).to eq('sample-post')
          expect(comment.user.email).to eq('author@example.com')
        end
      end

      context 'when user doesn\'t exist' do
        let(:csv_file_path) { 'spec/fixtures/invalid_user_data.csv' }

        it 'creates a user if not found and associates the comment' do
          expect { subject }.to change { Comment.count }.by(1)
                            .and change { User.count }.by(1)
        end
      end
    end

    context 'when data is invalid' do
      context 'when post slug is invalid' do
        let(:csv_file_path) { 'spec/fixtures/invalid_post_slug.csv' }

        it 'does not create a comment' do
          expect { subject }.not_to change { Comment.count }
        end

        it 'logs an error' do
          expect(ImportCommentsFromCSV).to receive(:log_error).with("Post with slug 'nonexistent-slug' not found.")
          subject
        end
      end

      context 'when comment contains forbidden word' do
        let(:csv_file_path) { 'spec/fixtures/invalid_comment_content.csv' }

        it 'does not create a comment' do
          expect { subject }.not_to change { Comment.count }
        end

        it 'logs an error' do
          expect(ImportCommentsFromCSV).to receive(:log_error).with('Failed to import comment for post: Sample Post. Errors: Content contains prohibited keyword: et')
          subject
        end
      end
    end
  end
end
