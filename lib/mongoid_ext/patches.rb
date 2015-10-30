module Mongo
  class DB
    def nolock_eval(code, *args)
      code = BSON::Code.new(code) unless code.is_a? BSON::Code

      oh = BSON::OrderedHash.new
      oh[:$eval] = code
      oh[:args]  = args
      oh[:nolock] = true

      doc = command(oh)
      doc['retval']
    end
  end
end
