module MongoidExt
  module Random
    extend ActiveSupport::Concern

    included do
      field :_random, :type => Float, :default => -> { rand }
      field :_random_times, :type => Float, :default => 0.0

      index(:_random => 1)
      index(:_random_times => 1)
    end

    module ClassMethods
      def random(conditions = {})
        r = rand
        doc = where(conditions.merge(:_random.gte => r)).asc(:_random_times, :_random).first
        doc ||= where(conditions.merge(:_random.lte => r)).asc(:_random_times, :_random).first
        doc.inc(:_random_times => 1.0) if doc
        doc
      end
    end
  end
end
