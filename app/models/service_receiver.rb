class SDL::Receivers::ServiceReceiver
  def refer_or_copy(instance)
    instance.class.new(instance.attributes.except('_id'))
  end
end