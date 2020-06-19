module Graphryder
  class Query
    include Singleton

    def perform(query)
      deserialize Discourse.redis.call(
        'GRAPH.QUERY',
        :graphryder,
        query.gsub("\n", '').squeeze(' ')
      )
    rescue Exception => e
      warn [
        "\e[31mFailed to perform Redisgraph query:",
        "#{query}\n",
        "\e[33m#{e.message}\e[0m",
      ].join("\n")
    end

    private

    def deserialize(nodes)
      nodes.first.each_with_index.reduce({}) do |result, (key, index)|
        result.merge(key => value_for(nodes.second.map { |v| v[index] }))
      end
    end

    def value_for(node)
      if node.all? { |record| record.respond_to?(:to_h) }
        node.map { |record| record.to_h['properties'].to_h }
      else
        node.first
      end
    end
  end
end
