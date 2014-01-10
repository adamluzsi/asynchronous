class CleanClass < BasicObject

  # remove methods from the class!
  #def self.purge_methods

    (self.instance_methods-[
        :undef_method,
        :object_id,
        :__send__,
        :methods,
        :new
    ]).each do |method|
      undef_method method
    end

  #end

end