module Graphryder
  module Initializer
    def self.initialize!
      Updater.initialize!
      Importer.initialize! if ENV['GRAPHRYDER_IMPORT']
    end
  end
end
