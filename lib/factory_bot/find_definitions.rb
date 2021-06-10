module FactoryBot
  class << self
    # An Array of strings specifying locations that should be searched for
    # factory definitions. By default, factory_bot will attempt to require
    # "factories", "test/factories" and "spec/factories". Only the first
    # existing file will be loaded.
    attr_accessor :definition_file_paths

    def find_definitions
      definition_file_paths.flat_map { |path|
        paths_for(path)
      }.uniq.each do |path|
        load path
      end
    end

    private

    def paths_for(path)
      path = File.expand_path(path)

      paths = []
      paths << path if File.file? path
      paths << "#{path}.rb" if File.file? "#{path}.rb"
      paths += Dir[File.join(path, "**", "*.rb")].sort if File.directory? path
      paths
    end
  end

  self.definition_file_paths = %w[factories test/factories spec/factories]
end
