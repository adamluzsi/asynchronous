require 'asynchronous'

selector = proc { |m| m.ancestors.include?(Enumerable) }
ObjectSpace.each_object(Module).select(&selector).each do |constant|
  constant.__send__(:include, ::Asynchronous::Enumerable)
end
