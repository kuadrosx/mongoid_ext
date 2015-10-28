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
      begin
        v = self[:votes]
      rescue
        v = {}
      end
      if v && !v.empty?
        self[:votes].include?(voter_id)
      else
        self.class.where({ :_id => id, :"votes.#{voter_id}".exists => true }).exists?
      end
    end

    def vote!(value, voter_id, &block)
      value = value.to_i
      voter_id = voter_id.to_s

      old_vote = votes[voter_id]
      if !old_vote
        votes[voter_id] = value
        if save
          add_vote!(value, voter_id, &block)
          return :created
        end
      else
        if (old_vote != value)
          votes[voter_id] = value
          if save
            self.remove_vote!(old_vote, voter_id, &block)
            self.add_vote!(value, voter_id, &block)

            return :updated
          end
        else
          votes.delete(voter_id)
          if save
            remove_vote!(value, voter_id, &block)
            return :destroyed
          end
        end
      end
    end

    def add_vote!(value, voter_id, &block)
      if embedded?
        updates = { atomic_position + ".votes_count" => 1,
                    atomic_position + ".votes_average" => value.to_i }
        if value == 1
          updates[atomic_position + ".votes_up"] = 1
        elsif value == -1
          updates[atomic_position + ".votes_down"] = 1
        end

        _parent.inc(updates)
      else
        updates = { :votes_count => 1, :votes_average => value.to_i }
        if value == 1
          updates[:votes_up] = 1
        elsif value == -1
          updates[:votes_down] = 1
        end

        inc(updates)
      end

      block.call(value, :add) if block

      on_add_vote(value, voter_id) if self.respond_to?(:on_add_vote)
    end

    def remove_vote!(value, voter_id, &block)
      if embedded?
        updates = { atomic_position + ".votes_count" => -1,
                    atomic_position + ".votes_average" => -value.to_i }
        if value == 1
          updates[atomic_position + ".votes_up"] = -1
        elsif value == -1
          updates[atomic_position + ".votes_down"] = -1
        end

        _parent.increment(updates)
      else
        updates = { :votes_count => -1, :votes_average => -value }
        if value == 1
          updates[:votes_up] = -1
        elsif value == -1
          updates[:votes_down] = -1
        end

        inc(updates)
      end

      block.call(value, :remove) if block

      on_remove_vote(value, voter_id) if self.respond_to?(:on_remove_vote)
    end

    module ClassMethods
    end
  end
end
