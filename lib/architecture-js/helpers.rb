module ArchitectureJS
  module Helpers
    
    def array_to_yml(array)
      yml = array.empty? ? '[]' : %Q{['#{array.join("', '")}']}
    end

    def symbolize_keys(hash)
      symbolized_hash = Hash.new
      hash.each do |key, value|
        symbolized_hash[key.to_sym] = value
      end
      symbolized_hash
    end

    module_function :array_to_yml,
                    :symbolize_keys
  end
end