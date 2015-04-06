class AddVoteCountToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :vote_count, :integer, default: 0
    add_column :comments, :vote_count, :integer, default: 0
  end
end
