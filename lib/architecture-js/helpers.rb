module ArchitectureJS
  module Helpers
    
    def get_file_name(module_path)
      module_path = module_path.split(/[\\\/]/).last
      split = module_path.split(/[\.\-\s]/)
      module_filename = String.new
      split.each do |piece|
        module_filename << piece unless piece.match(/^module$|^js$/i)
      end
      module_filename
    end
    
    def array_to_yml(array)
      yml = array.empty? ? '[]' : %Q{['#{array.join("', '")}']}
    end
    
    module_function :get_file_name, :array_to_yml
    
  end
end