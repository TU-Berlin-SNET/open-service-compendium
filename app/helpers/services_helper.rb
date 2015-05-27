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

  def deepness(value, deepness=0)
    if value.is_a? Hash
      value.map do |key, item|
        deepness(item, deepness + 1)
      end.max
    elsif value.is_a? Array
      value.map do |item|
        deepness(item, deepness)
      end.max
    else
      deepness
    end
  end

  def merge_hashes(first, second)
    first.table_hash.deep_merge(second.table_hash) do |k, f, s| [f, s] end
  end
end