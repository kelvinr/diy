module Voteable
  def counter(params)
    params == 'true' ? self.increment!(:vote_count) : self.decrement!(:vote_count)
  end

  def check_vote(user)
    @current_vote ||= self.votes.find_by creator: user
  end

  def change_vote(params)
    self.counter(params) if @current_vote.vote.to_s != params
    @current_vote.update(vote: params)
  end
end
