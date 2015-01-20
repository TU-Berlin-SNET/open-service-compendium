module ServicesHelper
  def form_path
    if @service then
      service_path(@service.symbolic_name)
    else
      services_path
    end
  end

  def rowspan(value)
    case value
      when Array
        value.size
      when Hash
        value.values.map {|v| rowspan(v)}.sum
      else
        1
    end
  end
end
