module Asynchronous
  class CleanClass < BasicObject

    # remove methods from the class!
    (self.instance_methods-[
        :object_id,
        :__send__,
        :alias,
    ]).each do |method|
      undef_method method
    end

  end
end