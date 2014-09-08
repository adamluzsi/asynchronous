module Asynchronous

  class CleanClass < BasicObject
    protected(*(self.instance_methods - [:__send__,:object_id,:alias]))
  end

end