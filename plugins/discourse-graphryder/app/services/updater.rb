module Graphryder
  class Updater
    def self.initialize!
      ::User.class_eval do
        after_save :graphryder_sync

        def is_annotator?
          admin? || groups.find_by(name: :annotator)
        end

        def graphryder_url
          "#{Discourse.base_url}/users/#{username}"
        end

        def graphryder_sync
          ::Graphryder::Query.instance.perform "
            MERGE (user:user {id:#{id}})
            SET user.label = '#{username}',
                user.avatar = '#{avatar_template}',
                user.timestamp = '#{updated_at}',
                user.url = '#{graphryder_url}'
            RETURN user
          "
        end
      end

      ::Topic.class_eval do
        after_save :graphryder_sync, if: :graphryder_sync?

        def graphryder_sync?
          allowed_groups.pluck(:name).include?(:annotator)
        end

        def graphryder_sync
          ::Graphryder::Query.instance.perform "
            MERGE (topic:topic {id:#{id}})
            SET topic.label = '#{id}',
                topic.title = '#{title&.gsub("\'", "’")}',
                topic.timestamp = '#{updated_at}',
                topic.url = '#{url}'
            MERGE (user:user {id:#{user_id}})
            MERGE (user)-[:AUTHORSHIP]->(topic)
            RETURN topic
          "
        end
      end

      ::Post.class_eval do
        after_save :graphryder_sync, if: :graphryder_sync?
        delegate :graphryder_sync?, to: :topic

        def graphryder_sync
          ::Graphryder::Query.instance.perform "
            MERGE (post:post {id:#{id}})
            SET post.label = '#{id}',
                post.topic_id = '#{topic_id}',
                post.number = '#{post_number}',
                post.content = '#{cooked&.gsub("\'", "’")}',
                post.timestamp = '#{updated_at}',
                post.url = '#{url}'
            MERGE (user:user {id:#{user_id}})
            MERGE (topic:topic {id:#{topic_id}})
            MERGE (user)-[:AUTHORSHIP]->(post)
            MERGE (post)-[:COMMENTS]->(topic)
            #{"
              MERGE (parent:post {topic_id:#{topic_id}, post_number:#{reply_to_post_number}})
              MERGE (post)-[:COMMENTS]->(parent)
            " if reply_to_post_number}
            RETURN post
          "
        end
      end

      ::AnnotatorStore::Tag.class_eval do
        after_save :graphryder_sync

        def graphryder_sync
          ::Graphryder::Query.instance.perform "
            MERGE (tag:tag {id:#{id}})
            SET tag.label = '#{name.downcase}',
                tag.name = '#{name.downcase}',
                tag.description = '#{description}',
                tag.timestamp = '#{updated_at}'
            #{"
              MERGE (user:user {id:#{creator_id}})
              MERGE (user)-[:AUTHORSHIP]->(tag)
            " if creator_id}
            RETURN tag
          "
        end
      end if Object.const_defined?("AnnotatorStore::Tag")

      ::AnnotatorStore::Annotation.class_eval do
        after_save :graphryder_sync

        def graphryder_sync
          ::Graphryder::Query.instance.perform "
            MERGE (annotation:annotation {id:#{id}})
            SET annotation.label = '#{id}',
                annotation.quote = '#{quote&.gsub("\'", "’")}',
                annotation.timestamp = '#{updated_at}'
            MERGE (user:user {id:#{creator_id}})
            MERGE (user)-[:AUTHORSHIP]->(annotation)
            #{"
              MERGE (tag:tag {id:#{tag_id}})
              MERGE (annotation)-[:REFERS_TO]->(tag)
            " if tag_id}
            #{"
              MERGE (post:post {id:#{post_id}})
              MERGE (annotation)-[:ANNOTATES]->(post)
            " if post_id}
            #{"
              MERGE (topic:topic {id:#{topic_id}})
              MERGE (annotation)-[:ANNOTATES]->(topic)
            " if topic_id}
            RETURN annotation
          "
        end
      end if Object.const_defined?("AnnotatorStore::Annotation")

      ::AnnotatorStore::TagName.class_eval do
        after_save :graphryder_sync

        def graphryder_sync
          ::Graphryder::Query.instance.perform "
            MERGE (tagname:tagname {id:#{id}})
            SET tagname.label = '#{name}',
                tagname.timestamp = '#{updated_at}'
            MERGE (tag:tag {id:#{tag_id}})
            MERGE (tag)-[:NAMED]->(tagname)
            RETURN tagname
          "
        end
      end
    end
  end
end
