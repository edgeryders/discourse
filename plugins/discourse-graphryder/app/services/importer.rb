module Graphryder
  class Importer
    def self.initialize!
      import_class(::User)
      import_class(::Tag)
      import_class(::Post)
      import_class(::Topic)
      import_class(::AnnotatorStore::Annotation) if Object.const_defined?("AnnotatorStore::Annotation")
    end

    def self.import_class(klass)
      models = block_given? ? yield(klass) : klass.all
      puts "Importing #{models.count} #{klass.to_s.pluralize}..."
      models.find_each(batch_size: 1000).each(&:graphryder_sync)
    end
  end
end
