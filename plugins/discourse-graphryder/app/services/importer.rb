module Graphryder
  class Importer
    def self.initialize!(force: false)
      if force
        puts "Force option was passed; deleting existing graph and rewriting it from scratch..."
        Graphryder::Query.instance.perform("MATCH (node) DETACH DELETE node RETURN node")
      end

      import_class "::User"
      import_class "::Post"
      import_class "::Topic"
      import_class "::AnnotatorStore::Tag"
      import_class "::AnnotatorStore::TagName"
      import_class "::AnnotatorStore::Annotation"
    end

    def self.import_class(klass_name)
      return unless const_defined?(klass_name)

      klass = klass_name.constantize
      models = block_given? ? yield(klass) : klass.all
      puts "Importing #{models.count} #{klass.to_s.pluralize}..."
      models.find_each(batch_size: 1000).each(&:graphryder_sync)
    end
  end
end
