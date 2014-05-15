class Nokogiri::XML::Element
  def mongoize
    return unless self
    obj_string = self.to_s
    compressed_string = Zlib::Deflate.deflate(obj_string, Zlib::BEST_SPEED)

    BSON::Binary.new(compressed_string, :generic)
  end

  def self.demongoize(serialized_object)
    return unless serialized_object
    decompressed_string = Zlib::Inflate.inflate(serialized_object.data)
    Nokogiri::XML.parse(decompressed_string).root
  end
end