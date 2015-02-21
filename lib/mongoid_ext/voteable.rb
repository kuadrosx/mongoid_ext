module MongoidExt
  module Voteable
    extend ActiveSupport::Concern

    included do
      field :votes_count, :type => Integer, :default => 0
      field :votes_average, :type => Integer, :default => 0
      field :votes_up, :type => Integer, :default => 0
      field :votes_down, :type => Integer, :default => 0

      field :votes, :type => Hash, :default => {}
    end

    def voted?(voter_id)
      if self[:votes] && !self[:votes].empty?
        self[:votes].include?(voter_id)
      else
        self.class.where({:_id => self.id, :"votes.#{voter_id}".exists => true}).exists?
      end
    end

    def vote!(value, voter_id, &block)
      value = value.to_i
      voter_id = voter_id.to_s

      old_vote = self.votes[voter_id]
      if !old_vote
        self.votes[voter_id] = value
        if self.save
          add_vote!(value, voter_id, &block)
          return :created
        end
      else
        if(old_vote != value)
          self.votes[voter_id] = value
          if self.save
            self.remove_vote!(old_vote, voter_id, &block)
            self.add_vote!(value, voter_id, &block)

            return :updated
          end
        else
          self.votes.delete(voter_id)
          if self.save
            remove_vote!(value, voter_id, &block)
            return :destroyed
          end
        end
      end
    end

    def add_vote!(value, voter_id, &block)
      if embedded?
        updates = {self.atomic_position+".votes_count" => 1,
                   self.atomic_position+".votes_average" => value.to_i}
        if value == 1
          updates[self.atomic_position+".votes_up"] = 1
        elsif value == -1
          updates[self.atomic_position+".votes_down"] = 1
        end

        self._parent.inc(updates)
      else
        updates = {:votes_count => 1, :votes_average => value.to_i}
        if value == 1
          updates[:votes_up] = 1
        elsif value == -1
          updates[:votes_down] = 1
        end

        self.inc(updates)
      end

      block.call(value, :add) if block

      self.on_add_vote(value, voter_id) if self.respond_to?(:on_add_vote)
    end

    def remove_vote!(value, voter_id, &block)
      if embedded?
        updates = {self.atomic_position+".votes_count" => -1,
                   self.atomic_position+".votes_average" => -value.to_i}
        if value == 1
          updates[self.atomic_position+".votes_up"] = -1
        elsif value == -1
          updates[self.atomic_position+".votes_down"] = -1
        end

        self._parent.increment(updates)
      else
        updates = {:votes_count => -1, :votes_average => -value}
        if value == 1
          updates[:votes_up] = -1
        elsif value == -1
          updates[:votes_down] = -1
        end

        self.inc(updates)
      end

      block.call(value, :remove) if block

      self.on_remove_vote(value, voter_id) if self.respond_to?(:on_remove_vote)
    end

    module ClassMethods
    end
  end
end
