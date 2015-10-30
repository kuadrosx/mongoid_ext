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
        self.class.where(:_id => id, :"votes.#{voter_id}".exists => true).exists?
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
      persist_vote(value)
      block.call(value, :add) if block
      on_add_vote(value, voter_id) if self.respond_to?(:on_add_vote)
    end

    def remove_vote!(value, voter_id, &block)
      persist_vote(value, false)
      block.call(value, :remove) if block
      on_remove_vote(value, voter_id) if self.respond_to?(:on_remove_vote)
    end

    module ClassMethods
    end

    private

    def persist_vote(value, add = true)
      delta = add ? 1 : -1

      field_prefix = ''
      target = self

      if embedded?
        field_prefix = "#{atomic_position}."
        target = _parent
      end

      updates = {
        :"#{field_prefix}votes_count" => delta,
        :"#{field_prefix}votes_average" => delta * value.to_i
      }

      if value == 1
        updates[:"#{field_prefix}votes_up"] = delta
      elsif value == -1
        updates[:"#{field_prefix}votes_down"] = delta
      end

      target.inc(updates)
    end
  end
end
