class Asynchronous::CleanClass < BasicObject

  keep_methods = [:object_id, :__send__, :alias]
  remove_methods = self.instance_methods - keep_methods
  remove_methods.each { |m| undef_method m }

end