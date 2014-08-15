class SDL::Receivers::TypeInstanceReceiver
  def refer_or_copy(instance)
    #instance.class.new(instance.attributes.except('_id', '_parent'))

    cloned_instance = instance.clone
  end
end