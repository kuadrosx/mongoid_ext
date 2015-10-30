module MongoidExt
  module Update
    def safe_update(white_list, values)
      white_list.each do |key|
        next unless values.key?(key)
        send("#{key}=", values[key])
      end
    end
  end
end

Mongoid::Document.send(:include, MongoidExt::Update)
